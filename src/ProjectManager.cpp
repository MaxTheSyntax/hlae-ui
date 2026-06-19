#include "ProjectManager.h"
#include <QFile>
#include <QFileInfo>
#include <QDir>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonParseError>
#include <QVariantMap>
#include <QVariantList>
#include <QStandardPaths>
#include <QUuid>

const QDir projectsDir(QDir(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation)).filePath("HLAE Projects"));

namespace {
bool isWindowsIllegalFileNameChar(QChar c)
{
    static const QString illegalChars = QStringLiteral("<>:\"/\\|?*.");
    return c.unicode() < 32 || illegalChars.contains(c);
}

QString nextAvailableProjectName(const QString &baseName)
{
    if (!projectsDir.exists(baseName))
        return baseName;

    int suffix = 1;
    QString candidate;
    do {
        candidate = baseName + QString::number(suffix++);
    } while (projectsDir.exists(candidate));

    return candidate;
}

void appendProjectNameSeparator(QString &out)
{
    if (!out.isEmpty() && !out.endsWith(QChar('-')))
        out.append(QChar('-'));
}

QVariantMap invalidResult(const QString &error)
{
    qWarning() << error;
    return {
        {"valid", false},
        {"error", error},
    };
}

QVariantMap projectFromJsonFile(const QString &filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly))
        return {};

    QJsonParseError parseError;
    const QJsonDocument doc = QJsonDocument::fromJson(file.readAll(), &parseError);
    if (parseError.error != QJsonParseError::NoError || !doc.isObject()) {
        qWarning() << QObject::tr("Unable to read project file (%1): %2")
                          .arg(filePath, parseError.errorString());
        return {};
    }

    const QJsonObject object = doc.object();
    const QString id = object.value(QStringLiteral("id")).toString();
    const QString name = object.value(QStringLiteral("name")).toString();
    const QString demoPath = object.value(QStringLiteral("demoPath")).toString();

    if (id.isEmpty() || name.isEmpty() || demoPath.isEmpty()) {
        qWarning() << QObject::tr("Project file is missing required fields (%1).").arg(filePath);
        return {};
    }

    return {
        {"id", id},
        {"name", name},
        {"demoPath", demoPath},
        {"map", object.value(QStringLiteral("map")).toString()},
        {"projectPath", QFileInfo(filePath).absolutePath()},
    };
}
}

ProjectManager::ProjectManager(QObject *parent)
    : QObject{parent}
{}

QString ProjectManager::normalizeProjectName(QString s)
{
    QString out;
    out.reserve(s.size());

    for (QChar c : s) {
        if (isWindowsIllegalFileNameChar(c))
            continue;

        ushort ch = c.toLower().unicode();

        if ((ch >= 'a' && ch <= 'z') || (ch >= '0' && ch <= '9')) {
            out.append(QChar(ch));
        } else if (c.isSpace() || c == QChar('-') || c == QChar('_')) {
            appendProjectNameSeparator(out);
        }
    }

    while (out.endsWith(QChar('-')))
        out.chop(1);

    if (out.isEmpty())
        out = QStringLiteral("project");

    return nextAvailableProjectName(out);
}

QString getMapNameFromBytes(QByteArray bytes) {
    QByteArray pattern = QByteArray::fromHex("53 6F 75 72 63 65 54 56 20 44 65 6D 6F 2A"); // means "SourceTV Demo*"

    int mapNameLengthLocation = bytes.indexOf(pattern) + pattern.length();
    int mapNameLength = static_cast<quint8>(bytes[mapNameLengthLocation]);
    int mapNameStart = mapNameLengthLocation + 1;

    QString mapName = bytes.mid(mapNameStart, mapNameLength);
    qDebug() << "selected demo map name: " << mapName;

    return mapName;
}

