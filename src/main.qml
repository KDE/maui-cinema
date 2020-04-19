import QtQuick 2.13
import QtQuick.Controls 2.13

import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kirigami 2.8 as Kirigami

import "views/player"

Maui.ApplicationWindow
{
    id: root

    Maui.App.enableCSD: true
    floatingHeader: _appViews.currentIndex === 0
    floatingFooter: _appViews.currentIndex === 0
    autoHideHeader: _appViews.currentIndex === 0

    MauiLab.AppViews
    {
        id: _appViews
        anchors.fill: parent

        PlayerView
        {
            id: _playerView
            MauiLab.AppView.title: qsTr("Player")
            MauiLab.AppView.iconName: qsTr("quickview")
            url: "file:///home/camilo/Videos/Marlene Dumas miss interpreted-veexrm7BLxQ.mp4"
        }

        Maui.Page
        {
            id: _collectionView
            MauiLab.AppView.title: qsTr("Collection")
            MauiLab.AppView.iconName: qsTr("folder-videos")
        }

        Maui.Page
        {
            id: _tagsView
            MauiLab.AppView.title: qsTr("Tags")
            MauiLab.AppView.iconName: qsTr("tag")
        }
    }
}
