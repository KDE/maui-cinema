import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import QtQuick 2.10
import QtQuick.Controls 2.10
import org.kde.kirigami 2.8 as Kirigami
import QtQuick.Layouts 1.3

Maui.ApplicationWindow
{
    id: root
    height: 800
    width: height

    Maui.App.enableCSD: true

    autoHideHeader: true
    floatingHeader: true
//         headerPositioning: ListView.PullBackHeader
//         footerPositioning: ListView.PullBackFooter
    headBar.leftContent: ToolButton
    {
        icon.name: "love"
    }

    footBar.leftContent: ToolButton
    {
        icon.name: "love"
        onClicked: root.altHeader = !root.altHeader
    }

    flickable: list

    ListView
    {
        id: list
        anchors.fill: parent
        model: 20
        spacing: 20

        delegate: Rectangle
        {
            width: 100
            height: 68
            color: "orange"
        }
    }
}
