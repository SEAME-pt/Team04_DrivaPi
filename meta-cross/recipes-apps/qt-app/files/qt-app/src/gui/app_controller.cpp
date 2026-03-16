/**
 * @file app_controller.cpp
 * @author DrivaPi Team
 * @brief Application controller implementation — lifecycle, data sources, QML engine setup.
 */

#include "app_controller.hpp"
#include "settings_manager.hpp"
#include "music_player_controller.hpp"
#include "vehicle_data.hpp"
#include "kuksa_reader.hpp"
#include "pi_health_reader.hpp"

#ifdef ENABLE_CAN_MODE
#include "can_reader.hpp"
#endif

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <memory>
#include <QThread>
#include <QWindow>
#include <QCoreApplication>
#include <QDebug>
#include <QUrl>
#include <QMetaObject>
#include <QFileInfo>

namespace drivaui {

AppController::AppController(const RunConfig& config)
    : config_(config) {}

static QUrl pickQmlEntryPoint(QQmlApplicationEngine &engine)
{
    // Prefer installed QML on target (easy to update via RPM)
    const QString diskQml = "/usr/share/qt-app/resources/qml/main.qml";

    if (QFileInfo::exists(diskQml)) {
        qInfo() << "Loading QML from disk:" << diskQml;

        // Make local imports work (e.g. import "components")
        engine.addImportPath("/usr/share/qt-app/resources/qml");

        // If you use qmldir-based modules under that tree, this helps too
        // engine.addImportPath("/usr/share/qt-app/resources");

        return QUrl::fromLocalFile(diskQml);
    }

    qInfo() << "Loading QML from resources (qrc): qrc:/qml/main.qml";
    return QUrl(QStringLiteral("qrc:/qml/main.qml"));
}

int AppController::run(QGuiApplication& app)
{
    // Context properties declared BEFORE the engine so they are destroyed AFTER it.
    // (Stack variables are destroyed in reverse declaration order — engine must die first
    //  so QML bindings can't fire on dangling pointers during teardown.)
    std::unique_ptr<VehicleData> vehicleData(new VehicleData());
    // --- Settings Manager (must be created first) ---
    std::unique_ptr<SettingsManager> settingsManager(new SettingsManager());

    // --- Music Player Controller ---
    std::unique_ptr<MusicPlayerController> musicPlayerController(
        new MusicPlayerController(settingsManager.get())
    );

    QThread* workerThread = new QThread(); // no parent — we manage lifetime in aboutToQuit
    kuksa::KuksaReader* kuksaReader = nullptr;

#ifdef ENABLE_CAN_MODE
    CanReader* canReader = nullptr;
#endif

    // Create Pi Health Reader — reads metrics directly from procfs/sysfs
    std::unique_ptr<drivaui::PiHealthReader> piHealth(new drivaui::PiHealthReader());
    piHealth->setIntervalMs(2000);
    piHealth->start();

    drivaui::PiHealthReader* piHealthRaw = piHealth.get();

    if (config_.useKuksa) {
        qInfo() << "Starting in KUKSA mode (default)";
        kuksa::KuksaOptions ko = config_.kuksa;
        kuksaReader = new kuksa::KuksaReader(ko);
        kuksaReader->moveToThread(workerThread);

        QObject::connect(workerThread, &QThread::started, kuksaReader, &kuksa::KuksaReader::start);
        QObject::connect(workerThread, &QThread::finished, kuksaReader, &kuksa::KuksaReader::deleteLater);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::speedReceived,
                         vehicleData.get(), &VehicleData::setSpeed,
                         Qt::QueuedConnection);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::lvBatteryPercentReceived,
                         vehicleData.get(), &VehicleData::setStm32Battery,
                         Qt::QueuedConnection);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::lvBatteryVoltageReceived,
                         vehicleData.get(), &VehicleData::setStm32BatteryVoltage,
                         Qt::QueuedConnection);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::stm32TemperatureReceived,
                         vehicleData.get(), &VehicleData::setStm32Temperature,
                         Qt::QueuedConnection);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::stm32HumidityReceived,
                         vehicleData.get(), &VehicleData::setStm32Humidity,
                         Qt::QueuedConnection);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::rpiBatteryPercentReceived,
                         vehicleData.get(), &VehicleData::setRpiBattery,
                         Qt::QueuedConnection);
        QObject::connect(kuksaReader, &kuksa::KuksaReader::rpiBatteryVoltageReceived,
                         vehicleData.get(), &VehicleData::setRpiBatteryVoltage,
                         Qt::QueuedConnection);

        // CurrentGear only (no SelectedGear in VSS v4 for this use case)
        QObject::connect(kuksaReader, &kuksa::KuksaReader::currentGearReceived,
                         vehicleData.get(), &VehicleData::handleCurrentGearUpdate,
                         Qt::QueuedConnection);

        QObject::connect(kuksaReader, &kuksa::KuksaReader::errorOccurred,
                         [](const QString& err) { qCritical() << "[KUKSA]" << err; });
    }
