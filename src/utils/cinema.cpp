#include "cinema.h"
#include <QDesktopServices>

Cinema::Cinema(QObject *parent) : QObject(parent)
{
}

QVariantList Cinema::sourcesModel() const
{
	QVariantList res;
	const auto sources = getSourcePaths();
	return std::accumulate(sources.constBegin(), sources.constEnd(), res, [](QVariantList &res, const QString &url)
	{
		res << FMH::getDirInfo(url);
		return res;
	});
}

QStringList Cinema::sources() const
{
	return getSourcePaths();
}

void Cinema::openVideos(const QList<QUrl> &pics)
{
	emit this->viewPics(QUrl::toStringList(pics));
}

void Cinema::refreshCollection()
{
	const auto sources = getSourcePaths();
	qDebug()<< "getting default sources to look up" << sources;
}

void Cinema::showInFolder(const QStringList &urls)
{
	for(const auto &url : urls)
		QDesktopServices::openUrl(FMH::fileDir(url));
}

void Cinema::addSources(const QStringList &paths)
{
	saveSourcePath(paths);
	emit sourcesChanged();
}

void Cinema::removeSources(const QString &path)
{
	removeSourcePath(path);
	emit sourcesChanged();
}
