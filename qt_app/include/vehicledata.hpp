#ifndef VEHICLEDATA_HPP
#define VEHICLEDATA_HPP

#include <QObject>
#include <QString>

class VehicleData : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString gear READ gear WRITE setGear NOTIFY gearChanged)
    Q_PROPERTY(int speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(double energy READ energy WRITE setEnergy NOTIFY energyChanged)
    Q_PROPERTY(int battery READ battery WRITE setBattery NOTIFY batteryChanged)
    Q_PROPERTY(int temperature READ temperature WRITE setTemperature NOTIFY temperatureChanged)
    Q_PROPERTY(int distance READ distance WRITE setDistance NOTIFY distanceChanged)
    Q_PROPERTY(bool autonomousMode READ autonomousMode WRITE setAutonomousMode NOTIFY autonomousModeChanged)

public:
    explicit VehicleData(QObject *parent = nullptr);
    ~VehicleData() override;

    Q_INVOKABLE void resetTrip();

    // Getters
	int     getSpeed() const;
	double  getEnergy() const;
	int     getBattery() const;
	int     getDistance() const;
    int     getTemperature() const;
    QString getGear() const;
    bool    getAutonomousMode() const;

    // Setters
    void    setSpeed(int speed);
    void    setEnergy(double energy);
    void    setBattery(int battery);
    void    setDistance(int distance);
    void    setGear(const QString &gear);
    void    setTemperature(int temperature);
    void    setAutonomousMode(bool mode);

    // Q_INVOKABLE methods - callable from QML
    Q_INVOKABLE void toggleAutonomousMode();
    Q_INVOKABLE void resetValues();
    Q_INVOKABLE void changeGearUp();
    Q_INVOKABLE void changeGearDown();

signals:
    void speedChanged();
    void energyChanged();
    void batteryChanged();
    void distanceChanged();
    void temperatureChanged();
    void gearChanged();
    void autonomousModeChanged();

private:
    // Member variables
    int     m_speed;
    double  m_energy;
    int     m_battery;
    int     m_distance;
    QString m_gear;
    int     m_temperature;
    bool    m_autonomousMode;

    // Helper methods
    int getGearIndex() const;
};

#endif // VEHICLEDATA_HPP
