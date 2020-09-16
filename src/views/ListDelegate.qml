import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

Maui.ListBrowserDelegate
{
    id: control

    width: parent.width
    height: Maui.Style.rowHeight * 2
    leftPadding: Maui.Style.space.small
    rightPadding: Maui.Style.space.small
    isCurrentItem: ListView.isCurrentItem
    draggable: true
    tooltipText: model.path
    checkable: root.selectionMode
    checked: (selectionBar ? selectionBar.contains(model.path) : false)

    Drag.keys: ["text/uri-list"]
    Drag.mimeData: Drag.active ?
                       {
                           "text/uri-list": filterSelectedItems(model.path)
                       } : {}

iconSizeHint: height * 0.9
label1.text: model.label
label2.text: model.path
label3.text: model.mime
label4.text: Qt.formatDateTime(new Date(model.modified), "d MMM yyyy")
imageSource: "image://thumbnailer/"+model.path
template.fillMode: Image.PreserveAspectCrop

}
