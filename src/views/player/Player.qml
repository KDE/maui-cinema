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

    floatingFooter: player.visible
    autoHideFooter: floatingFooter

    autoHideFooterMargins: control.height

    background: Rectangle
    {
        color: player.playbackState === MediaPlayer.PlayingState ? "#333" : Kirigami.theme.backGroundColor
    }

    Maui.Doodle
    {
        id: _doodle
        sourceItem: video
    }

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

    footBar.visible: player.playbackState !== MediaPlayer.StoppedState
    footBar.leftContent:[
        ToolButton
        {
            icon.name: "view-media-playlist"
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
                icon.name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                onTriggered: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
            }

            Action
            {
                icon.name: "media-skip-forward"
            }
        }]

    footBar.rightContent: [
        Label
        {
            text: Maui.FM.formatTime((player.duration - player.position)/1000)
        },

        ToolButton
        {
            icon.name: "tool_pen"
            onClicked: _doodle.open()

        }
    ]

    footBar.middleContent : Slider
    {
        id: _slider
        enabled: control.playing || control.paused
        Layout.fillWidth: true
        orientation: Qt.Horizontal
        from: 0
        to: 1000
        value: (1000 * player.position) / player.duration

        onMoved: player.seek((_slider.value / 1000) * player.duration)
    }
}
