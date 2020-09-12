#include <QQmlApplicationEngine>
#include <QCommandLineParser>
#include <QIcon>
#include <QFileInfo>

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
#include "src/models/videosmodel.h"
#include "src/utils/cinema.h"

#define CINEMA_URI "org.maui.cinema"

static const  QList<QUrl>  getFolderVideos(const QString &path)
{
	QList<QUrl> urls;

	if (QFileInfo(path).isDir())
	{
		QDirIterator it(path, FMH::FILTER_LIST[FMH::FILTER_TYPE::IMAGE], QDir::Files, QDirIterator::Subdirectories);
		while (it.hasNext())
			urls << QUrl::fromLocalFile(it.next());

	}else if (QFileInfo(path).isFile())
		urls << path;

	return urls;
}

static const QList<QUrl> openFiles(const QStringList &files)
{
	QList<QUrl>  urls;

	if(files.size()>1)
	{
		for(const auto &file : files)
			urls << QUrl::fromUserInput(file);
	}
	else if(files.size() == 1)
	{
		auto folder = QFileInfo(files.first()).dir().absolutePath();
		urls = getFolderVideos(folder);
		urls.removeOne(QUrl::fromLocalFile(files.first()));
		urls.insert(0,QUrl::fromLocalFile(files.first()));
	}

	return urls;
}

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
	app.setOrganizationDomain(CINEMA_URI);
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
	QList<QUrl> videos;
	if(!args.isEmpty())
		videos = openFiles(args);

	QQmlApplicationEngine engine;
	const QUrl url(QStringLiteral("qrc:/main.qml"));
	QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
					 &app, [url, args, &videos](QObject *obj, const QUrl &objUrl)
	{
		if (!obj && url == objUrl)
			QCoreApplication::exit(-1);

		if(!videos.isEmpty())
			Cinema::instance ()->openVideos(videos);

	}, Qt::QueuedConnection);

	qmlRegisterType<VideosModel>(CINEMA_URI, 1, 0, "Videos");
	qmlRegisterSingletonInstance<Cinema>(CINEMA_URI, 1, 0, "Cinema", Cinema::instance ());

	engine.load(url);

#ifdef Q_OS_MACOS
//    MAUIMacOS::removeTitlebarFromWindow();
//    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

	return app.exec();
}
