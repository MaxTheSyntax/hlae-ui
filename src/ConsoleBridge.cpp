#include "ConsoleBridge.h"

#include <QByteArray>

namespace {

bool socketPeerClosed(SOCKET socket)
{
    if (socket == INVALID_SOCKET) {
        return true;
    }

    fd_set readSet;
    FD_ZERO(&readSet);
    FD_SET(socket, &readSet);

    // Poll the socket without blocking the UI thread. A readable TCP socket can
    // mean either pending data or that the peer closed the connection.
    timeval timeout{};
#ifdef _WIN32
    const int ready = select(0, &readSet, nullptr, nullptr, &timeout);
#else
    const int ready = select(socket + 1, &readSet, nullptr, nullptr, &timeout);
#endif
    if (ready == SOCKET_ERROR) {
        return true;
    }

    if (ready == 0) {
        return false;
    }

    // Peek so we can detect a closed peer without consuming any real console
    // data that libvconsole may want to read later.
    char byte;
    const int received = recv(socket, &byte, 1, MSG_PEEK);
    if (received == 0) {
        return true;
    }

    if (received == SOCKET_ERROR) {
        const int error = SOCKET_ERROR_CODE;
        return error != WOULD_BLOCK_ERROR;
    }

    return false;
}

}

ConsoleBridge::ConsoleBridge(QObject *parent)
    : QObject(parent)
{
}

QString ConsoleBridge::statusMessage() const
{
    return m_statusMessage;
}

bool ConsoleBridge::isAvailable()
{
    return ensureConnected();
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

    if (!ensureConnected()) {
        setStatusMessage(tr("Source console is not available"));
        return false;
    }

    if (m_console.sendCmd(commandBytes.constData())) {
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
        if (!socketPeerClosed(m_console.getSocket())) {
            return true;
        }

        m_console.disconnect();
        m_connected = false;
    }

    m_connected = m_console.connect();
    return m_connected;
}
