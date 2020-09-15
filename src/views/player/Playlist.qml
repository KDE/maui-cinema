import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

Maui.Page
{
    id: _sideBar

    Maui.Holder
    {
        visible: player.stopped
        emojiSize: Maui.Style.iconSizes.huge
        emoji: "qrc:/img/assets/view-media-video.svg"
        title: qsTr("No Videos!")
        body: qsTr("Add videos to the playlist.")
    }
}
