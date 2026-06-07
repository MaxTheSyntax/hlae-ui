#include "ConsoleBridge.h"

#include <QByteArray>

ConsoleBridge::ConsoleBridge(QObject *parent)
    : QObject(parent)
{
}

QString ConsoleBridge::statusMessage() const
{
    return m_statusMessage;
}

bool ConsoleBridge::sendCommand(const QString &command)
{
    const QString trimmedCommand = command.trimmed();
    if (trimmedCommand.isEmpty()) {
        return false;
    }

    if (!ensureConnected()) {
        setStatusMessage(tr("Source console is not available"));
        return false;
    }

    const QByteArray commandBytes = trimmedCommand.toUtf8();
    if (m_console.sendCmd(commandBytes.constData())) {
        setStatusMessage(tr("Sent: %1").arg(trimmedCommand));
        return true;
    }

    m_console.disconnect();
    m_connected = false;

    if (ensureConnected() && m_console.sendCmd(commandBytes.constData())) {
        setStatusMessage(tr("Sent: %1").arg(trimmedCommand));
        return true;
    }

    setStatusMessage(tr("Failed to send command"));
    return false;
}

void ConsoleBridge::setStatusMessage(const QString &message)
{
    if (m_statusMessage == message) {
        return;
    }

    m_statusMessage = message;
    emit statusMessageChanged();
}

bool ConsoleBridge::ensureConnected()
{
    if (m_connected) {
        return true;
    }

    m_connected = m_console.connect();
    return m_connected;
}
