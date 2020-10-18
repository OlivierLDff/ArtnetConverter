// ──── INCLUDE ────

// Oliv Qt
#include <Qaterial/Qaterial.hpp>

// Qt
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QLibraryInfo>

int main(int argc, char* argv[])
{
#if defined(ARTNETCONVERTER_IGNORE_ENV)
    const QString executable = argv[0];
#    if defined(Q_OS_WINDOWS)
    const auto executablePath = executable.mid(0, executable.lastIndexOf("\\"));
    QCoreApplication::setLibraryPaths({executablePath});
#    endif
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    // ──── REGISTER APPLICATION ────

    QGuiApplication::setOrganizationName("Oliv");
    QGuiApplication::setApplicationName("ArtnetConverter");
    QGuiApplication::setOrganizationDomain("https://github.com/OlivierLDff/ArtnetConverter");
    QGuiApplication::setApplicationVersion(qaterial::Version::version().readable());

    // ──── LOAD AND REGISTER QML ────

#if defined(ARTNETCONVERTER_IGNORE_ENV)
    engine.setImportPathList({QLibraryInfo::location(QLibraryInfo::Qml2ImportsPath), "qrc:/", "qrc:/qt-project.org/imports"});
#else
    engine.addImportPath("qrc:/");
#endif

    // Load Qaterial
    qaterial::loadQmlResources();
    qaterial::registerQmlTypes();

    // Load ArtnetConverter
    Q_INIT_RESOURCE(ArtnetConverter);

    // ──── LOAD QML MAIN ────
#if defined(Q_OS_ANDROID) || defined(Q_OS_IOS) || defined(EMSCRIPTEN)
    engine.load(QUrl("qrc:/ArtnetConverter/ApplicationWindow.qml"));
#else
    engine.load(QUrl("qrc:/ArtnetConverter/SplashScreenApplication.qml"));
#endif
    if(engine.rootObjects().isEmpty())
        return -1;

    // ──── START EVENT LOOP ────
    return QGuiApplication::exec();
}
