import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import "views"
import "views/player"
import "views/collection"


Maui.ApplicationWindow
{
    id: root

    floatingHeader: _appViews.currentIndex === 0
    autoHideHeader: _appViews.currentIndex === 0 && _playerView.player.playing
    property bool selectionMode : false

    readonly property var views : ({player: 0, collection: 1, tags: 2})

    flickable: _appViews.currentItem ? _appViews.currentItem.flickable || null : null


    mainMenu: [
        Action
            {
                text: qsTr("Open")
                icon.name: "folder-open"
                onTriggered: _fileDialog.open()
            },

            Action
                {
                    text: qsTr("Settings")
                    icon.name: "folder-open"
                    onTriggered: _fileDialog.open()
                }

    ]
    Maui.FileDialog
    {
        id: _fileDialog
        mode: modes.open
        settings.filterType: Maui.FMList.VIDEO
        settings.sortBy: Maui.FMList.MODIFIED
        singleSelection : true
        onUrlsSelected:
        {
            if(urls.length > 0)
            {
                _playerView.url = urls[0]
            }
        }
    }

    Maui.AppViews
    {
        id: _appViews
        anchors.fill: parent

        PlayerView
        {
            id: _playerView
            Maui.AppView.title: qsTr("Player")
            Maui.AppView.iconName: qsTr("quickview")
            url: "file:///home/camilo/Videos/Marlene Dumas miss interpreted-veexrm7BLxQ.mp4"
        }

        CollectionView
        {
            id: _collectionView
            Maui.AppView.title: qsTr("Collection")
            Maui.AppView.iconName: qsTr("folder-videos")
        }

        Maui.Page
        {
            id: _tagsView
            Maui.AppView.title: qsTr("Tags")
            Maui.AppView.iconName: qsTr("tag")
        }
    }

    page.footerColumn: SelectionBar
    {
        id: selectionBar
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width-(Maui.Style.space.medium*2), implicitWidth)
        padding: Maui.Style.space.big
        maxListHeight: _appViews.height - Maui.Style.space.medium
    }

    footBar.preferredHeight: 100
    footBar.visible:  _appViews.currentIndex !== views.player && _playerView.player.playing
    footBar.leftContent: [
        ShaderEffectSource
        {
            Layout.fillHeight: true
            Layout.preferredWidth: height*2

            live: true
            textureSize: Qt.size(width,height)
            sourceItem: _playerView.player.video
        },

        Maui.ToolActions
        {
            expanded: true
            Action
            {
                icon.name: "media-skip-backward"
            }

            Action
            {
                icon.name: "media-playback-start"
            }

            Action
            {
                icon.name: "media-skip-forward"
            }
        },

        Maui.ListItemTemplate
        {
            Layout.fillHeight: true
            Layout.fillWidth: true
            label1.text: _playerView.currentVideo.label
            label2.text: _playerView.currentVideo.modified
        }

    ]



    function play(item)
    {
        _appViews.currentIndex = views.player
        _playerView.currentVideo = item

    }
}
