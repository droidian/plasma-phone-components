/*
 *  Copyright 2013 Marco Martin <mart@kde.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Dialogs 1.1
import QtQuick.Controls 1.0 as QtControls
import QtQuick.Layouts 1.0
import org.kde.plasma.configuration 2.0


//TODO: all of this will be done with desktop components
Rectangle {
    id: root
    Layout.minimumWidth: units.gridUnit * 30
    Layout.minimumHeight: units.gridUnit * 20

//BEGIN properties
    color: Qt.rgba(0, 0, 0, 1 - panel.x/width)
    width: units.gridUnit * 40
    height: units.gridUnit * 30

    property bool isContainment: false
//END properties

//BEGIN model
    property ConfigModel globalConfigModel:  globalAppletConfigModel

    ConfigModel {
        id: globalAppletConfigModel
        ConfigCategory {
            name: i18nd("plasma_shell_org.kde.plasma.desktop", "Keyboard shortcuts")
            icon: "preferences-desktop-keyboard"
            source: "ConfigurationShortcuts.qml"
        }
    }
//END model

//BEGIN functions
    function saveConfig() {
        if (main.currentItem.saveConfig) {
            main.currentItem.saveConfig()
        } else {
            for (var key in plasmoid.configuration) {
                if (main.currentItem["cfg_"+key] !== undefined) {
                    plasmoid.configuration[key] = main.currentItem["cfg_"+key]
                }
            }
        }
    }

    function restoreConfig() {
        for (var key in plasmoid.configuration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                main.currentItem["cfg_"+key] = plasmoid.configuration[key]
            }
        }
    }

    function configurationHasChanged() {
        for (var key in plasmoid.configuration) {
            if (main.currentItem["cfg_"+key] !== undefined) {
                //for objects == doesn't work
                if (typeof plasmoid.configuration[key] == 'object') {
                    for (var i in plasmoid.configuration[key]) {
                        if (plasmoid.configuration[key][i] != main.currentItem["cfg_"+key][i]) {
                            return true;
                        }
                    }
                    return false;
                } else if (main.currentItem["cfg_"+key] != plasmoid.configuration[key]) {
                    return true;
                }
            }
        }
        return false;
    }

    function settingValueChanged() {
        if (main.currentItem.saveConfig !== undefined) {
            main.currentItem.saveConfig();
        } else {
            root.saveConfig();
        }
    }
//END functions


//BEGIN connections
    Component.onCompleted: {
        if (!isContainment && configDialog.configModel && configDialog.configModel.count > 0) {
            main.sourceFile = configDialog.configModel.get(0).source
            main.title = configDialog.configModel.get(0).name
        } else {
            main.sourceFile = globalConfigModel.get(0).source
            main.title = globalConfigModel.get(0).name
        }
    }
//END connections

//BEGIN UI components
    SystemPalette {id: syspal}

    NumberAnimation {
        id: openAnim
        running: true
        target: panel
        properties: "x"
        duration: units.longDuration
        easing.type: Easing.InOutQuad
        to: root.width/6
    }
    SequentialAnimation {
        id: closeAnim
        NumberAnimation {
            target: panel
            properties: "x"
            duration: units.longDuration
            easing.type: Easing.InOutQuad
            to: root.width
        }
        ScriptAction {
            script: cancelAction.trigger();
        }
    }

    Timer {
        running: true
        interval: 250
        onTriggered: {
            openAnim.running = true;
        }
    }
    onWidthChanged: panel.x = root.width/6

    MessageDialog {
        id: messageDialog
        icon: StandardIcon.Warning
        property Item delegate
        title: i18nd("plasma_shell_org.kde.plasma.desktop", "Apply Settings")
        text: i18nd("plasma_shell_org.kde.plasma.desktop", "The settings of the current module have changed. Do you want to apply the changes or discard them?")
        standardButtons: StandardButton.Apply | StandardButton.Discard | StandardButton.Cancel
        onApply: {
            applyAction.trigger()
            delegate.openCategory()
        }
        onDiscard: {
            delegate.openCategory()
        }
    }

    MouseArea {
        anchors.fill: parent
        drag.filterChildren: true
        drag.target: panel
        drag.axis: Drag.XAxis
        drag.maximumX: width
        drag.minimumX: width/6
        onReleased: {
            if (panel.x > root.width/2) {
                closeAnim.running = true;
            } else {
                openAnim.running = true;
            }
        }
        onClicked: {
            if (mouse.x < width / 6) {
                closeAnim.running = true;
            }
        }
        Rectangle {
            id: panel
            width: root.width - root.width/6
            x: root.width
            height: root.height
            color: syspal.window
            ColumnLayout {
                id: mainColumn
                anchors {
                    fill: parent
                    margins: mainColumn.spacing //margins are hardcoded in QStyle we should match that here
                }
                property int implicitWidth: Math.max(contentRow.implicitWidth, buttonsRow.implicitWidth) + 8
                property int implicitHeight: contentRow.implicitHeight + buttonsRow.implicitHeight + 8

                RowLayout {
                    id: contentRow
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    spacing: units.largeSpacing
                    Layout.fillHeight: true
                    Layout.preferredHeight: parent.height - buttonsRow.height

                    QtControls.ScrollView {
                        id: categoriesScroll
                        frameVisible: true
                        Layout.fillHeight: true
                        visible: (configDialog.configModel ? configDialog.configModel.count : 0) + globalConfigModel.count > 1
                        width: visible ? units.gridUnit * 7 : 0
                        implicitWidth: width
                        flickableItem.interactive: false

                        Rectangle {
                            width: categoriesScroll.viewport.width
                            height: Math.max(categoriesScroll.viewport.height, categories.height)
                            color: syspal.base

                            Column {
                                id: categories
                                width: parent.width
                                height: childrenRect.height

                                property Item currentItem: children[1]

                                Repeater {
                                    model: root.isContainment ? globalConfigModel : undefined
                                    delegate: ConfigCategoryDelegate {}
                                }
                                Repeater {
                                    model: configDialog.configModel
                                    delegate: ConfigCategoryDelegate {}
                                }
                                Repeater {
                                    model: !root.isContainment ? globalConfigModel : undefined
                                    delegate: ConfigCategoryDelegate {}
                                }
                            }
                        }
                    }
                    QtControls.ScrollView {
                        id: scroll
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        Column {
                            spacing: units.largeSpacing / 2

                            QtControls.Label {
                                id: pageTitle
                                width: scroll.viewport.width
                                font.pointSize: theme.defaultFont.pointSize*2
                                font.weight: Font.Light
                                text: main.title
                            }

                            QtControls.StackView {
                                id: main
                                property string title: ""
                                property bool invertAnimations: false

                                height: Math.max((scroll.viewport.height - pageTitle.height - parent.spacing), (main.currentItem  ? (main.currentItem.implicitHeight ? main.currentItem.implicitHeight : main.currentItem.childrenRect.height) : 0))
                                width: scroll.viewport.width

                                property string sourceFile

                                onSourceFileChanged: {
        //                             print("Source file changed in flickable" + sourceFile);
                                    replace(Qt.resolvedUrl(sourceFile));
                                    root.restoreConfig()
                                    for (var prop in currentItem) {
                                        if (prop.indexOf("cfg_") === 0 && prop.indexOf("Changed") > 0 ) {
                                            currentItem[prop].connect(root.settingValueChanged)
                                        }
                                    }
                                    if (currentItem["configurationChanged"]) {
                                        currentItem["configurationChanged"].connect(root.settingValueChanged)
                                    }
                                    /*
                                        * This is not needed on a desktop shell that has ok/apply/cancel buttons, i'll leave it here only for future reference until we have a prototype for the active shell.
                                        * root.pageChanged will start a timer, that in turn will call saveConfig() when triggered

                                    for (var prop in currentItem) {
                                        if (prop.indexOf("cfg_") === 0) {
                                            currentItem[prop+"Changed"].connect(root.pageChanged)
                                        }
                                    }*/
                                }

                                delegate: QtControls.StackViewDelegate {
                                    function transitionFinished(properties)
                                    {
                                        properties.exitItem.opacity = 1
                                    }

                                    pushTransition: QtControls.StackViewTransition {
                                        PropertyAnimation {
                                            target: enterItem
                                            property: "opacity"
                                            from: 0
                                            to: 1
                                            duration: units.longDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                        PropertyAnimation {
                                            target: enterItem
                                            property: "x"
                                            from: main.invertAnimations ? -target.width/3: target.width/3
                                            to: 0
                                            duration: units.longDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                        PropertyAnimation {
                                            target: exitItem
                                            property: "opacity"
                                            from: 1
                                            to: 0
                                            duration: units.longDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                        PropertyAnimation {
                                            target: exitItem
                                            property: "x"
                                            from: 0
                                            to: main.invertAnimations ? target.width/3 : -target.width/3
                                            duration: units.longDuration
                                            easing.type: Easing.InOutQuad
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                QtControls.Action {
                    id: acceptAction
                    onTriggered: {
                        applyAction.trigger();
                        configDialog.close();
                    }
                    shortcut: "Return"
                }

                QtControls.Action {
                    id: applyAction
                    onTriggered: {
                        if (main.currentItem.saveConfig !== undefined) {
                            main.currentItem.saveConfig();
                        } else {
                            root.saveConfig();
                        }
                    }
                }

                QtControls.Action {
                    id: cancelAction
                    onTriggered: configDialog.close();
                    shortcut: "Escape"
                }
            }
        }
    }
//END UI components
}