QVariantMap ProjectManager::create(QString name, QString demoPath) {
    QFile demo(demoPath.trimmed());

    // make sure exists
    if (!demo.exists() || !demo.open(QIODevice::ReadOnly)) {
        QString msg = tr("Unable to find or open demo file.");
        return invalidResult(msg);
    }

    // setup basic data
    QJsonObject info;
    info["id"] = QUuid::createUuid().toString(QUuid::WithoutBraces);
    info["name"] = name;
    info["demoPath"] = demoPath;

    // get map
    QByteArray firstBytes = demo.read(1000);
    QString mapName = getMapNameFromBytes(firstBytes);
    info["map"] = mapName;

    // create project dir
    QString projectFolderName = normalizeProjectName(name);
    QDir projectDir(projectsDir.filePath(projectFolderName));
    if (!projectsDir.mkpath(projectFolderName)) {
        QString msg = tr("Unable to create project folder (%1).").arg(projectDir.absolutePath());
        return invalidResult(msg);
    }

    // write info file
    QJsonDocument infoDoc(info);
    QFile infoFile(projectDir.filePath("project.json"));
    if (!infoFile.open(QIODevice::WriteOnly)) {
        QString msg = tr("Failed to create project file (%1).").arg(QFileInfo(infoFile).absolutePath());
        return invalidResult(msg);
    }
    infoFile.write(infoDoc.toJson());
    infoFile.close();

    return {
        {"valid", true},
        {"error", QString()},
        {"id", info["id"].toString()},
        {"name", info["name"].toString()},
        {"demoPath", info["demoPath"].toString()},
        {"map", info["map"].toString()},
        {"projectPath", projectDir.absolutePath()},
    };
}

QVariantList ProjectManager::list() {
    QVariantList projects;

    if (!projectsDir.exists())
        return projects;

    const QFileInfoList projectDirs = projectsDir.entryInfoList(QDir::Dirs | QDir::NoDotAndDotDot, QDir::Name);
    for (const QFileInfo &projectDirInfo : projectDirs) {
        const QString projectFilePath = QDir(projectDirInfo.absoluteFilePath()).filePath(QStringLiteral("project.json"));
        if (!QFileInfo::exists(projectFilePath))
            continue;

        QVariantMap project = projectFromJsonFile(projectFilePath);
        if (!project.isEmpty())
            projects.append(project);
    }

    return projects;
}

QVariantMap ProjectManager::load(QString uuid) {
    const QString trimmedUuid = uuid.trimmed();
    if (trimmedUuid.isEmpty())
        return invalidResult(tr("No project selected."));

    const QVariantList projects = list();
    for (const QVariant &projectVariant : projects) {
        QVariantMap project = projectVariant.toMap();
        if (project.value(QStringLiteral("id")).toString() != trimmedUuid)
            continue;

        project.insert(QStringLiteral("valid"), true);
        project.insert(QStringLiteral("error"), QString());
        return project;
    }

    return invalidResult(tr("Unable to find project (%1).").arg(trimmedUuid));
}

QVariantMap ProjectManager::remove(QString uuid) {
    const QString trimmedUuid = uuid.trimmed();
    if (trimmedUuid.isEmpty())
        return invalidResult(tr("No project selected."));

    const QVariantList projects = list();
    for (const QVariant &projectVariant : projects) {
        const QVariantMap project = projectVariant.toMap();
        if (project.value(QStringLiteral("id")).toString() != trimmedUuid)
            continue;

        const QString projectPath = project.value(QStringLiteral("projectPath")).toString();
        QDir projectDir(projectPath);
        if (!projectDir.exists())
            return invalidResult(tr("Project folder does not exist (%1).").arg(projectPath));

        if (!projectDir.removeRecursively())
            return invalidResult(tr("Unable to delete project folder (%1).").arg(projectPath));

        return {
            {"valid", true},
            {"error", QString()},
            {"id", trimmedUuid},
            {"name", project.value(QStringLiteral("name")).toString()},
            {"projectPath", projectPath},
        };
    }

    return invalidResult(tr("Unable to find project (%1).").arg(trimmedUuid));
}
