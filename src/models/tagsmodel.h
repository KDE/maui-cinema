#ifndef TAGSMODEL_H
#define TAGSMODEL_H

#ifdef STATIC_MAUIKIT
#include "fmh.h"
#include "mauilist.h"
#else
#include <MauiKit/fmh.h>
#include <MauiKit/mauilist.h>
#endif

class TagsModel : public MauiList
{
    Q_OBJECT

public:
    explicit TagsModel(QObject *parent = nullptr);
    FMH::MODEL_LIST items() const override;
    void componentComplete() override;

private:
    FMH::MODEL_LIST list;
    void setList();

    FMH::MODEL_LIST tags();
    static FMH::MODEL packPlaylist(const QString &playlist);
};

#endif // TAGSMODEL_H
