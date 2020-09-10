import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.cinema 1.0 as Cinema

Maui.Page
{
    id: control
    flickable: _gridView.flickable

    Maui.GridView
    {
        id: _gridView
        margins: Maui.Style.space.medium
        anchors.fill: parent
        itemSize: 180
        enableLassoSelection: true
        onItemsSelected:
        {
            for(var i in indexes)
                selectionBar.insert(model.get(indexes[i]))
        }

        model: Maui.BaseModel
        {
            id: _collectionModel
            list: Cinema.Videos
            {
                id: _collectionList
                urls: Cinema.Cinema.sources
            }
        }

        delegate: Item
        {
            property bool isCurrentItem : GridView.isCurrentItem
            height: _gridView.cellHeight
            width: _gridView.cellWidth

            Maui.GridBrowserDelegate
            {
                id: delegate

                iconSizeHint: height * 0.6
                label1.text: model.label
                imageSource: "image://thumbnailer/"+model.path
                template.imageHeight: height
                template.imageWidth: height
                template.fillMode: Image.PreserveAspectCrop

                anchors.centerIn: parent
                height: _gridView.cellHeight - 15
                width: _gridView.itemSize - 20
                padding: Maui.Style.space.tiny
                isCurrentItem: parent.isCurrentItem
                tooltipText: model.path
                checkable: root.selectionMode
                checked: (selectionBar ? selectionBar.contains(model.path) : false)
                draggable: true
                opacity: model.hidden == "true" ? 0.5 : 1

                Drag.keys: ["text/uri-list"]
                Drag.mimeData: Drag.active ?
                                   {
                                       "text/uri-list": control.filterSelectedItems(model.path)
                                   } : {}

            onClicked:
            {
                _gridView.currentIndex = index

                if ((mouse.button == Qt.LeftButton) && (mouse.modifiers & Qt.ControlModifier))
                {
                    _gridView.itemsSelected([index])
                }else
                {
                    play(model)
                }
            }

            onDoubleClicked:
            {
                _gridView.currentIndex = index
                _gridView.itemDoubleClicked(index)
            }

            onPressAndHold:
            {
                if(!Maui.Handy.isTouch)
                    return

                _gridView.currentIndex = index
                _gridView.itemRightClicked(index)
            }

            onRightClicked:
            {
                _gridView.currentIndex = index
                _gridView.itemRightClicked(index)
            }

            onToggled:
            {
                _gridView.currentIndex = index
                _gridView.itemToggled(index, state)
            }

            onContentDropped:
            {
                //                _dropMenu.urls = drop.urls.join(",")
                //                _dropMenu.target = model.path
                //                _dropMenu.popup()
            }

            Connections
            {
                target: selectionBar

                function onUriRemoved(uri)
                {
                    if(uri === model.path)
                        delegate.checked = false
                }

                function onUriAdded(uri)
                {
                    if(uri === model.path)
                        delegate.checked = true
                }

                function onCleared(uri)
                {
                    delegate.checked = false
                }
            }
        }
    }
}

function filterSelectedItems(path)
{
    if(selectionBar && selectionBar.count > 0 && selectionBar.contains(path))
    {
        const uris = selectionBox.uris
        return uris.join("\n")
    }

    return path
}

}
