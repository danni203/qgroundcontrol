import QtQuick
import QtQuick.Layouts
import Qt.labs.settings 1.0
import QGroundControl
import QGroundControl.Controls
import QGroundControl.FactControls

//-------------------------------------------------------------------------
//-- Flap Indicator
Item {
    id:             control
    anchors.top:    parent.top
    anchors.bottom: parent.bottom
    width:          flapIndicatorRow.width


    // Configuration
    property var    _activeVehicle:     QGroundControl.multiVehicleManager.activeVehicle
    property var    _settingsManager:           QGroundControl.settingsManager
    property var    _appSettings:               _settingsManager.appSettings

    property bool   showIndicator:      _activeVehicle && _appSettings.showEFIIndicator.visible// && _activeVehicle.rcFlap !== undefined

    // Data access
    property int    _rcFlapValue:       _activeVehicle ? _activeVehicle.rcFlap : 1500

    Settings {
            id: flapSettings
            category: "FlapIndicator"
            property alias flapUpThreshold:   control._flapUpThreshold
            property alias flapDownThreshold: control._flapDownThreshold
            property alias flapMinPWM:        control._flapMinPWM
            property alias flapMaxPWM:        control._flapMaxPWM
        }
    // Thresholds
    property int _flapUpThreshold:   2000
    property int _flapDownThreshold: 1000
    readonly property int _flapMinPWM:        1000
    readonly property int _flapMaxPWM:        2000

    QGCPalette { id: qgcPal }

    RowLayout {
        id:             flapIndicatorRow
        anchors.top:    parent.top
        anchors.bottom: parent.bottom
        spacing:        ScreenTools.defaultFontPixelWidth / 2

        Loader {
            Layout.fillHeight:  true
            sourceComponent:    flapVisual
            visible:            control.showIndicator
        }
    }

    MouseArea {
        anchors.fill:   parent
        onClicked:      mainWindow.showIndicatorDrawer(flapPopup, control)
    }


    Component {
        id: flapPopup

        ToolIndicatorPage {
            showExpand:         false
            waitForParameters:  false
            contentComponent:   flapContentComponent
        }
    }


    Component {
        id: flapVisual

        Row {
            Layout.fillHeight:  true
            spacing:            ScreenTools.defaultFontPixelWidth / 4

            // Helper functions for the toolbar visual
            function getFlapStatus() {
                if (!_activeVehicle) return "N/A";
                if (_rcFlapValue === flapSettings.flapUpThreshold) return "FLAT";
                if (_rcFlapValue === flapSettings.flapDownThreshold) return "DOWN";
                return "MID";
            }

            function getFlapColor() {
                if (!_activeVehicle) return qgcPal.colorGrey;
                if (_rcFlapValue === flapSettings.flapUpThreshold) return qgcPal.colorGreen;
                if (_rcFlapValue === flapSettings.flapDownThreshold) return qgcPal.colorOrange;
                return qgcPal.colorBlue;
            }

            QGCColoredImage {
                anchors.top:        parent.top
                anchors.bottom:     parent.bottom
                width:              height
                sourceSize.width:   width
                source:             "/qmlimages/Flap.svg"
                fillMode:           Image.PreserveAspectFit
                color:              getFlapColor()

                // Keep the color animation from your original code
                Behavior on color { ColorAnimation { duration: 250 } }
            }

            QGCLabel {
                text:                   getFlapStatus()
                font.pointSize:         ScreenTools.mediumFontPointSize
                color:                  qgcPal.text
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }


    Component {
        id: flapContentComponent

        ColumnLayout {
            spacing: ScreenTools.defaultFontPixelHeight / 2
            width:   ScreenTools.defaultFontPixelWidth * 30
            Rectangle {
                            Layout.fillWidth:   true
                            height:             1
                            color:              qgcPal.text
                            opacity:            0.2
                        }

                        QGCLabel {
                            text:               qsTr("Configuration (PWM)")
                            font.family:        ScreenTools.demiboldFontFamily
                            Layout.alignment:   Qt.AlignHCenter
                        }

                        GridLayout {
                            columns:       2
                            columnSpacing: ScreenTools.defaultFontPixelWidth
                            rowSpacing:    ScreenTools.defaultFontPixelHeight / 2
                            Layout.fillWidth: true

                            // -- UP Threshold Input
                            QGCLabel {
                                text: qsTr("Up:")
                                color: qgcPal.text
                            }
                            QGCTextField {
                                text:               control._flapUpThreshold.toString()
                                Layout.fillWidth:   true
                                inputMethodHints:   Qt.ImhDigitsOnly
                                // Update property when user finishes typing
                                onEditingFinished:  flapSettings.flapUpThreshold = parseInt(text)
                            }

                            // -- DOWN Threshold Input
                            QGCLabel {
                                text: qsTr("Down:")
                                color: qgcPal.text
                            }
                            QGCTextField {
                                text:               control._flapDownThreshold.toString()
                                Layout.fillWidth:   true
                                inputMethodHints:   Qt.ImhDigitsOnly
                                onEditingFinished:  flapSettings.flapDownThreshold= parseInt(text)
                            }

                            // -- Min PWM Input
                           // QGCLabel {
                               // text: qsTr("Min PWM:")
                               // color: qgcPal.text
                           // }
                          //  QGCTextField {
                               // text:               control._flapMinPWM.toString()
                               // Layout.fillWidth:   true
                              //  inputMethodHints:   Qt.ImhDigitsOnly
                              //  onEditingFinished:  control._flapMinPWM = parseInt(text)
                          //  }

                            // -- Max PWM Input
                           // QGCLabel {
                            //    text: qsTr("Max PWM:")
                               // color: qgcPal.text
                          //  }
                          //  QGCTextField {
                               // text:               control._flapMaxPWM.toString()
                              //  Layout.fillWidth:   true
                              //  inputMethodHints:   Qt.ImhDigitsOnly
                               // onEditingFinished:  control._flapMaxPWM = parseInt(text)
                           // }
                        }
            QGCLabel {
                text:               qsTr("Flap Status")
                font.family:        ScreenTools.demiboldFontFamily
                Layout.alignment:   Qt.AlignHCenter
            }

            Rectangle {
                Layout.fillWidth:   true
                height:             1
                color:              qgcPal.text
                opacity:            0.2
            }

            GridLayout {
                columns:       2
                columnSpacing: ScreenTools.defaultFontPixelWidth * 2
                rowSpacing:    ScreenTools.defaultFontPixelHeight / 2
                Layout.fillWidth: true

                // Logic helpers for the drawer
                function getFlapText() {
                    if (_rcFlapValue >= _flapUpThreshold) return "FLAT";
                    if (_rcFlapValue <= _flapDownThreshold) return "DOWN";
                    return "MID";
                }

                function getFlapPercentage() {
                    var percentage = ((_rcFlapValue - _flapMinPWM) / (_flapMaxPWM - _flapMinPWM)) * 100;
                    return Math.max(0, Math.min(100, Math.round(percentage)));
                }

                //-- Row 1: Position Status
                QGCLabel { text: qsTr("Position:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    text:               _activeVehicle ? getFlapText() : "N/A"
                    color:              qgcPal.text
                    font.bold:          true
                    Layout.alignment:   Qt.AlignRight
                }

                //-- Row 2: Percentage
                QGCLabel { text: qsTr("Percentage:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    text:               _activeVehicle ? getFlapPercentage() + "%" : "N/A"
                    color:              qgcPal.text
                    Layout.alignment:   Qt.AlignRight
                }

                //-- Row 3: PWM Value
                QGCLabel { text: qsTr("PWM Value:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    text:               _activeVehicle ? _rcFlapValue : "N/A"
                    color:              qgcPal.text
                    Layout.alignment:   Qt.AlignRight
                }

                //-- Row 4: Range Config
                QGCLabel { text: qsTr("Range:"); color: qgcPal.text; Layout.alignment: Qt.AlignLeft }
                QGCLabel {
                    text:               _flapMinPWM + " - " + _flapMaxPWM
                    color:              qgcPal.text
                    Layout.alignment:   Qt.AlignRight
                }
            }
        }
    }
}
