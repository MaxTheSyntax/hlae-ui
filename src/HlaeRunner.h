#ifndef HLAERUNNER_H
#define HLAERUNNER_H

#include <QObject>
#include <QProcess>

class HlaeRunner : public QObject
{
    Q_OBJECT
public:
    explicit HlaeRunner(QObject *parent = nullptr);

    Q_INVOKABLE void run(const QString hlaePath,
                         const QString cs2Path,
                         const QStringList &dllPaths,
                         const QString cs2Arguments,
                         const QStringList &envVariables);

signals:
};

#endif // HLAERUNNER_H
