#ifndef CINEMA_H
#define CINEMA_H

#if (defined (Q_OS_LINUX) && !defined (Q_OS_ANDROID))
#include <MauiKit/utils.h>
#include <MauiKit/fmh.h>
#else
#include "utils.h"
#include "fmh.h"
#endif

class Cinema : public QObject
{
		Q_OBJECT
		Q_PROPERTY(QVariantList sourcesModel READ sourcesModel NOTIFY sourcesChanged FINAL)
		Q_PROPERTY(QStringList sources READ sources NOTIFY sourcesChanged FINAL)

	public:
		static Cinema * instance()
		{
			static Cinema cinema;
			return &cinema;
		}

		Cinema(const Cinema &) = delete;
		Cinema &operator=(const Cinema &) = delete;
		Cinema(Cinema &&) = delete;
		Cinema &operator=(Cinema &&) = delete;

	public slots:
		QVariantList sourcesModel() const;
		QStringList sources() const;

		void addSources(const QStringList &paths);
		void removeSources(const QString &path);

		void openVideos(const QList<QUrl> &urls);
		void refreshCollection();
		/*File actions*/
		static void showInFolder(const QStringList &urls);

	private:
		explicit Cinema(QObject* parent = nullptr);

		inline static const QStringList getSourcePaths()
		{
				static const QStringList defaultSources  = {FMH::VideosPath, FMH::DownloadsPath};
				const auto sources = UTIL::loadSettings("Sources", "Settings", defaultSources).toStringList();
				qDebug()<< "SOURCES" << sources;
				return sources;
		}

		inline static void saveSourcePath(QStringList const& paths)
		{
				auto sources = getSourcePaths();

				sources << paths;
				sources.removeDuplicates();

				qDebug()<< "Saving new sources" << sources;
				UTIL::saveSettings("Sources", sources, "Settings");
		}

		inline static void removeSourcePath(const QString &path)
		{
				auto sources = getSourcePaths();
				sources.removeOne(path);

				UTIL::saveSettings("Sources", sources, "Settings");
		}

	signals:
		void refreshViews(QVariantMap tables);
		void openUrls(QStringList urls);
		void sourcesChanged();
};

#endif // CINEMA_H
