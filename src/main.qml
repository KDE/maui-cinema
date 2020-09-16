import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import TagsList 1.0

import "views"
import "views/player"
import "views/collection"
import "views/tags"

Maui.ApplicationWindow
{
    id: root

    floatingHeader: autoHideHeader
    autoHideHeader: _appViews.currentIndex === 0 && _playerView.player.playing
    property bool selectionMode : false

    readonly property var views : ({player: 0, collection: 1, tags: 2})
    property alias dialog : dialogLoader.item

    flickable: _appViews.currentItem ? _appViews.currentItem.flickable || null : null

    /***MODELS****/
    Maui.BaseModel
    {
        id: tagsModel
        list: TagsList
        {
            id: tagsList
        }
    }

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
            //            onTriggered: _fileDialog.open()
        }
    ]

    //    Maui.FileDialog
    //    {
    //        id: _fileDialog
    //        mode: modes.open
    //        settings.filterType: Maui.FMList.VIDEO
    //        settings.sortBy: Maui.FMList.MODIFIED
    //        singleSelection : true
    //        onUrlsSelected:
    //        {
    //            if(urls.length > 0)
    //            {
    //                _playerView.url = urls[0]
    //            }
    //        }
    //    }

    DropArea
    {
        id: _dropArea
        anchors.fill: parent
        onDropped:
        {
            if(drop.urls)
            {
                VIEWER.openExternalPics(drop.urls, 0)
            }
        }

        onExited:
        {
            if(swipeView.currentIndex === views.viewer)
            {
                swipeView.goBack()
            }
        }

        onEntered:
        {
            if(drag.source)
            {
                return
            }

            swipeView.currentIndex = views.viewer
        }
    }

    Component
    {
        id: shareDialogComponent
        Maui.ShareDialog {}
    }

    Component
    {
        id: tagsDialogComponent
        Maui.TagsDialog
        {
            onTagsReady: composerList.updateToUrls(tags)
            composerList.strict: false
        }
    }

    Component
    {
        id: fmDialogComponent
        Maui.FileDialog
        {
            mode: modes.SAVE
            settings.filterType: Maui.FMList.IMAGE
            settings.onlyDirs: false
        }
    }

    //    Component
    //    {
    //        id: _settingsDialogComponent
    //        SettingsDialog {}
    //    }

    Maui.Dialog
    {
        id: removeDialog

        title: i18n("Delete files?")
        acceptButton.text: i18n("Accept")
        rejectButton.text: i18n("Cancel")
        message: i18n("Are sure you want to delete %1 files", String(selectionBar.count))
        page.margins: Maui.Style.space.big
        template.iconSource: "emblem-warning"
        onRejected: close()
        onAccepted:
        {
            for(var url of selectionBox.uris)
                Maui.FM.removeFile(url)
            selectionBox.clear()
            close()
        }
    }

    Loader { id: dialogLoader }

    Maui.AppViews
    {
        id: _appViews
        anchors.fill: parent

        PlayerView
        {
            id: _playerView
            Maui.AppView.title: qsTr("Player")
            Maui.AppView.iconName: qsTr("quickview")
        }

        CollectionView
        {
            id: _collectionView
            Maui.AppView.title: qsTr("Collection")
            Maui.AppView.iconName: qsTr("folder-videos")
        }

        TagsView
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
    footBar.middleContent: [

        ShaderEffectSource
        {
            Layout.fillHeight: true
            Layout.preferredWidth: sourceItem.width * (height /  sourceItem.height)
            hideSource: visible
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
            //            Layout.preferredWidth: 500
            label1.text: _playerView.currentVideo.label
            label2.text: _playerView.currentVideo.path
        }
    ]

    function play(item)
    {
        queue(item)
        playAt(_playerView.playlist.list.count-1)
    }

    //Index of the video in the playlist
    function playAt(index)
    {
        _appViews.currentIndex = views.player
        _playerView.currentVideoIndex = index
        _playerView.currentVideo = _playerView.playlist.model.get(index)
    }

    function playItems(items)
    {
        _playerView.playlist.list.clear()
        for(var item of items)
        {
            queue(item)
        }
        playAt(0)
    }

    function queueItems(items)
    {
        for(var item of items)
        {
            queue(item)
        }
    }

    function queue(item)
    {
        _playerView.playlist.append(item)
    }
}
