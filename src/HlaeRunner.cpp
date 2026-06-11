#include "HlaeRunner.h"

#include <QProcess>
#include <QDebug>
#include <QVariantMap>

HlaeRunner::HlaeRunner(QObject *parent)
    : QObject{parent}
{}

QVariantMap HlaeRunner::run(
    const QString hlaePath,
    const QString cs2Path,
    const QStringList &dllPaths,
    const QString cs2Arguments,
    const QStringList &envVariables,
    const bool bypassRestrictions)
{
    // Check for -inscure cs2 launch flag
    if (!bypassRestrictions && !cs2Arguments.contains("-insecure")) {
        return {
            {"success", false},
            {"error", "Insecure flag not set."},
        };
    }

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

    qDebug() << "Launching with: '" << hlaePath << " " << hlaeArgs << "'\n";

    process->start(hlaePath, hlaeArgs);
    return {
        {"success", true},
        {"error", QString()},
    };
}
