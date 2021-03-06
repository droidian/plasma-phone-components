/*
 *  SPDX-FileCopyrightText: 2021 Devin Lin <devin@kde.org>
 *
 *  SPDX-License-Identifier: GPL-2.0-or-later
 */

import QtQuick 2.12
import org.kde.plasma.core 2.0 as PlasmaCore

pragma Singleton

/**
 * Provides access to the panel plasmoid containment within the shell.
 */
QtObject {
    id: root
    
    signal startSwipe()
    signal endSwipe()
    signal requestRelativeScroll(real offsetY)
    property bool inSwipe: false
    property real panelHeight: PlasmaCore.Units.gridUnit // set and updated in panel containment
}
