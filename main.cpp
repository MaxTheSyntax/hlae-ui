#include <QGuiApplication>
#include <QQmlApplicationEngine>

int main(int argc, char *argv[])
{
    qputenv("QT_QUICK_CONTROLS_STYLE", "Basic");

    QGuiApplication app(argc, argv);
    QCoreApplication::setOrganizationName("Syntax Studios");
    // QCoreApplication::setOrganizationDomain("syntaxworks.top");
    QCoreApplication::setApplicationName("HLAE UI");
    QCoreApplication::setApplicationVersion("a1.0.1");

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("hlae_ui", "Main");

    return QGuiApplication::exec();
}
