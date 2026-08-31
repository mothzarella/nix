import QtQuick
import org.kde.layershell as LayerShell
import org.kde.taskmanager as TaskManager
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kirigami as Kirigami

Window {
    id: bar

    readonly property color foreground: "@foreground@"
    readonly property color dim: "@dim@"
    readonly property color accent: "@accent@"
    readonly property color hover: "@hover@"

    readonly property int barHeight: 34
    readonly property int taskWidth: 190

    width: 1920
    height: barHeight
    visible: true
    color: "transparent"

    LayerShell.Window.scope: "dock"
    LayerShell.Window.layer: LayerShell.Window.LayerTop
    LayerShell.Window.anchors: LayerShell.Window.AnchorLeft
        | LayerShell.Window.AnchorRight
        | LayerShell.Window.AnchorBottom
    LayerShell.Window.exclusionZone: bar.barHeight
    LayerShell.Window.keyboardInteractivity: LayerShell.Window.KeyboardInteractivityNone

    TaskManager.VirtualDesktopInfo {
        id: desktops
    }

    TaskManager.TasksModel {
        id: tasks

        virtualDesktop: desktops.currentDesktop
        filterByVirtualDesktop: true
        groupMode: TaskManager.TasksModel.GroupDisabled
        sortMode: TaskManager.TasksModel.SortVirtualDesktop
    }

    Plasma5Support.DataSource {
        id: shell

        engine: "executable"

        onNewData: (source, data) => disconnectSource(source)

        function run(command) {
            disconnectSource(command);
            connectSource(command);
        }
    }

    function activateDesktop(id) {
        shell.run("@busctl@ --user set-property org.kde.KWin /VirtualDesktopManager"
            + " org.kde.KWin.VirtualDesktopManager current s " + "\"" + id + "\"");
    }

    Item {
        anchors.fill: parent

        // -------------------------------------------------------------- sheen
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#00000000" }
                GradientStop { position: 0.5; color: "#0a000000" }
                GradientStop { position: 1.0; color: "#28000000" }
            }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: Math.round(bar.barHeight / 2)
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#4dffffff" }
                GradientStop { position: 0.3; color: "#24ffffff" }
                GradientStop { position: 1.0; color: "#00ffffff" }
            }
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top }
            height: 1
            color: "#a6ffffff"
        }

        Rectangle {
            anchors { left: parent.left; right: parent.right; top: parent.top; topMargin: 1 }
            height: 1
            color: "#28ffffff"
        }

        // ----------------------------------------------------------- desktops
        Grid {
            id: pager

            anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
            rows: Math.max(desktops.desktopLayoutRows, 1)
            columns: Math.max(Math.ceil(desktops.numberOfDesktops / rows), 1)
            spacing: 2

            Repeater {
                model: desktops.desktopIds

                Rectangle {
                    id: pip

                    required property var modelData

                    readonly property bool current: modelData === desktops.currentDesktop

                    width: 8
                    height: 8
                    radius: 1
                    color: current ? bar.accent
                        : pipPointer.containsMouse ? "#4dffffff"
                        : "#26ffffff"
                    border.color: current ? Qt.darker(bar.accent, 1.3)
                        : pipPointer.containsMouse ? bar.hover
                        : "#66ffffff"
                    border.width: 1

                    Rectangle {
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
                        height: 3
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#59ffffff" }
                            GradientStop { position: 1.0; color: "#00ffffff" }
                        }
                    }

                    MouseArea {
                        id: pipPointer

                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: bar.activateDesktop(pip.modelData)
                    }
                }
            }
        }

        // ------------------------------------------------------------ windows
        ListView {
            id: windows

            anchors {
                left: pager.right
                leftMargin: 10
                right: parent.right
                rightMargin: 6
                top: parent.top
                topMargin: 4
                bottom: parent.bottom
                bottomMargin: 3
            }
            orientation: ListView.Horizontal
            spacing: 3
            clip: true
            model: tasks

            delegate: Rectangle {
                id: task

                readonly property bool active: model.IsActive
                readonly property bool hovered: pointer.containsMouse

                width: Math.max(28, Math.min(bar.taskWidth,
                    (windows.width - (tasks.count - 1) * windows.spacing) / Math.max(tasks.count, 1)))
                height: windows.height

                radius: 3

                color: task.active ? "#4dffffff"
                    : task.hovered ? "#2effffff"
                    : "#12ffffff"
                border.color: task.active ? "#b3ffffff"
                    : task.hovered ? bar.hover
                    : "#38ffffff"
                border.width: 1

                Rectangle {
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
                    height: Math.round((task.height - 2) / 2)
                    topLeftRadius: task.radius - 1
                    topRightRadius: task.radius - 1
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: task.active ? "#4dffffff" : "#2effffff" }
                        GradientStop { position: 1.0; color: "#00ffffff" }
                    }
                }

                Rectangle {
                    anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 1 }
                    height: Math.round((task.height - 2) / 3)
                    bottomLeftRadius: task.radius - 1
                    bottomRightRadius: task.radius - 1
                    visible: task.active || task.hovered
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#00ffffff" }
                        GradientStop { position: 1.0; color: task.active ? "#2effffff" : "#1affffff" }
                    }
                }

                Rectangle {
                    anchors { fill: parent; margins: 1 }
                    radius: parent.radius - 1
                    color: "transparent"
                    border.color: task.active ? "#4cffffff" : "#1affffff"
                    border.width: 1
                }

                Row {
                    anchors { fill: parent; leftMargin: 5; rightMargin: 5 }
                    spacing: 5

                    Kirigami.Icon {
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.decoration
                        width: 16
                        height: 16
                        opacity: model.IsMinimized ? 0.5 : 1.0
                    }

                    Item {
                        anchors.verticalCenter: parent.verticalCenter
                        width: task.width - 31
                        height: label.contentHeight
                        visible: width > 0

                        Text {
                            y: 1
                            width: parent.width
                            text: label.text
                            font: label.font
                            color: "#66ffffff"
                            elide: Text.ElideRight
                        }

                        Text {
                            id: label

                            width: parent.width
                            text: model.display
                            color: model.IsMinimized ? bar.dim : bar.foreground
                            font.family: "@fontFamily@"
                            font.pixelSize: 11
                            elide: Text.ElideRight
                        }
                    }
                }

                MouseArea {
                    id: pointer

                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

                    onClicked: (mouse) => {
                        const idx = tasks.makeModelIndex(index);

                        if (mouse.button === Qt.MiddleButton) {
                            tasks.requestClose(idx);
                        } else if (model.IsActive) {
                            tasks.requestToggleMinimized(idx);
                        } else {
                            tasks.requestActivate(idx);
                        }
                    }
                }
            }
        }
    }
}
