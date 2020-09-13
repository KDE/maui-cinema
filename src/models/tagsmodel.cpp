#include "tagsmodel.h"

#ifdef STATIC_MAUIKIT
#include "tagging.h"
#else
#include <MauiKit/tagging.h>
#endif

TagsModel::TagsModel(QObject *parent) : MauiList(parent)
{
    connect(Tagging::getInstance(), &Tagging::tagged, [this](QString tag)
    {
        emit this->preItemAppended();
        this->list << (this->packPlaylist(tag));
        emit this->postItemAppended();
    });
}

void TagsModel::componentComplete()
{
    this->setList();
}

FMH::MODEL_LIST TagsModel::items() const
{
    return this->list;
}

void TagsModel::setList()
{
    emit this->preListChanged();
    this->list << this->tags();
    emit this->postListChanged();
}

FMH::MODEL TagsModel::packPlaylist(const QString &playlist)
{
    return FMH::MODEL
    {
        {FMH::MODEL_KEY::TAG, playlist},
        {FMH::MODEL_KEY::COLOR, "#333"},
        {FMH::MODEL_KEY::ICON, "tag"},
    };
}

FMH::MODEL_LIST TagsModel::tags()
{
    FMH::MODEL_LIST res;
    const auto tags = Tagging::getInstance()->getUrlsTags(false);

    return std::accumulate(tags.constBegin(), tags.constEnd(), res, [](FMH::MODEL_LIST &list, const QVariant &item)
    {
        list << FMH::toModel(item.toMap());
        return list;
    });
}

