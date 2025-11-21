#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QScopedPointer>
#include "vehicledata.hpp"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Create QML engine
    QQmlApplicationEngine engine;

    // Create VehicleData using QScopedPointer for automatic cleanup
    QScopedPointer<VehicleData> vehicleData(new VehicleData());

    // Expose VehicleData to QML (keep ownership in C++)
    engine.rootContext()->setContextProperty("vehicleData", vehicleData.data());

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
