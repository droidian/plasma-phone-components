/*
 *   Copyright 2014 Aaron Seigo <aseigo@kde.org>
 *   Copyright 2012 Marco Martin <notmart@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtGraphicalEffects 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.shell 2.0 as Shell
import org.kde.satellite.components 0.1 as SatelliteComponents
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.workspace.components 2.0 as PlasmaWorkspace
import org.nemomobile.voicecall 1.0
import org.kde.kquickcontrolsaddons 2.0
import MeeGo.QOfono 0.2
import "../components"

Item {
    id: homescreen
    width: 1080
    height: 1920

    property Item containment;
    property Item wallpaper;
    property var pendingRemovals: [];
    property int notificationId: 0;
    property int buttonHeight: width/4

<<<<<<< HEAD
    /*
        Notification data object has the following properties:
        appIcon
        image
        appName
        summary
        body
        isPersistent
        expireTimeout
        urgency
        appRealName
        configurable
    */
    function addNotification(source, data, actions) {
        // Do not show duplicated notifications
        // Remove notifications that are sent again (odd, but true)
        for (var i = 0; i < notificationsModel.count; ++i) {
            var tmp = notificationsModel.get(i);
            var matches = (tmp.appName == data.appName &&
                           tmp.summary == data.summary &&
                           tmp.body == data.body);
            var sameSource = tmp.source == source;
=======
    onContainmentChanged: {
        containment.parent = homescreen;
>>>>>>> mart/newContainmentShell

        if (containment != null) {
            containment.visible = true;
        }
        if (containment != null) {
            containment.anchors.left = homescreen.left;
            containment.anchors.top = homescreen.top;
            containment.anchors.right = homescreen.right;
            containment.anchors.bottom = homescreen.bottom;
        }
    }

    OfonoManager {
        id: ofonoManager
        onAvailableChanged: {
           console.log("Ofono is " + available)
        }
        onModemAdded: {
            console.log("modem added " + modem)
        }
        onModemRemoved: console.log("modem removed")
    }

    OfonoConnMan {
       id: ofono1
       Component.onCompleted: {
           console.log(ofonoManager.modems)
       }
       modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
    }

    OfonoModem {
       id: modem1
       modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""

    }

    OfonoContextConnection {
        id: context1
        contextPath : ofono1.contexts.length > 0 ? ofono1.contexts[0] : ""
        Component.onCompleted: {
            print("Context Active: " + context1.active)
        }
        onActiveChanged: {
            print("Context Active: " + context1.active)
        }
    }

    property OfonoSimManager simManager: ofonoSimManager
    OfonoSimManager {
        id: ofonoSimManager
        modemPath: ofonoManager.modems.length > 0 ? ofonoManager.modems[0] : ""
    }

    OfonoNetworkOperator {
        id: netop
    }

    property VoiceCallManager manager: VoiceCallManager {
        id: manager

        onActiveVoiceCallChanged: {
            if (activeVoiceCall) {
                dialerOverlay.open();
                //main.activeVoiceCallPerson = people.personByPhoneNumber(activeVoiceCall.lineId);
                dialerOverlay.item.numberEntryText = activeVoiceCall.lineId;

            } else {
                dialerOverlay.close();
                dialerOverlay.item.numberEntryText = '';

                //main.activeVoiceCallPerson = null;
            }
        }

        onError: {
            console.log('*** QML *** VCM ERROR: ' + message);
        }
    }

    //pass the focus to the containment, so it can react to homescreen activate/inactivate
    Connections {
        target: desktop
        onActiveChanged: {
            containment.focus = desktop.active;
        }
    }

    Loader {
        id: dialerOverlay
        function open() {
            source = Qt.resolvedUrl("Dialer.qml")
            dialerOverlay.item.open();
        }
        function close() {
            dialerOverlay.item.close();
        }
        anchors {
            left: parent.left
            top: statusPanel.bottom
            right: parent.right
            bottom: parent.bottom
        }
        z: 20
    }
    Loader {
        id: pinOverlay
        anchors {
            left: parent.left
            top: statusPanel.bottom
            right: parent.right
            bottom: parent.bottom
        }
        z: 21
        source: simManager.pinRequired != OfonoSimManager.NoPin ? Qt.resolvedUrl("Pin.qml") : ""
    }

    Component.onCompleted: {
        //configure the view behavior
        if (desktop) {
            desktop.width = width;
            desktop.height = height;
        }
    }
}
