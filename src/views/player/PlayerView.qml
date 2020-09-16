import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

SplitView
{
    id: control
    property alias url : _player.url
    property alias player : _player
    property alias playlist : _playlist

    property var currentVideo : ({})
    property int currentVideoIndex : -1

    orientation: Qt.Vertical

    onCurrentVideoChanged:
    {
        url = currentVideo.url
    }

    handle: Rectangle
    {
        implicitWidth: 6
        implicitHeight: 6
        color: SplitHandle.pressed ? Kirigami.Theme.highlightColor
                                   : (SplitHandle.hovered ? Qt.lighter(Kirigami.Theme.backgroundColor, 1.1) : Kirigami.Theme.backgroundColor)

        Rectangle
        {
            anchors.centerIn: parent
            width: 48
            height: parent.height
            color: _splitSeparator.color
        }

        Kirigami.Separator
        {
            id: _splitSeparator
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.left: parent.left
        }

        Kirigami.Separator
        {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.left: parent.left
        }
    }

    Player
    {
        id: _player
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        SplitView.minimumHeight: 250
        SplitView.preferredHeight: 500

        Maui.Holder
        {
            visible: player.stopped
            emojiSize: Maui.Style.iconSizes.huge
            emoji: "qrc:/img/assets/view-media-video.svg"
            title: qsTr("No Videos!")
            body: qsTr("Open a new video to start playing or add it to the playlist.")
        }
    }

    Playlist
    {
        id: _playlist
        SplitView.fillWidth: true
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: Math.min(500, _playlist.currentView.contentHeight)
    }

}
