import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import ".."

BrowserLayout
{
    id: control

    headBar.visible: false
    holder.emoji: "qrc:/img/assets/view-media-video.svg"
    holder.title: qsTr("No Videos!")
    holder.body: qsTr("Add videos to the playlist.")

    function append(item)
    {
        control.list.append(item.url)
    }
}

