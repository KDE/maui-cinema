#include "clip.h"
#include <QDesktopServices>

Clip::Clip(QObject *parent) : QObject(parent)
{
}

QVariantList Clip::sourcesModel() const
{
	QVariantList res;
	const auto sources = getSourcePaths();
	return std::accumulate(sources.constBegin(), sources.constEnd(), res, [](QVariantList &res, const QString &url)
	{
		res << FMH::getDirInfo(url);
		return res;
	});
}

QStringList Clip::sources() const
{
	return getSourcePaths();
}

void Clip::openVideos(const QList<QUrl> &urls)
{
	emit this->openUrls(QUrl::toStringList(urls));
}

void Clip::refreshCollection()
{
	const auto sources = getSourcePaths();
	qDebug()<< "getting default sources to look up" << sources;
}

void Clip::showInFolder(const QStringList &urls)
{
	for(const auto &url : urls)
		QDesktopServices::openUrl(FMH::fileDir(url));
}

void Clip::addSources(const QStringList &paths)
{
	saveSourcePath(paths);
	emit sourcesChanged();
}

void Clip::removeSources(const QString &path)
{
	removeSourcePath(path);
	emit sourcesChanged();
}
