import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14
import org.kde.kirigami 2.2 as Kirigami
import org.kde.mauikit 1.2 as Maui
import org.maui.cinema 1.0 as Cinema

import ".."

StackView
{
    id: control
    clip: true

    property string currentTag : ""
    property Flickable flickable : currentItem.flickable

    Maui.NewDialog
    {
        id: newTagDialog
        title: i18n("New tag")
        message: i18n("Create a new tag to organize your collection")
        acceptButton.text : i18n("Add")
        onFinished:
        {
            tagsList.insert(text)
        }

        onRejected: close()
    }

    initialItem: TagsGrid
    {
        id:  _tagsGrid
    }

    Component
    {
        id: _filterViewComponent

        BrowserLayout
        {

            title: control.currentTag
            list.urls : ["tags:///"+currentTag]
            list.recursive: false
            holder.title: i18n("No Videos!")
            holder.body: i18n("There's no videos associated with the tag")
            headBar.visible: true
            headBar.farLeftContent: ToolButton
            {
                icon.name: "go-previous"
                onClicked: control.pop()
            }
        }
    }

    function populateGrid(myTag)
    {
        control.push(_filterViewComponent)
        currentTag = myTag
    }
}
