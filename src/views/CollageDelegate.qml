import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.kirigami 2.9 as Kirigami
import org.kde.mauikit 1.2 as Maui

import org.maui.clip 1.0 as Clip

Maui.ItemDelegate
{
    id: control
    property alias list : _videoList
    property alias template : _template
    property int contentWidth: Maui.Style.iconSizes.huge
    property int contentHeight: Maui.Style.iconSizes.huge

    function randomHexColor()
    {
        var color = '#', i = 5;
        do{ color += "0123456789abcdef".substr(Math.random() * 16,1); }while(i--);
        return color;
    }

    background: Item {}

    ColumnLayout
    {
        width: control.contentWidth
        height: control.contentHeight
        anchors.centerIn: parent
        spacing: Maui.Style.space.small

        Item
        {
            id: _collageLayout
            Layout.fillWidth: true
            Layout.fillHeight: true

            Item
            {
                anchors.fill: parent

                Rectangle
                {
                    anchors.fill: parent
                    radius: 8
                    color: randomHexColor()
                    visible: _repeater.count === 0
                }

                GridLayout
                {
                    anchors.fill: parent
                    columns: 2
                    rows: 2
                    columnSpacing: 2
                    rowSpacing: 2

                    Repeater
                    {
                        id: _repeater
                        model: Maui.BaseModel
                        {
                            list: Clip.Videos
                            {
                                id: _videoList
                                autoReload: false
                                recursive: false
                                limit: 4
                            }
                        }

                        delegate: Rectangle
                        {
                            Layout.fillHeight: true
                            Layout.fillWidth: true
                            color: Qt.rgba(0,0,0,0.3)
                            Image
                            {
                                anchors.fill: parent
                                sourceSize.width: 80
                                sourceSize.height: 80
                                asynchronous: true
                                smooth: false
                                source: model.thumbnail
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                    }
                }

                layer.enabled: true
                layer.effect: OpacityMask
                {
                    cached: true
                    maskSource: Item
                    {
                        width: _collageLayout.width
                        height: _collageLayout.height

                        Rectangle
                        {
                            anchors.fill: parent
                            radius: 8
                        }
                    }
                }
            }
        }

        Item
        {
            Layout.fillWidth: true
            Layout.preferredHeight: Maui.Style.rowHeight

            Rectangle
            {
                width: parent.width
                height: parent.height
                anchors.centerIn: parent
                Behavior on color
                {
                    ColorAnimation
                    {
                        duration: Kirigami.Units.longDuration
                    }
                }

                color: control.isCurrentItem || control.hovered ? Qt.rgba(control.Kirigami.Theme.highlightColor.r, control.Kirigami.Theme.highlightColor.g, control.Kirigami.Theme.highlightColor.b, 0.2) : control.Kirigami.Theme.backgroundColor

                radius: Maui.Style.radiusV
                border.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : "transparent"
            }


            Maui.ListItemTemplate
            {
                id: _template
                isCurrentItem: control.isCurrentItem
                anchors.fill: parent
//                label1.color: control.isCurrentItem ? control.Kirigami.Theme.highlightColor : control.Kirigami.Theme.textColor

                rightLabels.visible: true
                iconSizeHint: Maui.Style.iconSizes.small
            }
        }


    }
}
