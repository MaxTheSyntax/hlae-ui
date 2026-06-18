#ifndef PATHVALIDATOR_H
#define PATHVALIDATOR_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

class PathValidator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit PathValidator(QObject *parent = nullptr);

    Q_INVOKABLE QVariantMap containsExecutable(const QString &path, const QString &executable) const;
    Q_INVOKABLE QVariantMap validateDemoFile(const QString &path) const;
};

#endif // PATHVALIDATOR_H
