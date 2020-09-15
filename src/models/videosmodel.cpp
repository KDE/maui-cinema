#include "videosmodel.h"
#include <QFileSystemWatcher>

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#include "fmstatic.h"
#include "fileloader.h"
#else
#include <MauiKit/tagging.h>
#include <MauiKit/fmstatic.h>
#include <MauiKit/fileloader.h>
#endif

VideosModel::VideosModel(QObject *parent) : MauiList(parent)
  , m_fileLoader(new FMH::FileLoader())
  , m_watcher (new QFileSystemWatcher(this))
  , m_autoReload(true)
  , m_autoScan(true)
  , m_recursive (true)
{
	qDebug()<< "CREATING GALLERY LIST";

    connect(m_fileLoader, &FMH::FileLoader::finished,[](FMH::MODEL_LIST items)
	{
		qDebug() << "Items finished" << items.size();
	});

    connect(m_fileLoader, &FMH::FileLoader::itemsReady,[this](FMH::MODEL_LIST items)
	{
		emit this->preListChanged();
		this-> list << items;
		emit this->postListChanged();
		emit countChanged(); //TODO this is a bug from mauimodel not changing the count right //TODO
	});

    connect(m_fileLoader, &FMH::FileLoader::itemReady,[this](FMH::MODEL item)
	{
		this->insertFolder(item[FMH::MODEL_KEY::SOURCE]);

//        emit this->preItemAppended();
//        this->list.append(item);
//        emit this->postItemAppended();
	});

	connect(m_watcher, &QFileSystemWatcher::directoryChanged, [this](QString dir)
	{
		qDebug()<< "Dir changed" << dir;
		this->rescan();
//        this->scan({QUrl::fromLocalFile(dir)}, m_recursive);
	});

	connect(m_watcher, &QFileSystemWatcher::fileChanged, [](QString file)
	{
		qDebug()<< "File changed" << file;
	});
}

VideosModel::~VideosModel()
{
	delete m_fileLoader;
}

FMH::MODEL_LIST VideosModel::items() const
{
	return this->list;
}

void VideosModel::setUrls(const QList<QUrl> &urls)
{
	qDebug()<< "setting urls"<< this->m_urls << urls;

	if(this->m_urls == urls)
		return;

	this->m_urls = urls;
	this->clear();
	emit this->urlsChanged();

	if(m_autoScan)
	{
		this->scan(m_urls, m_recursive, m_limit);
	}
}

QList<QUrl> VideosModel::urls() const
{
	return m_urls;
}

void VideosModel::setAutoScan(const bool &value)
{
	if(m_autoScan == value)
		return;

	m_autoScan = value;
	emit autoScanChanged();
}

bool VideosModel::autoScan() const
{
	return m_autoScan;
}

void VideosModel::setAutoReload(const bool &value)
{
	if(m_autoReload == value)
		return;

	m_autoReload = value;
	emit autoReloadChanged();
}

bool VideosModel::autoReload() const
{
	return m_autoReload;
}

QList<QUrl> VideosModel::folders() const
{
	return m_folders;
}

bool VideosModel::recursive() const
{
	return m_recursive;
}

int VideosModel::limit() const
{
	return m_limit;
}

void VideosModel::scan(const QList<QUrl> &urls, const bool &recursive, const int &limit)
{
	this->scanTags (extractTags (urls), recursive, limit);
    m_fileLoader->requestPath(urls, recursive, FMH::FILTER_LIST[FMH::FILTER_TYPE::VIDEO]);
}

void VideosModel::scanTags(const QList<QUrl> & urls, const bool & recursive, const int & limit)
{
	FMH::MODEL_LIST res;
	for(const auto &tagUrl : urls)
	{
        auto items = Tagging::getInstance ()->getUrls(tagUrl.toString ().replace ("tags:///", ""), true, limit, "video");

		for(const auto &item : items)
		{
			const auto url = QUrl(item.toMap ().value ("url").toString());
			if(FMH::fileExists(url))
                res << FMH::getFileInfoModel(url);
		}
	}

	emit this->preListChanged ();
	list << res;
	emit this->postListChanged ();
	emit countChanged();
}

void VideosModel::insertFolder(const QUrl &path)
{
	if(!m_folders.contains(path))
	{
		m_folders << path;

		if(m_autoReload)
		{
			this->m_watcher->addPath(path.toLocalFile());
		}

		emit foldersChanged();
	}
}

QList<QUrl> VideosModel::extractTags(const QList<QUrl> & urls)
{
	QList<QUrl> res;
	return std::accumulate(urls.constBegin (), urls.constEnd (), res, [](QList<QUrl> &list, const QUrl &url)
	{
		if(FMH::getPathType (url) == FMH::PATHTYPE_KEY::TAGS_PATH)
		{
			list << url;
		}

		return list;
	});
}

QVariantMap VideosModel::get(const int &index) const
{
	if(index >= this->list.size() || index < 0)
		return QVariantMap();
	return FMH::toMap(this->list.at( this->mappedIndex(index)));
}

bool VideosModel::remove(const int &index)
{
	Q_UNUSED (index)
	return false;
}

bool VideosModel::deleteAt(const int &index)
{
	if(index >= this->list.size() || index < 0)
		return false;

	const auto index_ = this->mappedIndex(index);

	emit this->preItemRemoved(index_);
	auto item = this->list.takeAt(index_);
	FMStatic::removeFiles ({item[FMH::MODEL_KEY::URL]});
	emit this->postItemRemoved();

	return true;
}

void VideosModel::append(const QVariantMap &pic)
{
	emit this->preItemAppended();
	this->list << FMH::toModel (pic);
	emit this->postItemAppended();
}

void VideosModel::append(const QString &url)
{
	emit this->preItemAppended();
    this->list << FMH::getFileInfoModel(QUrl::fromUserInput (url));
	emit this->postItemAppended();
}

void VideosModel::clear()
{
	emit this->preListChanged();
	this->list.clear ();
	emit this->postListChanged();

	this->m_folders.clear ();
	emit foldersChanged();
}

void VideosModel::rescan()
{
	this->clear();
	this->scan(m_urls, m_recursive, m_limit);
}

void VideosModel::reload()
{
	this->scan(m_urls, m_recursive, m_limit);
}

void VideosModel::setRecursive(bool recursive)
{
	if (m_recursive == recursive)
		return;

	m_recursive = recursive;
	emit recursiveChanged(m_recursive);
}

void VideosModel::setlimit(int limit)
{
	if (m_limit == limit)
		return;

	m_limit = limit;
	emit limitChanged(m_limit);
}
