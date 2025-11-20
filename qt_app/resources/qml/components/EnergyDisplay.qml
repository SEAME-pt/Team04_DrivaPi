import QtQuick 2.15

Item {
    id: root

    property real energy: 0.0

    Text {
        id: energyNumber
        text: root.energy.toFixed(1)
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
        text: "KWH / 100KM"
        font.pixelSize: 16
        font.family: "SF Pro Display"
        font.weight: Font.Light
        color: "#8A8A8A"
        anchors.horizontalCenter: energyNumber.horizontalCenter
        anchors.top: energyNumber.bottom
        anchors.topMargin: 2
    }
}
