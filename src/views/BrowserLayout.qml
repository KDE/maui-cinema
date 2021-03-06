import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.clip 1.0 as Clip

Maui.AltBrowser
{
    id: control
    property alias list : _collectionList
    property alias listModel : _collectionModel

    signal itemClicked(var item)
    signal itemRightClicked(var item)

    gridView.itemSize: 180

    enableLassoSelection: true

    holder.visible: _collectionList.count === 0
    holder.emojiSize: Maui.Style.iconSizes.huge

    viewType: control.width < Kirigami.Units.gridUnit * 30 ? Maui.AltBrowser.ViewType.List : Maui.AltBrowser.ViewType.Grid

    //    Binding on viewType
//    {
//        value: control.width < Kirigami.Units.gridUnit * 30 ? Maui.AltBrowser.ViewType.List : Maui.AltBrowser.ViewType.Grid
//        restoreMode: Binding.RestoreBinding
//    }

    Connections
    {
        target: control.currentView
        ignoreUnknownSignals: true

        function onItemsSelected(indexes)
        {
            for(var i in indexes)
                selectionBar.insert(_collectionModel.get(indexes[i]))
        }

        function onKeyPress(event)
        {
            const index = control.currentIndex
            const item = control.model.get(index)

            if((event.key == Qt.Key_Left || event.key == Qt.Key_Right || event.key == Qt.Key_Down || event.key == Qt.Key_Up) && (event.modifiers & Qt.ControlModifier) && (event.modifiers & Qt.ShiftModifier))
            {
                control.currentView.itemsSelected([index])
            }

            //            if(event.key === Qt.Key_Space)
            //            {
            //                getFileInfo(item.url)
            //            }
        }
    }

    ItemMenu
    {
        id: _menu
        index: control.currentIndex
        model: control.model
    }

    headBar.middleContent: Maui.TextField
    {
        enabled: _collectionList.count > 0
        Layout.fillWidth: true
        placeholderText: i18n("Search") + " " + _collectionList.count + " videos"
        onAccepted: _collectionModel.filter = text
        onCleared: _collectionModel.filter = ""
    }

    headBar.leftContent: Maui.ToolActions
    {
        autoExclusive: true
        expanded: isWide
        currentIndex : control.viewType === Maui.AltBrowser.ViewType.List ? 0 : 1
        enabled: _collectionList.count > 0
        display: ToolButton.TextBesideIcon
        cyclic: true

        Action
        {
            text: i18n("List")
            icon.name: "view-list-details"
            onTriggered: control.viewType = Maui.AltBrowser.ViewType.List
        }

        Action
        {
            text: i18n("Grid")
            icon.name: "view-list-icons"
            onTriggered: control.viewType= Maui.AltBrowser.ViewType.Grid
        }
    }


    model: Maui.BaseModel
    {
        id: _collectionModel
        sortOrder: Qt.DescendingOrder
        sort: "modified"
        recursiveFilteringEnabled: true
        sortCaseSensitivity: Qt.CaseInsensitive
        filterCaseSensitivity: Qt.CaseInsensitive
        list: Clip.Videos
        {
            id: _collectionList
        }
    }

    listDelegate: ListDelegate
    {
        id: _listDelegate
        width: ListView.view.width

        onToggled:
        {
            control.currentIndex = index
            control.currentView.itemsSelected([index])
        }

        onClicked:
        {
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
                control.itemClicked(model)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                control.itemClicked(model)
            }
        }

        onPressAndHold:
        {
            if(!Maui.Handy.isTouch)
                return

            control.currentIndex = index
            control.itemRightClicked(index)
            _menu.popup()
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(index)
            _menu.popup()
        }

        Connections
        {
            target: selectionBar

            function onUriRemoved(uri)
            {
                if(uri === model.path)
                    _listDelegate.checked = false
            }

            function onUriAdded(uri)
            {
                if(uri === model.path)
                    _listDelegate.checked = true
            }

            function onCleared(uri)
            {
                _listDelegate.checked = false
            }
        }
    }

gridDelegate: Item
{
    property bool isCurrentItem : GridView.isCurrentItem
    height: control.gridView.cellHeight
    width: control.gridView.cellWidth

    Maui.GridBrowserDelegate
    {
        id: delegate

        iconSizeHint: height * 0.6
        label1.text: model.label
        imageSource: "image://thumbnailer/"+model.path
        template.imageHeight: height
        template.imageWidth: width
        template.fillMode: Image.PreserveAspectFit

        anchors.centerIn: parent
        height: control.gridView.cellHeight - 15
        width: control.gridView.itemSize - 20
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
            control.currentIndex = index
            if(selectionMode || (mouse.button == Qt.LeftButton && (mouse.modifiers & Qt.ControlModifier)))
            {
                control.currentView.itemsSelected([index])
            }else if(Maui.Handy.singleClick)
            {
               control.itemClicked(model)
            }
        }

        onDoubleClicked:
        {
            control.currentIndex = index
            if(!Maui.Handy.singleClick && !selectionMode)
            {
                control.itemClicked(model)
            }
        }

        onPressAndHold:
        {
            if(!Maui.Handy.isTouch)
            return

            control.currentIndex = index
            control.itemRightClicked(model)
            _menu.popup()
        }

        onRightClicked:
        {
            control.currentIndex = index
            control.itemRightClicked(model)
            _menu.popup()
        }

        onToggled:
        {
            control.currentIndex = index
            control.currentView.itemsSelected([index])
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
