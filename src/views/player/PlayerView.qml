import QtQuick 2.10
import QtQuick.Controls 2.10

Item
{
    id: control
    property alias url : _player.url

    Player
    {
        id: _player
        anchors.fill: parent
    }
}
