#ifndef PROJECTMANAGER_H
#define PROJECTMANAGER_H

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>

class ProjectManager : public QObject
{
    Q_OBJECT
    QML_ELEMENT
public:
    /// Create a manager instance for project operations.
    explicit ProjectManager(QObject *parent = nullptr);

    /// Set up a project folder and metadata from a demo file.
    Q_INVOKABLE QVariantMap create(QString name, QString demoPath);

    /// Return metadata for every saved project.
    Q_INVOKABLE QVariantList list();

    /// Open a saved project by its persistent identifier.
    Q_INVOKABLE QVariantMap load(QString uuid);

    /// Delete a saved project by its persistent identifier.
    Q_INVOKABLE QVariantMap remove(QString uuid);

    /// Return stream metadata stored in the selected project's project.json.
    Q_INVOKABLE QVariantMap streamMetadata(QString uuid);

    /// Merge stream metadata into the selected project's project.json.
    Q_INVOKABLE QVariantMap setStreamMetadata(QString uuid, QString streamName, QVariantMap metadata);

    /// Remove stream metadata from the selected project's project.json.
    Q_INVOKABLE QVariantMap removeStreamMetadata(QString uuid, QString streamName);

    /// Convert arbitrary text into a filesystem-safe folder label (windows).
    Q_INVOKABLE QString normalizeProjectName(QString s);

signals:
};

#endif // PROJECTMANAGER_H
