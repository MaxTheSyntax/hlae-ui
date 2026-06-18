#include "PathValidator.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QVariantMap>

namespace {
QVariantMap validResult()
{
    return {
        {"valid", true},
        {"error", QString()},
    };
}

QVariantMap invalidResult(const QString &error)
{
    return {
        {"valid", false},
        {"error", error},
    };
}
}

PathValidator::PathValidator(QObject *parent)
    : QObject(parent)
{
}

QVariantMap PathValidator::containsExecutable(const QString &path, const QString &executable) const
{
    const QFileInfo fileInfo(path.trimmed());

    if (fileInfo.isFile()) {
        if (fileInfo.isExecutable()) {
            return validResult();
        } else {
            return invalidResult(tr("Provided file is not an executable."));
        }
    } else if (fileInfo.isDir()) {
        const QFileInfo executableInfo(QDir(fileInfo.absoluteFilePath()).filePath(executable));
        if (executableInfo.isFile() && executableInfo.isExecutable()) {
            return validResult();
        } else {
            return invalidResult(tr("The provided directory does not contain %1.").arg(executable));
        }
    }

    return invalidResult(tr("Unable to find the %1 executable.").arg(executable));
}

QVariantMap PathValidator::validateDemoFile(const QString &path) const
{
    const QString trimmedPath = path.trimmed();
    if (trimmedPath.isEmpty()) {
        return invalidResult(tr("Please provide a demo file path."));
    }

    const QFileInfo fileInfo(trimmedPath);
    if (!fileInfo.exists()) {
        return invalidResult(tr("Unable to find demo file."));
    }

    if (!fileInfo.isFile()) {
        return invalidResult(tr("Provided path is not a file."));
    }

    if (fileInfo.suffix().compare(QStringLiteral("dem"), Qt::CaseInsensitive) != 0) {
        return invalidResult(tr("Demo file must have a .dem extension."));
    }

    QFile demoFile(fileInfo.absoluteFilePath());
    if (!demoFile.open(QIODevice::ReadOnly)) {
        return invalidResult(tr("Unable to open demo file."));
    }

    return validResult();
}
