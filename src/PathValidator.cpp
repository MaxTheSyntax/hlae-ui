#include "PathValidator.h"

#include <QDir>
#include <QFileInfo>

PathValidator::PathValidator(QObject *parent)
    : QObject(parent)
{
}

QVariantMap PathValidator::containsExecutable(const QString &path, const QString &executable) const
{
    const QFileInfo fileInfo(path.trimmed());

    if (fileInfo.isFile()) {
        if (fileInfo.isExecutable()) {
            return {
                {"valid", true},
                {"error", QString()},
            };
        } else {
            return {
                {"valid", false},
                {"error", tr("Provided file is not an executable.")},
            };
        }
    } else if (fileInfo.isDir()) {
        const QFileInfo executableInfo(QDir(fileInfo.absoluteFilePath()).filePath(executable));
        if (executableInfo.isFile() && executableInfo.isExecutable()) {
            return {
                {"valid", true},
                {"error", QString()},
            };
        } else {
            return {
                {"valid", false},
                {"error", tr("The provided directory does not contain an executable executable file.")},
            };
        }
    }

    return {
        {"valid", false},
        {"error", tr("Unable to find the %1 executable.").arg(executable)},
    };
}
