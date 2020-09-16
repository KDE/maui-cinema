import QtQuick 2.14
import QtQml 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.mauikit 1.2 as Maui
import org.kde.kirigami 2.8 as Kirigami

import org.maui.cinema 1.0 as Cinema

import ".."

BrowserLayout
{
    id: control

    list.urls: Cinema.Cinema.sources

    onItemClicked:
    {
        play(item)
    }

}
