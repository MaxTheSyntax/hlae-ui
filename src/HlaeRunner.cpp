#include "HlaeRunner.h"

#include <QProcess>
#include <QDebug>

HlaeRunner::HlaeRunner(QObject *parent)
    : QObject{parent}
{}

void HlaeRunner::run(
    const QString hlaePath,
    const QString cs2Path,
    const QStringList &dllPaths,
    const QString cs2Arguments,
    const QStringList &envVariables)
{
    QProcess *process = new QProcess(this);

    process->setProcessChannelMode(QProcess::MergedChannels);

    connect(process, &QProcess::readyReadStandardOutput, this, [process]() {
        const QString output = process->readAllStandardOutput();
        qDebug() << output;
    });

    QStringList hlaeArgs = {
        QStringLiteral("-noConfig"),
        QStringLiteral("-customLoader"),
        QStringLiteral("-noGui"),
        QStringLiteral("-autoStart")
    };

    for (const QString &dllPath : dllPaths) {
        hlaeArgs << QStringLiteral("-hookDllPath") << dllPath;
    }

    hlaeArgs << QStringLiteral("-programPath") << cs2Path
             << QStringLiteral("-cmdLine") << cs2Arguments;

    for (const QString &envVariable : envVariables) {
        hlaeArgs << QStringLiteral("--addEnv") << envVariable;
    }

    process->start(hlaePath, hlaeArgs);
}
