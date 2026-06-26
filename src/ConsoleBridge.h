#ifndef CONSOLEBRIDGE_H
#define CONSOLEBRIDGE_H

#include <QHash>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

#include <libvconsole/vconsole.h>

class ConsoleBridge : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QString statusMessage READ statusMessage NOTIFY statusMessageChanged)

public:
    explicit ConsoleBridge(QObject *parent = nullptr);

    QString statusMessage() const;

    Q_INVOKABLE bool isAvailable();
    Q_INVOKABLE bool sendCommand(const QString &command, const bool showGameNotOpenDialog = true);
    Q_INVOKABLE bool requestCommandOutput(const QString &requestId,
                                          const QString &command,
                                          int timeoutMs = 600);

signals:
    void statusMessageChanged();
    void gameNotOpenDialogRequested();
    void commandOutputReady(const QString &requestId, const QStringList &lines);

private:
    void setStatusMessage(const QString &message);
    bool ensureConnected();
    void handleConsolePrint(const PRNT &print);
    void pollConsoleOutput();
    void finishOutputRequest(const QString &requestId);
    void stopPollingIfIdle();

    VConsole m_console;
    bool m_connected = false;
    QString m_statusMessage;
    QTimer m_pollTimer;
    QHash<QString, QStringList> m_pendingOutputRequests;
};

#endif // CONSOLEBRIDGE_H
