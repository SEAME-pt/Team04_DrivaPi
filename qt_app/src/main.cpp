#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScopedPointer>
#include <QWindow>
#include <QThread>
#include <QPointer>
#include "vehicledata.hpp"
#include "canreader.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Create QML engine
    QQmlApplicationEngine engine;

    // Create VehicleData using QScopedPointer for automatic cleanup
    QScopedPointer<VehicleData> vehicleData(new VehicleData());

    // Expose VehicleData to QML (keep ownership in C++)
    engine.rootContext()->setContextProperty("vehicleData", vehicleData.data());

    // Create CANReader and move it to its own thread if needed
    QThread *canThread = new QThread(&app);

    // Use a raw pointer for the worker object (we call deleteLater on it)
    CANReader *canReader = new CANReader(QStringLiteral("vcan0"));
    canReader->moveToThread(canThread);

    // Start CANReader when thread starts
    QObject::connect(canThread, &QThread::started, canReader, &CANReader::start);
    // Ensure worker object is deleted when thread finishes (safe because it's a QObject)
    QObject::connect(canThread, &QThread::finished, canReader, &CANReader::deleteLater);

    // Forward CAN messages from thread worker to UI (thread-safe)
    QObject::connect(canReader, &CANReader::canMessageReceived,
                     vehicleData.data(), &VehicleData::handleCanMessage,
                     Qt::QueuedConnection);

    // Handle CANReader errors (lambda - no capture needed here)
    QObject::connect(canReader, &CANReader::errorOccurred, [](const QString &msg)
    {
        qWarning() << "CANReader error:" << msg;
    });

    // Start the CAN thread
    canThread->start();

    // Clean up thread and worker on app exit. Capture raw pointers by value.
    QObject::connect(&app, &QCoreApplication::aboutToQuit, [canThread, canReader]() {
        // ask the thread worker to stop reading CAN messages (queued to worker thread)
        QMetaObject::invokeMethod(canReader, "stop", Qt::QueuedConnection);

        // request thread to quit its event loop
        canThread->quit();

        // wait for thread to finish
        if (!canThread->wait(2000)) {
            qWarning() << "CAN thread did not quit in 2 seconds, terminating";
            canThread->terminate();
            canThread->wait();
        }
        // delete the thread (worker will be deleted via deleteLater)
        delete canThread;
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
