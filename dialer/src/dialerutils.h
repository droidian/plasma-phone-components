/*
 * Copyright 2015 Marco Martin <mart@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

#ifndef DIALERUTILS_H
#define DIALERUTILS_H

#include <QObject>
#include <QPointer>
#include <KNotification>

class DialerUtils : public QObject
{
    Q_OBJECT
public:

    DialerUtils(QObject *parent = 0);
    virtual ~DialerUtils();

    Q_INVOKABLE void notifyMissedCall(const QString &caller, const QString &description);
    Q_INVOKABLE void resetMissedCalls();
    Q_INVOKABLE void notifyRinging();
    Q_INVOKABLE void stopRinging();

Q_SIGNALS:
    void missedCallsActionTriggered();

private:
    QPointer <KNotification> m_callsNotification;
    QPointer <KNotification> m_ringingNotification;
    int m_missedCalls;
};


#endif