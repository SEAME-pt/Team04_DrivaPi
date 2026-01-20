#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScopedPointer>
#include <QWindow>
#include <QThread>
#include <QPointer>
#include <QCommandLineParser>
#include <QCommandLineOption>
#include "vehicle_data.hpp"
#include "can_reader.hpp"
#include "kuksa_reader.hpp"
#include "models/system_status.hpp"
#include "models/notification_manager.hpp"
#include "models/can_logger.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    app.setApplicationName("DrivaPi Dashboard");

    // --- 1. ARGUMENT PARSING ---
    QCommandLineParser parser;
    parser.setApplicationDescription("Hybrid Dashboard (CAN / Kuksa)");
    parser.addHelpOption();
    
    // Define the "--kuksa" or "-k" option
    QCommandLineOption kuksaOption(QStringList() << "k" << "kuksa", 
        "Enable Kuksa mode (gRPC). Defaults to CAN if omitted.");
    parser.addOption(kuksaOption);
    
    parser.process(app);
    
    // Check if the user passed the argument
    bool useKuksa = parser.isSet(kuksaOption);

    // UI and Engine setup
    QQmlApplicationEngine engine;
    QScopedPointer<VehicleData> vehicleData(new VehicleData());
    QScopedPointer<SystemStatus> systemStatus(new SystemStatus());
    QScopedPointer<NotificationManager> notificationManager(NotificationManager::instance());
    QScopedPointer<CANLogger> canLogger(new CANLogger());
    
    // Expose models to QML (keep ownership in C++)
    engine.rootContext()->setContextProperty("vehicleData", vehicleData.data());
    engine.rootContext()->setContextProperty("systemStatus", systemStatus.data());
    engine.rootContext()->setContextProperty("notificationManager", notificationManager.data());
    engine.rootContext()->setContextProperty("canLogger", canLogger.data());

    // Worker thread setup for data reading
    QThread *workerThread = new QThread(&app);

    // Pointers to readers for cleanup
    CANReader *canReader = nullptr;
    KUKSAReader *kuksaReader = nullptr;

    if (useKuksa)
    {
        qInfo() << "Starting in KUKSA mode";
        // KUKSA Reader setup
        kuksaReader = new KUKSAReader();
        kuksaReader->moveToThread(workerThread);
        // Start KUKSAReader when thread starts
        QObject::connect(workerThread, &QThread::started, kuksaReader, &KUKSAReader::start);
        // Ensure worker object is deleted when thread finishes (safe because it's a QObject)
        QObject::connect(workerThread, &QThread::finished, kuksaReader, &KUKSAReader::deleteLater);
        // Forward speed data from KUKSAReader to VehicleData (thread-safe)
        QObject::connect(kuksaReader, &KUKSAReader::speedReceived,
                         vehicleData.data(), &VehicleData::handleSpeedUpdate);
    } else {
        qInfo() << "Starting in CAN mode";
        // CAN Reader setup
        canReader = new CANReader(QStringLiteral("vcan0"));
        canReader->moveToThread(workerThread);
        // Start CANReader when thread starts
        QObject::connect(workerThread, &QThread::started, canReader, &CANReader::start);
        // Ensure worker object is deleted when thread finishes (safe because it's a QObject)
        QObject::connect(workerThread, &QThread::finished, canReader, &CANReader::deleteLater);

        // Forward CAN messages from thread worker to UI (thread-safe)
        QObject::connect(canReader, &CANReader::canMessageReceived,
                        vehicleData.data(), &VehicleData::handleCanMessage,
                        Qt::QueuedConnection);
    }

    workerThread->start();

    // CLEANUP HANDLING
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [workerThread, canReader, kuksaReader]() {
        if (canReader)
        {
            // ask CAN reader to stop
            QMetaObject::invokeMethod(canReader, "stop", Qt::QueuedConnection);
        }
        if (workerThread)
        {
            workerThread->quit();
            // wait for thread to finish
            if (!workerThread->wait(2000)) {
                qWarning() << "Worker thread did not quit in 2 seconds, terminating";
                workerThread->terminate();
                workerThread->wait();
            }
            // delete the thread (worker will be deleted via deleteLater)
            delete workerThread;
        }
    });

    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/qml/main.qml"));

    QObject::connect(
        &engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection
    );

    engine.load(url);

    if (!engine.rootObjects().isEmpty()) {
        QWindow *window = qobject_cast<QWindow*>(engine.rootObjects().first());
        if (window) {
            window->showFullScreen();  // ✅ Hides title bar & taskbar
        }
    }

    // Keep running until app quits
    return app.exec();

    // vehicleData will be automatically destroyed when going out of scope
}
