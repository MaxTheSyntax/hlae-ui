#include "PathValidator.h"

#include <QDir>
#include <QFileInfo>

PathValidator::PathValidator(QObject *parent)
    : QObject(parent)
{
}

QVariantMap PathValidator::containsHlaeExecutable(const QString &path) const
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
        const QFileInfo executableInfo(QDir(fileInfo.absoluteFilePath()).filePath("HLAE.exe"));
        if (executableInfo.isFile() && executableInfo.isExecutable()) {
            return {
                {"valid", true},
                {"error", QString()},
            };
        } else {
            return {
                {"valid", false},
                {"error", tr("The provided directory does not contain an executable HLAE.exe file.")},
            };
        }
    }

    return {
        {"valid", false},
        {"error", tr("Unable to find the HLAE executable.")},
    };
}
