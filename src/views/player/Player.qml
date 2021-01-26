import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    property alias video : player
    property alias url : player.source
    readonly property bool playing : player.playbackState === MediaPlayer.PlayingState
    readonly property bool paused : player.playbackState === MediaPlayer.PausedState
    readonly property bool stopped : player.playbackState === MediaPlayer.StoppedState

    headBar.visible: false
    floatingFooter: player.visible && !_playlist.visible
    autoHideFooter: floatingFooter

    autoHideFooterMargins: control.height

    Kirigami.Theme.inherit: false
    Kirigami.Theme.backgroundColor: "#333"
    Kirigami.Theme.textColor: "#fafafa"
    //    Connections
    //    {
    //        target: _appViews
    //        function onCurrentIndexChanged()
    //        {
    //            if(_appViews.currentIndex !== views.player && control.playing)
    //            {
    //                player.pause()
    //            }else
    //            {
    //                player.play()
    //            }
    //        }
    //    }

    Video
    {
        id: player
        visible: !control.stopped
        anchors.fill: parent
        autoLoad: true
        autoPlay: true
        focus: true
        Keys.onSpacePressed: player.playbackState == MediaPlayer.PlayingState ? player.pause() : player.play()
        Keys.onLeftPressed: player.seek(player.position - 5000)
        Keys.onRightPressed: player.seek(player.position + 5000)

        RowLayout
        {
            anchors.fill: parent

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onDoubleClicked: player.seek(player.position - 5000)
            }

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
            }

            MouseArea
            {
                Layout.fillWidth: true
                Layout.fillHeight: true
                onDoubleClicked: player.seek(player.position + 5000)
            }
        }
    }

    footBar.visible: true

    footerColumn: [
        Maui.TagsBar
        {
            id: tagBar
            position: ToolBar.Footer
            width: parent.width
            allowEditMode: true
            onTagsEdited:
            {
                tagBar.list.updateToUrls(tags)
            }

            list.strict: true
            list.urls:  [control.url]
        },

        Maui.ToolBar
        {
            enabled: player.playbackState !== MediaPlayer.StoppedState
            position: ToolBar.Footer
            width: parent.width
            leftContent: Label
            {
                text: Maui.FM.formatTime((player.duration - player.position)/1000)
            }

            rightContent: Label
            {
                text: Maui.FM.formatTime(player.duration/1000)
            }

            middleContent:Slider
            {
                id: _slider
                enabled: control.playing || control.paused
                Layout.fillWidth: true
                implicitWidth: 0
                orientation: Qt.Horizontal
                from: 0
                to: 1000
                value: (1000 * player.position) / player.duration

                onMoved: player.seek((_slider.value / 1000) * player.duration)
            }
        }
    ]
    footBar.leftContent: ToolButton
    {
        visible: !Kirigami.Settings.isMobile
        icon.name: "view-fullscreen"
        onClicked: toogleFullscreen()
        checked: fullScreen
    }

    footBar.rightContent: [
        ToolButton
        {
            icon.name: "view-split-top-bottom"
            checked: _playlist.visible
            onClicked: _playlist.visible = !_playlist.visible
        },

        Maui.Badge
        {
            text: _playlist.list.count
        }
    ]

    footBar.middleContent:[

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
                enabled: player.playbackState !== MediaPlayer.StoppedState
                icon.width: Maui.Style.iconSizes.big
                icon.height: Maui.Style.iconSizes.big
                icon.name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onTriggered: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
            }

            Action
            {
                icon.name: "media-skip-forward"
                onTriggered: playNext()
            }
        }]
}
