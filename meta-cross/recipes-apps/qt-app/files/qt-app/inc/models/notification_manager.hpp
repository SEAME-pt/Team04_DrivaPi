/**
 * @file notification_manager.hpp
 * @brief Notification/toast system for HMI
 * 
 * Provides singleton for queueing and displaying notifications in QML
 * with auto-dismiss and alert level color coding.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QList>
#include <QVariantMap>
#include <QTimer>
#include <memory>

class NotificationManager : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QList<QVariantMap> notifications READ notifications NOTIFY notificationsChanged)

public:
    enum AlertLevel {
        Info = 0,
        Warning = 1,
        Critical = 2
    };
    Q_ENUM(AlertLevel)
    
    explicit NotificationManager(QObject *parent = nullptr);
    ~NotificationManager() override;
    
    // Singleton instance
    static NotificationManager *instance();
    
    // Show notification (invokable from QML)
    Q_INVOKABLE void showNotification(const QString &message, int level = Info, int durationMs = 3000);
    
    // Getters
    QList<QVariantMap> notifications() const { return m_notifications; }
    
signals:
    void notificationsChanged();

private slots:
    void removeNotification(const QString &id);

private:
    // Generate unique notification ID
    QString generateId();
    
    // Notification list
    QList<QVariantMap> m_notifications;
    
    // Timers for auto-dismiss (id -> timer)
    QMap<QString, QTimer *> m_dismissTimers;
    
    // Static singleton instance
    static std::unique_ptr<NotificationManager> s_instance;
};
