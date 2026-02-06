#include "models/system_status.hpp"
#include "models/notification_manager.hpp"
#include "models/can_logger.hpp"
#include "gui/app_controller.hpp"
#include "gui/settings_manager.hpp"
#include "gui/music_player_controller.hpp"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScopedPointer>
#include <QThread>
#include <QWindow>
#include <QCoreApplication>
#include <QDebug>
#include <QUrl>
#include <QMetaObject>

#include "gui/vehicle_data.hpp"
#include "gui/kuksa_reader.hpp"
#ifdef ENABLE_CAN_MODE
#include "gui/can_reader.hpp"
#endif

namespace drivaui {

AppController::AppController(const RunConfig& config)
    : config_(config) {}

int AppController::run(QGuiApplication& app)
{


    QQmlApplicationEngine engine;
    QScopedPointer<VehicleData> vehicleData(new VehicleData());
    QScopedPointer<SystemStatus> systemStatus(new SystemStatus());
    QScopedPointer<NotificationManager> notificationManager(NotificationManager::instance());
    QScopedPointer<CANLogger> canLogger(new CANLogger());

    // --- Settings Manager (must be created first) ---
    QScopedPointer<SettingsManager> settingsManager(new SettingsManager());

    // --- Music Player Controller ---
    QScopedPointer<MusicPlayerController> musicPlayerController(new MusicPlayerController(settingsManager.data()));

    engine.rootContext()->setContextProperty("vehicleData", vehicleData.data());
    engine.rootContext()->setContextProperty("systemStatus", systemStatus.data());
    engine.rootContext()->setContextProperty("notificationManager", notificationManager.data());
    engine.rootContext()->setContextProperty("canLogger", canLogger.data());
    engine.rootContext()->setContextProperty("settingsManager", settingsManager.data());
    engine.rootContext()->setContextProperty("musicPlayerController", musicPlayerController.data());

    QThread* workerThread = new QThread(&app);
    kuksa::KUKSAReader* kuksaReader = nullptr;
#ifdef ENABLE_CAN_MODE
    CANReader* canReader = nullptr;
#endif

    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    if (config_.useKuksa) {
        qInfo() << "Starting in KUKSA mode (default)";
        kuksa::KuksaOptions ko = config_.kuksa;
        kuksaReader = new kuksa::KUKSAReader(ko);
        kuksaReader->moveToThread(workerThread);
        QObject::connect(workerThread, &QThread::started, kuksaReader, &kuksa::KUKSAReader::start);
        QObject::connect(workerThread, &QThread::finished, kuksaReader, &kuksa::KUKSAReader::deleteLater);
        QObject::connect(kuksaReader, &kuksa::KUKSAReader::speedReceived,
                         vehicleData.data(), &VehicleData::handleSpeedUpdate);
    }
#ifdef ENABLE_CAN_MODE
    else {
        qInfo() << "Starting in CAN mode on" << config_.canInterface << "(--can)";
        canReader = new CANReader(config_.canInterface);
        canReader->moveToThread(workerThread);
        QObject::connect(workerThread, &QThread::started, canReader, &CANReader::start);
        QObject::connect(workerThread, &QThread::finished, canReader, &CANReader::deleteLater);
        QObject::connect(canReader, &CANReader::canMessageReceived,
                         vehicleData.data(), &VehicleData::handleCanMessage,
                         Qt::QueuedConnection);
        // Feed raw CAN frames to CANLogger for recording
        QObject::connect(canReader, &CANReader::canMessageReceived,
                         &app, [canLogger = canLogger.data()](const QByteArray &payload, uint32_t canId){
                             if (!canLogger->isRecording()) return;
                             const int dlc = qMin(payload.size(), 8);
                             const uint8_t *data = reinterpret_cast<const uint8_t*>(payload.constData());
                             canLogger->recordFrame(canId, static_cast<uint8_t>(dlc), data);
                         }, Qt::QueuedConnection);
    }
#endif

    workerThread->start();

    QObject::connect(&app, &QCoreApplication::aboutToQuit, [workerThread,
#ifdef ENABLE_CAN_MODE
        canReader,
#endif
        kuksaReader]() {
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

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject* obj, const QUrl& objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     },
                     Qt::QueuedConnection);

    engine.load(url);

    if (!engine.rootObjects().isEmpty()) {
        QWindow* window = qobject_cast<QWindow*>(engine.rootObjects().first());
        // if (window) {
        //     window->showFullScreen();
        // }
    }

    return app.exec();
}

}  // namespace drivaui
