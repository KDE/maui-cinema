import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

Kirigami.ColumnView
{
    id: control
    property alias url : _player.url
    property alias player : _player
    property var currentVideo : ({})

    columnResizeMode:  Kirigami.SingleColumn
    columnWidth: Math.min(Kirigami.Units.gridUnit * 12, control.width)

    onCurrentVideoChanged:
    {
        url = currentVideo.path
    }

    Playlist
    {
        id: _sideBar
    }

    Player
    {
        id: _player
        Kirigami.ColumnView.fillWidth: true

        Maui.Holder
        {
            visible: player.stopped
            emojiSize: Maui.Style.iconSizes.huge
            emoji: "qrc:/img/assets/view-media-video.svg"
            title: qsTr("No Videos!")
            body: qsTr("Open a new video to start playing or add it to the playlist.")
        }
    }
}
