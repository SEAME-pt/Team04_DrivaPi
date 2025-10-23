import QtQuick 2.15

Item {
    id: root

    property int speed: 0

    Text {
        id: speedNumber
        text: Math.round(root.speed).toString()
        renderType: Text.NativeRendering
        font.pixelSize: 80
        font.family: "SF Pro Display"
        font.weight: Font.DemiBold
        color: "#FFFFFF"
        style: Text.Outline
        styleColor: "#80000000"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: -100
        layer.enabled: true
    }

    Text {
        text: "KM/H"
        font.pixelSize: 18
        font.family: "SF Pro Display"
        font.weight: Font.Light
        color: "#8A8A8A"
        anchors.horizontalCenter: speedNumber.horizontalCenter
        anchors.top: speedNumber.bottom
        anchors.topMargin: 2
    }
}
