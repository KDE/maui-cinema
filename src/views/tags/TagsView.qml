import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.cinema 1.0 as Cinema

StackView
{
    id: control
    clip: true

    property string currentTag : ""
    property Flickable flickable : currentItem.flickable


    initialItem: TagsGrid
    {
        id:  _tagsGrid
    }

    Component
    {
        id: _filterView

        Page
        {
//            title: control.currentTag
//            list.urls : ["tags:///"+currentTag]
//            list.recursive: false
//            holder.title: i18n("No Pics!")
//            holder.body: i18n("There's no pics associated with the tag")
//            holder.emojiSize: Maui.Style.iconSizes.huge
//            holder.emoji: "qrc:/img/assets/add-image.svg"
//            headBar.visible: true
//            headBar.farLeftContent: ToolButton
//            {
//                icon.name: "go-previous"
//                onClicked: control.pop()
//            }
        }
    }

    function populateGrid(myTag)
    {
        control.push(tagsGrid)
        currentTag = myTag
    }
 }
