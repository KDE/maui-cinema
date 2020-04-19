#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QIcon>

#ifdef Q_OS_ANDROID
#include <QGuiApplication>
#else
#include <QApplication>
#endif

#ifdef STATIC_KIRIGAMI
#include "3rdparty/kirigami/src/kirigamiplugin.h"
#endif

#ifdef STATIC_MAUIKIT
#include "3rdparty/mauikit/src/mauikit.h"
#include "mauiapp.h"
#else
#include <MauiKit/mauiapp.h>
#endif

#include "cinema_version.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

#ifdef Q_OS_ANDROID
    QGuiApplication app(argc, argv);
    if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
        return -1;
#else
    QApplication app(argc, argv);
#endif

    app.setApplicationName("cinema");
    app.setApplicationVersion(CINEMA_VERSION_STRING);
    app.setApplicationDisplayName("Cinema");
    app.setOrganizationName("Maui");
    app.setOrganizationDomain("org.maui.cinema");
    app.setWindowIcon(QIcon(":/img/assets/cinema.svg"));
    MauiApp::instance()->setDescription("Video collection manager and player.");
    MauiApp::instance()->setIconName("qrc:/img/assets/cinema.svg");
    MauiApp::instance()->setWebPage("https://mauikit.org");
    MauiApp::instance()->setDonationPage("https://mauikit.org");
    MauiApp::instance()->setReportPage("https://invent.kde.org/camiloh/cinema");    
    MauiApp::instance()->setCredits ({QVariantMap({{"name", "Camilo Higuita"}, {"email", "milo.h@aol.com"}, {"year", "2019-2020"}})});
    MauiApp::instance()->setHandleAccounts(false);

    QCommandLineParser parser;
    parser.setApplicationDescription("Video manager and player");
    const QCommandLineOption versionOption = parser.addVersionOption();
    parser.addOption(versionOption);
    parser.process(app);

    const QStringList args = parser.positionalArguments();

#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes();
#endif

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url, args](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);
    
#ifdef Q_OS_MACOS
//    MAUIMacOS::removeTitlebarFromWindow();
//    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif
    
    return app.exec();
}
