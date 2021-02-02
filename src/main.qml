import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtQuick.Window 2.13
import QtMultimedia 5.8

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.clip 1.0 as Clip

import TagsList 1.0

import "views"
import "views/player"
import "views/collection"
import "views/tags"

Maui.ApplicationWindow
{
    id: root

    floatingHeader: _appViews.currentIndex === 0 && _playerView.player.playing && (_playerView.orientation === Qt.Vertical || !_playerView.playlist.visible)
    autoHideHeader: _appViews.currentIndex === 0 && _playerView.player.playing

    property bool selectionMode : false

    readonly property var views : ({player: 0, collection: 1, tags: 2})
    property alias dialog : dialogLoader.item

    floatingFooter: true
    flickable: _appViews.currentItem ? _appViews.currentItem.flickable || null : null

    headBar.visible: root.visibility !== Window.FullScreen

    onIsPortraitChanged:
    {
        if(!isPortrait)
           toogleFullscreen()

    }

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
            text: i18n("Open")
            icon.name: "folder-open"
            onTriggered:
            {
                dialogLoader.sourceComponent= fmDialogComponent
                dialog.mode = dialog.modes.OPEN
                dialog.settings.filterType= Maui.FMList.VIDEO
                dialog.settings.onlyDirs= false
                dialog.callback = function(paths)
                {
                    Clip.Clip.openVideos(paths)
                };
                dialog.open()
            }
        }
    ]

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
            Maui.AppView.title: i18n("Player")
            Maui.AppView.iconName: "quickview"
        }

        CollectionView
        {
            id: _collectionView
            Maui.AppView.title: i18n("Collection")
            Maui.AppView.iconName: "folder-videos"
        }

        TagsView
        {
            id: _tagsView
            Maui.AppView.title: i18n("Tags")
            Maui.AppView.iconName: "tag"
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

    footBar.preferredHeight: 64
    footBar.visible:  _appViews.currentIndex !== views.player && !_playerView.player.stopped
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
            checkable: false
            autoExclusive: false

            Action
            {
                icon.name: "media-skip-backward"
                onTriggered: playPrevious()
            }

            Action
            {
                enabled: _playerView.player.video.playbackState !== MediaPlayer.StoppedState
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                icon.name: _playerView.player.video.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onTriggered: _playerView.player.video.playbackState === MediaPlayer.PlayingState ? _playerView.player.video.pause() : _playerView.player.video.play()
            }

            Action
            {
                icon.name: "media-skip-forward"
                onTriggered: playNext()
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

    Connections
    {
        target: Clip.Clip
        function onOpenUrls(urls)
        {
            for(var url of urls)
                _playerView.playlist.list.append(url)
        }
    }

    function playNext()
    {
        if(_playerView.playlist.list.count > 0)
        {
            const next = _playerView.currentVideoIndex+1 >= _playerView.playlist.list.count ? 0 : _playerView.currentVideoIndex+1

            playAt(next)
        }
    }

    function playPrevious()
    {
        if(_playerView.playlist.list.count > 0)
        {
            const previous = _playerView.currentVideoIndex-1 >= 0 ? _playerView.currentVideoIndex-1 : _playerView.playlist.list.count-1

            playAt(previous)
        }
    }

    function play(item)
    {
        queue(item)
        playAt(_playerView.playlist.list.count-1)
    }

    //Index of the video in the playlist
    function playAt(index)
    {
        if((index < _playerView.playlist.list.count) && (index > -1))
        {
//            _appViews.currentIndex = views.player
            _playerView.currentVideoIndex = index
            _playerView.currentVideo = _playerView.playlist.model.get(index)
        }
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

    function toogleFullscreen()
    {
        if(root.visibility === Window.FullScreen)
        {
            root.showNormal()
        }else
        {
            root.showFullScreen()
        }
    }

}
