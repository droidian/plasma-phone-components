/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2019 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2013-2017 Jan Grulich <jgrulich@redhat.com>

    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.2
import QtQuick.Layouts 1.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.networkmanagement 0.2 as PlasmaNM
import org.kde.plasma.private.mobileshell 1.0 as MobileShell

PlasmaCore.IconItem {
    id: connectionIcon
    property MobileShell.WifiProvider provider: MobileShell.WifiProvider

    source: provider.icon
    colorGroup: PlasmaCore.ColorScope.colorGroup

    Layout.fillHeight: true
    Layout.preferredWidth: height

    PlasmaComponents.BusyIndicator {
        id: connectingIndicator

        anchors.fill: parent
        running: provider.indicatorRunning
        visible: running
    }
}
