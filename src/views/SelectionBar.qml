import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3
import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.6 as Kirigami

Maui.SelectionBar
{
    id: control

    visible: count > 0 && _appViews.currentIndex !== views.player
    onExitClicked:
    {
        selectionMode = false
        clear()
    }

    listDelegate: Maui.ItemDelegate
    {
        Kirigami.Theme.inherit: true
        height: Maui.Style.toolBarHeight
        width: ListView.view.width

        background: Item {}

        Maui.ListItemTemplate
        {
            id: _template
            anchors.fill: parent
            label1.text: model.label
            label2.text: model.path
            imageSource: "image://thumbnailer/"+model.path
            iconSizeHint: height * 0.9
            checkable: true
            checked: true
            onToggled: control.removeAtIndex(index)
        }
    }

    Action
    {
        text: i18n("Play")
        icon.name: "media-playback-start"
        onTriggered:
        {
            playItems(control.items, 0)
            control.clear()
        }
    }

    Action
    {
        text: i18n("Queue")
        icon.name: "media-playlist-play"
        onTriggered:
        {
            queueItems(control.items, 0)
            control.clear()
        }
    }

    Action
    {
        text: i18n("Un/Fav")
        icon.name: "love"
        onTriggered: VIEWER.fav(control.uris)
    }

    Action
    {
        text: i18n("Tag")
        icon.name: "tag"
        onTriggered:
        {
            dialogLoader.sourceComponent = tagsDialogComponent
            dialog.composerList.urls = control.uris
            dialog.open()
        }
    }

    Action
    {
        text: i18n("Share")
        icon.name: "document-share"
        onTriggered:
        {
            dialogLoader.sourceComponent = shareDialogComponent
            dialog.urls= control.uris
            dialog.open()
        }
    }

    Action
    {
        text: i18n("Export")
        icon.name: "document-save"
        onTriggered:
        {
            const pics = control.uris
            dialogLoader.sourceComponent= fmDialogComponent
            dialog.show(function(paths)
            {
                for(var i in paths)
                    Maui.FM.copy(pics, paths[i])
            });
        }
    }

    Action
    {
        text: i18n("Remove")
        icon.name: "edit-delete"
        Kirigami.Theme.textColor: Kirigami.Theme.negativeTextColor
        onTriggered:
        {
            removeDialog.open()
        }
    }

    function insert(item)
    {
        if(control.contains(item.path))
        {
            control.removeAtUri(item.path)
            return
        }

        control.append(item.path, item)
    }
}

