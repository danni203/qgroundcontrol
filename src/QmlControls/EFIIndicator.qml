import QtQuick
import QtQuick.Layouts

import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls


//-------------------------------------------------------------------------
//-- EFI Indicator
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          efiIndicatorRow.width

    // Only show if vehicle exists and EFI group is active
    property bool showIndicator: _activeVehicle && _activeVehicle.efi && _activeVehicle.efi.telemetryAvailable

    property var _activeVehicle: QGroundControl.multiVehicleManager.activeVehicle
    property var _efi:           _activeVehicle ? _activeVehicle.efi : null

    QGCPalette { id: qgcPal }

    RowLayout {
        id:             efiIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Loader {
            Layout.fillHeight:  true
            sourceComponent:    efiVisual
            visible:            control.showIndicator
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(efiPopup, control)
    }

    //-- Standard QGC Drawer Structure
    Component {
        id: efiPopup

        ToolIndicatorPage {
            showExpand:         false // Set to true if you want a secondary "advanced" settings page
            waitForParameters:  false
            contentComponent:   efiContentComponent
        }
    }

    //-- The Toolbar Icon and Text
    Component {
        id: efiVisual

        Row {
            Layout.fillHeight:  true
            spacing:            ScreenTools.defaultFontPixelWidth / 4

            function getEngineStatus() {
                if (!_efi) return "N/A";
                var health_status = ['OFF','Stby','Ignite','Acc','Stab','NU','LO','NU','SD','NU','AutoOff','Run','AccDelay','SpdReg','TSR','PreH1','PreH2','NU','NU','FullOn'];
                // Use 'value' to get the raw integer for array indexing
                var stat_idx = _efi.health.value
                if (stat_idx < 0 || stat_idx >= health_status.length) return "Unknown";
                return health_status[stat_idx];
            }

            QGCColoredImage {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                sourceSize.width:   width
                source:             "/qmlimages/Engine.svg" // Ensure this SVG exists in your resources
                fillMode:           Image.PreserveAspectFit
                color:              qgcPal.text
            }

            QGCLabel {
                text:                   getEngineStatus()
                font.pointSize:         ScreenTools.mediumFontPointSize
                color:                  qgcPal.text
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    //-- The Content Inside the Drawer
    Component {
        id: efiContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2
            width:   ScreenTools.defaultFontPixelWidth * 30

            QGCLabel {
                text:               qsTr("EFI Status")
                font.family:        ScreenTools.demiboldFontFamily
                Layout.alignment:   Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth:   true
                height:            1
                color:             qgcPal.text
                opacity:           0.2
            }

            GridLayout {
                columns: 2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 2
                rowSpacing:    ScreenTools.defaultFontPixelHeight / 2
                Layout.fillWidth: true

                // Helper to get text
                function getEngineStatusText() {
                    if (!_efi) return "N/A";
                    var health_status = ['OFF','Stby','Ignite','Acc','Stab','NU','LO','NU','SD','NU','AutoOff','Run','AccDelay','SpdReg','TSR','PreH1','PreH2','NU','NU','FullOn'];
                    var stat_idx = _efi.health.value
                    if (stat_idx < 0 || stat_idx >= health_status.length) return "Unknown";
                    return health_status[stat_idx];
                }

                //-- Row 1: Status
                QGCLabel { text: qsTr("Status:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    text: getEngineStatusText()
                    color: qgcPal.text
                    font.bold: true
                    Layout.alignment: Qt.AlignRight
                }

                //-- Row 2: RPM
                QGCLabel { text: qsTr("RPM:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    text: _efi ? (_efi.rpm.valueString + " " + _efi.rpm.units) : "N/A"
                    color: qgcPal.text
                    Layout.alignment: Qt.AlignRight
                }

                //-- Row 3: Exhaust Gas Temp
                QGCLabel { text: qsTr("Gas Temp:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    // Matched to 'exGasTemp' in VehicleEFIFactGroup.cc
                    text: _efi ? (_efi.exGasTemp.valueString + " " + _efi.exGasTemp.units) : "N/A"
                    color: qgcPal.text
                    Layout.alignment: Qt.AlignRight
                }

                //-- Row 4: Throttle
                QGCLabel { text: qsTr("Throttle:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    // Matched to 'throttlePos' in VehicleEFIFactGroup.cc
                    text: _efi ? (_efi.throttlePos.valueString + " " + _efi.throttlePos.units) : "N/A"
                    color: qgcPal.text
                    Layout.alignment: Qt.AlignRight
                }

                //-- Row 5: Fuel Flow
                QGCLabel { text: qsTr("Fuel Flow:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    // Matched to 'fuelFlow' in VehicleEFIFactGroup.cc
                    text: _efi ? (_efi.fuelFlow.valueString + " " + _efi.fuelFlow.units) : "N/A"
                    color: qgcPal.text
                    Layout.alignment: Qt.AlignRight
                }
            }
        }
    }
}
