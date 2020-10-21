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

    orientation: control.width > 750 ? Qt.Horizontal : Qt.Vertical

    onCurrentVideoChanged:
    {
        url = currentVideo.url
    }

    Component
    {
        id: _verticalHandle

        Maui.Separator
        {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            position: Qt.Vertical
        }
    }

    Component
    {
        id: _horizontalHandle

        Item
        {
            implicitHeight: Maui.Handy.isTouch ? 10 : 6
            implicitWidth: implicitHeight

            Maui.Separator
            {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                position: Qt.Horizontal
            }
        }

    }

    handle: orientation == Qt.Horizontal ? _verticalHandle : _horizontalHandle

    Player
    {
        id: _player
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        SplitView.minimumWidth: control.orientation === Qt.Horizontal ? 500 : 0
        SplitView.preferredWidth: control.orientation === Qt.Horizontal ? 200 : width

        SplitView.minimumHeight: control.orientation === Qt.Vertical ? control.height * 0.5 : 0
        SplitView.preferredHeight: control.orientation === Qt.vertical ? 500 : height

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
        visible: list.count > 0
        SplitView.fillWidth: true

        SplitView.minimumHeight: control.orientation === Qt.Vertical ? 100 : 0
        SplitView.preferredHeight: control.orientation === Qt.vertical ?  Math.min(500, _playlist.currentView.contentHeight) : height

        SplitView.maximumWidth: control.orientation === Qt.Horizontal ? 250 : width
        SplitView.minimumWidth: control.orientation === Qt.Horizontal ? 250 : 0
        SplitView.preferredWidth: control.orientation === Qt.Horizontal ? 250 : width
    }

}