#ifdef ENABLE_CAN_MODE
    else {
        qInfo() << "Starting in CAN mode on" << config_.canInterface << "(--can)";
        canReader = new CanReader(config_.canInterface);
        canReader->moveToThread(workerThread);

        QObject::connect(workerThread, &QThread::started, canReader, &CanReader::start);
        QObject::connect(workerThread, &QThread::finished, canReader, &CanReader::deleteLater);

        QObject::connect(canReader, &CanReader::canMessageReceived,
                         vehicleData.get(), &VehicleData::handleCanMessage,
                         Qt::QueuedConnection);
    }
#endif

    workerThread->start();

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [workerThread, piHealthRaw,
#ifdef ENABLE_CAN_MODE
        canReader,
#endif
        kuksaReader]() {
        // Stop Pi health polling first so no timer fires during teardown
        if (piHealthRaw) piHealthRaw->stop();
#ifdef ENABLE_CAN_MODE
        if (canReader) {
            QMetaObject::invokeMethod(canReader, "stop", Qt::DirectConnection);
        }
#endif
        if (kuksaReader) {
            QMetaObject::invokeMethod(kuksaReader, "stop", Qt::DirectConnection);
        }
        if (workerThread) {
            workerThread->quit();
            if (!workerThread->wait(2000)) {
                qWarning() << "Worker thread did not quit in 2 seconds, terminating";
                workerThread->terminate();
                workerThread->wait();
            }
            delete workerThread;
        }
    });

    // Engine is in a nested scope so it is destroyed BEFORE the context property objects
    // above (which are on the outer scope). This prevents QML bindings from firing on
    // dangling pointers during teardown.
    int result;
    {
        QQmlApplicationEngine engine;

        engine.rootContext()->setContextProperty("vehicleData", vehicleData.get());
        engine.rootContext()->setContextProperty("settingsManager", settingsManager.get());
        engine.rootContext()->setContextProperty("musicPlayerController", musicPlayerController.get());
        engine.rootContext()->setContextProperty("piHealthReader", piHealthRaw);

        const QUrl url = pickQmlEntryPoint(engine);

        QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                         &app, [url](QObject* obj, const QUrl& objUrl) {
                             if (!obj && url == objUrl)
                                 QCoreApplication::exit(-1);
                         },
                         Qt::QueuedConnection);

        engine.load(url);

        // 1. Verify the engine actually loaded something
        if (engine.rootObjects().isEmpty()) {
            qCritical() << "Critical: QML Engine failed to load any root objects. Check your QML syntax/paths.";
            return -1; // Exit gracefully
        }

        // QQmlApplicationEngine::rootObjects() returns QObject*, not QWindow*.
        // The QML root may be a QtQuick Window, ApplicationWindow, or a plain Item
        // depending on the QML file. We must attempt a dynamic cast before calling
        // any window-specific API such as showFullScreen().
        QObject* rootObj = engine.rootObjects().first();
        if (rootObj) {
            QWindow* window = qobject_cast<QWindow*>(rootObj);
            if (window) {
                window->showFullScreen();
            } else {
                qWarning() << "Root QML object is not a QWindow — showFullScreen() skipped."
                           << "Ensure main.qml has a Window or ApplicationWindow as its root.";
            }
        }

        result = app.exec();
    } // engine destroyed here — QML is fully shut down before context properties below

    return result;
}

}  // namespace drivaui
