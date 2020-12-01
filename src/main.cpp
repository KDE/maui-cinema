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

#ifndef STATIC_MAUIKIT
#include "cinema_version.h"
#endif

#include "src/models/videosmodel.h"
#include "src/models/tagsmodel.h"

#include "src/utils/cinema.h"

#if defined Q_OS_MACOS || defined Q_OS_WIN
#include <KF5/KI18n/KLocalizedString>
#else
#include <KI18n/KLocalizedString>
#endif

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
	QCoreApplication::setAttribute(Qt::AA_DontCreateNativeWidgetSiblings);
	QCoreApplication::setAttribute(Qt::AA_UseHighDpiPixmaps, true);
	QCoreApplication::setAttribute(Qt::AA_DisableSessionManager, true);

#ifdef Q_OS_ANDROID
	QGuiApplication app(argc, argv);
	if (!MAUIAndroid::checkRunTimePermissions({"android.permission.WRITE_EXTERNAL_STORAGE"}))
		return -1;
#else
	QApplication app(argc, argv);
#endif

	app.setOrganizationName("Maui");
	app.setWindowIcon(QIcon(":/img/assets/cinema.svg"));

	MauiApp::instance()->setIconName("qrc:/img/assets/cinema.svg");
	MauiApp::instance()->setHandleAccounts(false);

	KLocalizedString::setApplicationDomain("cinema");
	KAboutData about(QStringLiteral("cinema"), i18n("Cinema"), CINEMA_VERSION_STRING, i18n("Video collection manager and player."),
					 KAboutLicense::LGPL_V3, i18n("© 2020 Nitrux Development Team"));
	about.addAuthor(i18n("Camilo Higuita"), i18n("Developer"), QStringLiteral("milo.h@aol.com"));
	about.setHomepage("https://mauikit.org");
	about.setProductName("maui/cinema");
	about.setBugAddress("https://invent.kde.org/maui/buho/-/issues");
	about.setOrganizationDomain(CINEMA_URI);
	about.setProgramLogo(app.windowIcon());

	KAboutData::setApplicationData(about);

	QCommandLineParser parser;
	parser.process(app);

	about.setupCommandLine(&parser);
	about.processCommandLine(&parser);

	const QStringList args = parser.positionalArguments();

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


#ifdef STATIC_KIRIGAMI
    KirigamiPlugin::getInstance().registerTypes();
#endif

#ifdef STATIC_MAUIKIT
    MauiKit::getInstance().registerTypes(&engine);
#endif

	qmlRegisterType<VideosModel>(CINEMA_URI, 1, 0, "Videos");
	qmlRegisterType<TagsModel>(CINEMA_URI, 1, 0, "Tags");
	qmlRegisterSingletonInstance<Cinema>(CINEMA_URI, 1, 0, "Cinema", Cinema::instance ());

	engine.load(url);

#ifdef Q_OS_MACOS
//    MAUIMacOS::removeTitlebarFromWindow();
//    MauiApp::instance()->setEnableCSD(true); //for now index can not handle cloud accounts
#endif

	return app.exec();
}
