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
    m_console.setOnPRNTReceived([this](const PRNT &print) {
        handleConsolePrint(print);
    });

    m_pollTimer.setInterval(25);
    connect(&m_pollTimer, &QTimer::timeout, this, &ConsoleBridge::pollConsoleOutput);
}

QString ConsoleBridge::statusMessage() const
{
    return m_statusMessage;
}

bool ConsoleBridge::isAvailable()
{
    return ensureConnected();
}

bool ConsoleBridge::sendCommand(const QString &command, const bool showGameNotOpenDialog)
{
    const QString trimmedCommand = command.trimmed();
    if (trimmedCommand.isEmpty()) {
        return false;
    }

    if (!ensureConnected()) {
        setStatusMessage(tr("Source console is not available"));
        if (showGameNotOpenDialog) {
            emit gameNotOpenDialogRequested();
        }
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
        if (showGameNotOpenDialog) {
            emit gameNotOpenDialogRequested();
        }
        return false;
    }

    if (m_console.sendCmd(commandBytes.constData())) {
        setStatusMessage(tr("Sent: %1").arg(trimmedCommand));
        return true;
    }

    setStatusMessage(tr("Failed to send command"));
    return false;
}

bool ConsoleBridge::requestCommandOutput(const QString &requestId,
                                         const QString &command,
                                         int timeoutMs)
{
    const QString trimmedRequestId = requestId.trimmed();
    if (trimmedRequestId.isEmpty()) {
        return false;
    }

    m_pendingOutputRequests.insert(trimmedRequestId, QStringList{});
    if (!sendCommand(command)) {
        m_pendingOutputRequests.remove(trimmedRequestId);
        stopPollingIfIdle();
        return false;
    }

    if (!m_pollTimer.isActive()) {
        m_pollTimer.start();
    }

    const int boundedTimeoutMs = timeoutMs < 50 ? 50 : timeoutMs;
    QTimer::singleShot(boundedTimeoutMs, this, [this, trimmedRequestId]() {
        finishOutputRequest(trimmedRequestId);
    });

    return true;
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
    if (m_connected) {
        setSocketNonBlocking(m_console.getSocket());
    }

    return m_connected;
}

void ConsoleBridge::handleConsolePrint(const PRNT &print)
{
    if (m_pendingOutputRequests.isEmpty()) {
        return;
    }

    QString message = QString::fromStdString(print.message);
    message.replace('\r', '\n');

    const QStringList rawLines = message.split('\n', Qt::SkipEmptyParts);
    QStringList lines;
    for (const QString &rawLine : rawLines) {
        const QString line = rawLine.trimmed();
        if (!line.isEmpty()) {
            lines.append(line);
        }
    }

    if (lines.isEmpty()) {
        return;
    }

    for (auto it = m_pendingOutputRequests.begin(); it != m_pendingOutputRequests.end(); ++it) {
        it.value().append(lines);
    }
}

void ConsoleBridge::pollConsoleOutput()
{
    if (!m_connected) {
        stopPollingIfIdle();
        return;
    }

    if (socketPeerClosed(m_console.getSocket())) {
        m_console.disconnect();
        m_connected = false;
        stopPollingIfIdle();
        return;
    }

    for (int packetIndex = 0; packetIndex < 64; ++packetIndex) {
        if (!m_console.processIncomingData()) {
            break;
        }
    }

    stopPollingIfIdle();
}

void ConsoleBridge::finishOutputRequest(const QString &requestId)
{
    const auto it = m_pendingOutputRequests.find(requestId);
    if (it == m_pendingOutputRequests.end()) {
        return;
    }

    const QStringList lines = it.value();
    m_pendingOutputRequests.erase(it);
    emit commandOutputReady(requestId, lines);
    stopPollingIfIdle();
}

void ConsoleBridge::stopPollingIfIdle()
{
    if (m_pendingOutputRequests.isEmpty() && m_pollTimer.isActive()) {
        m_pollTimer.stop();
    }
}
