/*
    SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
    SPDX-License-Identifier: GPL-2.0-or-later
 */

#include "homescreen.h"

#include <KWindowSystem>
#include <QDebug>
#include <QQuickItem>
#include <QtQml>

HomeScreen::HomeScreen(QObject *parent, const QVariantList &args)
    : Plasma::Containment(parent, args)
{
    setHasConfigurationInterface(true);
    connect(KWindowSystem::self(), &KWindowSystem::showingDesktopChanged, this, &HomeScreen::showingDesktopChanged);
}

HomeScreen::~HomeScreen() = default;

void HomeScreen::configChanged()
{
    Plasma::Containment::configChanged();
}


void HomeScreen::stackBefore(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackBefore(item2);
}

void HomeScreen::stackAfter(QQuickItem *item1, QQuickItem *item2)
{
    if (!item1 || !item2 || item1 == item2 || item1->parentItem() != item2->parentItem()) {
        return;
    }

    item1->stackAfter(item2);
}

bool HomeScreen::showingDesktop() const
{
    return KWindowSystem::showingDesktop();
}

void HomeScreen::setShowingDesktop(bool showingDesktop)
{
    KWindowSystem::setShowingDesktop(showingDesktop);
}

K_PLUGIN_CLASS_WITH_JSON(HomeScreen, "metadata.json")

#include "homescreen.moc"
