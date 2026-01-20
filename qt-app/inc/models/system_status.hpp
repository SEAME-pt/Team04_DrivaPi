/**
 * @file system_status.hpp
 * @brief System status and diagnostics model for HMI
 * 
 * Exposes real-time connection state, performance metrics, and system information
 * to the QML frontend via Qt properties and signals.
 */

#pragma once

#include <QObject>
#include <QString>
#include <QTimer>
#include <atomic>

class SystemStatus : public QObject
{
    Q_OBJECT
    
    Q_PROPERTY(QString connectionState READ connectionState NOTIFY connectionStateChanged)
    Q_PROPERTY(QString connectionMode READ connectionMode NOTIFY connectionModeChanged)
    Q_PROPERTY(int frameRate READ frameRate NOTIFY frameRateChanged)
    Q_PROPERTY(double latency READ latency NOTIFY latencyChanged)
    Q_PROPERTY(int signalsStaleness READ signalsStaleness NOTIFY stalnessChanged)
    Q_PROPERTY(int cpuUsage READ cpuUsage NOTIFY cpuUsageChanged)
    Q_PROPERTY(int memoryUsage READ memoryUsage NOTIFY memoryUsageChanged)
    Q_PROPERTY(int renderingFps READ renderingFps NOTIFY renderingFpsChanged)

public:
    explicit SystemStatus(QObject *parent = nullptr);
    ~SystemStatus() override;
    
    // Getters
    QString connectionState() const { return m_connectionState; }
    QString connectionMode() const { return m_connectionMode; }
    int frameRate() const { return m_frameRate; }
    double latency() const { return m_latency; }
    int signalsStaleness() const { return m_signalsStaleness; }
    int cpuUsage() const { return m_cpuUsage; }
    int memoryUsage() const { return m_memoryUsage; }
    int renderingFps() const { return m_renderingFps; }
    
    // Setters (for internal updates)
    void setConnectionState(const QString &state);
    void setConnectionMode(const QString &mode);
    void setFrameRate(int fps);
    void setLatency(double ms);
    void setSignalsStaleness(int count);
    void setCpuUsage(int percent);
    void setMemoryUsage(int percent);
    void setRenderingFps(int fps);
    
    // Frame counting for FPS calculation
    void recordFrame();

signals:
    void connectionStateChanged();
    void connectionModeChanged();
    void frameRateChanged();
    void latencyChanged();
    void stalnessChanged();
    void cpuUsageChanged();
    void memoryUsageChanged();
    void renderingFpsChanged();

private slots:
    void updateSystemMetrics();
    void calculateFrameRate();

private:
    // Connection properties
    QString m_connectionState;      // "connected", "disconnected", "connecting"
    QString m_connectionMode;       // "CAN", "KUKSA"
    double m_latency;              // milliseconds
    int m_signalsStaleness;        // count of stale signals
    
    // Performance metrics
    int m_frameRate;               // frames per second
    int m_cpuUsage;                // percentage
    int m_memoryUsage;             // percentage
    int m_renderingFps;            // QML rendering FPS
    
    // Frame counting
    std::atomic<int> m_frameCount{0};
    
    // Timers
    QTimer *m_metricsTimer;        // Updates system metrics every 1 sec
    QTimer *m_frameCountTimer;     // Calculates FPS every 1 sec
};
