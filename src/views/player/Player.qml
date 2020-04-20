import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtMultimedia 5.8
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.kde.kirigami 2.7 as Kirigami

Maui.Page
{
    id: control
    property alias video : player
    property alias url : player.source
    floatingFooter: true
    autoHideFooter: true
    autoHideFooterMargins: control.height

    MauiLab.Doodle
    {
        id: _doodle
        sourceItem: video
    }

    Video
    {
        id: player
        anchors.fill: parent
        source: control.url
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

    footBar.leftContent: ToolButton
    {
        icon.name: player.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
        onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
    }

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
        Layout.fillWidth: true
        orientation: Qt.Horizontal
        from: 0
        to: 1000
        value: (1000 * player.position) / player.duration

        onMoved: player.seek((_slider.value / 1000) * player.duration)
    }
}
