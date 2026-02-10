#include "notification_manager.hpp"
#include <QDebug>
#include <QUuid>
#include <QMap>
#include <QDateTime>

std::unique_ptr<NotificationManager> NotificationManager::s_instance = nullptr;

NotificationManager::NotificationManager(QObject *parent)
    : QObject(parent)
{
}

NotificationManager::~NotificationManager()
{
    // Clean up all timers
    for (auto timer : m_dismissTimers) {
        if (timer) delete timer;
    }
}

NotificationManager *NotificationManager::instance()
{
    if (!s_instance) {
        s_instance = std::make_unique<NotificationManager>();
    }
    return s_instance.get();
}

void NotificationManager::showNotification(const QString &message, int level, int durationMs)
{
    // Generate unique ID for this notification
    QString id = generateId();
    
    // Create notification map
    QVariantMap notif;
    notif["id"] = id;
    notif["message"] = message;
    notif["level"] = level;  // Info=0, Warning=1, Critical=2
    notif["timestamp"] = QDateTime::currentMSecsSinceEpoch();
    
    // Add to list (max 5 notifications)
    if (m_notifications.size() >= 5) {
        // Remove oldest notification
        QString oldestId = m_notifications.takeFirst()["id"].toString();
        if (m_dismissTimers.contains(oldestId)) {
            QTimer *oldTimer = m_dismissTimers[oldestId];
            m_dismissTimers.remove(oldestId);
            oldTimer->stop();
            delete oldTimer;
        }
    }
    
    m_notifications.append(notif);
    
    // Set up auto-dismiss timer
    QTimer *dismissTimer = new QTimer(this);
    m_dismissTimers[id] = dismissTimer;
    
    connect(dismissTimer, &QTimer::timeout, this, [this, id]() {
        removeNotification(id);
    });
    
    dismissTimer->setSingleShot(true);
    dismissTimer->start(durationMs);
    
    emit notificationsChanged();
}

void NotificationManager::removeNotification(const QString &id)
{
    // Find and remove notification
    for (int i = 0; i < m_notifications.size(); ++i) {
        if (m_notifications[i]["id"].toString() == id) {
            m_notifications.removeAt(i);
            break;
        }
    }
    
    // Clean up timer
    if (m_dismissTimers.contains(id)) {
        QTimer *timer = m_dismissTimers[id];
        m_dismissTimers.remove(id);
        timer->stop();
        delete timer;
    }
    
    emit notificationsChanged();
}

QString NotificationManager::generateId()
{
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}
