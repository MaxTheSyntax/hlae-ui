#ifndef CONSOLEBRIDGE_H
#define CONSOLEBRIDGE_H

#include <QObject>
#include <QString>
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

signals:
    void statusMessageChanged();
    void gameNotOpenDialogRequested();

private:
    void setStatusMessage(const QString &message);
    bool ensureConnected();

    VConsole m_console;
    bool m_connected = false;
    QString m_statusMessage;
};

#endif // CONSOLEBRIDGE_H
