import { Audio } from 'expo-av';
import * as Haptics from 'expo-haptics';
import { Client } from 'paho-mqtt';
import React, { useEffect, useRef, useState } from 'react';
import { ScrollView, StyleSheet, Text, View } from 'react-native';
import { SafeAreaProvider, SafeAreaView } from 'react-native-safe-area-context';

const BROKER_HOST = '10.21.220.251';
const BROKER_PORT = 9001;
const TOPIC = 'vehicles/emergency';

export default function App() {
  const [status, setStatus] = useState('Disconnected');
  const [isEmergency, setIsEmergency] = useState(false);
  const [flashColor, setFlashColor] = useState('#ff0000');

  const flashIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const vibrationIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const soundObjectRef = useRef<Audio.Sound | null>(null);

  const playAlertSound = async () => {
    try {
      const { sound } = await Audio.Sound.createAsync(
        { uri: 'https://actions.google.com/sounds/v1/alarms/digital_watch_alarm_long.ogg' }
      );
      soundObjectRef.current = sound;
      await sound.setIsLoopingAsync(true);
      await sound.playAsync();
    }
    catch (error) {
      console.log('Error playing sound:', error);
    }
  };

  const stopAlertSound = async () => {
    if (soundObjectRef.current) {
      try {
        await soundObjectRef.current.stopAsync();
        await soundObjectRef.current.unloadAsync();
        soundObjectRef.current = null;
      }
      catch (e) {
        console.log(e);
      }
    }
  };

  const triggerEmergencyEffects = () => {
    setIsEmergency(true);
    playAlertSound();

    if (flashIntervalRef.current)
      clearInterval(flashIntervalRef.current);
    if (vibrationIntervalRef.current)
      clearInterval(vibrationIntervalRef.current);

    flashIntervalRef.current = setInterval(() => {
      setFlashColor((prev) => (prev === '#ff0000' ? '#000000' : '#ff0000'));
    }, 250);

    vibrationIntervalRef.current = setInterval(() => {
      Haptics.notificationAsync(Haptics.NotificationFeedbackType.Error);
    }, 500);

    setTimeout(() => {
      if (flashIntervalRef.current)
        clearInterval(flashIntervalRef.current);
      if (vibrationIntervalRef.current)
        clearInterval(vibrationIntervalRef.current);
      stopAlertSound();
      setIsEmergency(false);
    }, 5000);
  };

  useEffect(() => {
    setStatus('Connecting...');
    const clientId = `expo_client_${Math.random().toString(16).substr(2, 8)}`;
    //const client = new Client(BROKER_HOST, Number(BROKER_PORT), clientId);
	const client = new Client(BROKER_HOST, Number(BROKER_PORT), "/mqtt", clientId);

    client.onConnectionLost = (responseObject) => {
      if (responseObject.errorCode !== 0)
        setStatus('Disconnected');
    };

    client.onMessageArrived = (message) => {
      if (message.payloadString.trim() === 'EMERGENCY_ACTIVE') {
        triggerEmergencyEffects();
      }
    };

    client.connect({
      onSuccess: () => {
        setStatus('Connected!');
        client.subscribe(TOPIC);
      },
      onFailure: (err) => {
        setStatus('Connection Error');
        console.log('Detalhes do erro MQTT:', err);
      },
      useSSL: false,
      userName: 'phoneapp',
      password: 'drivapi',
      timeout: 10,
      cleanSession: true,
    });

    return () => {
      if (client && client.isConnected())
        client.disconnect();
      if (flashIntervalRef.current)
        clearInterval(flashIntervalRef.current);
      if (vibrationIntervalRef.current)
        clearInterval(vibrationIntervalRef.current);
      stopAlertSound();
    };
  }, []);

  const dynamicBackgroundColor = isEmergency ? flashColor : '#4CD964';

  return (
    <SafeAreaProvider>
      <SafeAreaView style={[styles.container, { backgroundColor: dynamicBackgroundColor }]}>
        <View style={styles.header}>
          <Text style={[styles.title, isEmergency && { color: '#fff' }]}>
            Emergency Vehicle Alert
          </Text>
          <Text style={[styles.status, status === 'Connected!' ? styles.connected : styles.disconnected]}>
            ● {status}
          </Text>
        </View>
        <View style={styles.centerContainer}>
          {isEmergency ? (
            <View style={styles.alertBox}>
              <Text style={styles.emergencyTextIcon}>⚠️</Text>
              <Text style={styles.emergencyTitleText}>EMERGENCY VEHICLE AHEAD</Text>
              <Text style={styles.emergencySubText}>MOVE OVER SAFELY</Text>
            </View>
          ) : (
            <ScrollView contentContainerStyle={styles.safeBox}>
              <Text style={styles.cuteAmbulanceEmoji}>🚑</Text>
              <Text style={styles.safeTitleText}>No Emergency Vehicles Around</Text>
            </ScrollView>
          )}
        </View>
      </SafeAreaView>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
  header: { padding: 20, alignItems: 'center', borderBottomWidth: 1, borderBottomColor: 'rgba(255,255,255,0.2)', flexDirection: 'row', justifyContent: 'space-between' },
  title: { fontSize: 18, fontWeight: 'bold', color: '#fff' },
  status: { fontSize: 13, fontWeight: '600' },
  connected: { color: '#004d00' },
  disconnected: { color: '#8b0000' },
  centerContainer: { flex: 1, paddingHorizontal: 30, justifyContent: 'center' },
  safeBox: { alignItems: 'center', justifyContent: 'center', flexGrow: 1 },
  cuteAmbulanceEmoji: { fontSize: 120, marginBottom: 25 },
  safeTitleText: { fontSize: 26, fontWeight: 'bold', color: '#fff', textAlign: 'center', marginBottom: 20 },
  alertBox: { alignItems: 'center' },
  emergencyTextIcon: { fontSize: 90, marginBottom: 20 },
  emergencyTitleText: { fontSize: 32, fontWeight: '900', color: '#fff', textAlign: 'center', marginBottom: 10, letterSpacing: 1 },
  emergencySubText: { fontSize: 18, fontWeight: 'bold', color: '#fff', textAlign: 'center', opacity: 0.9 }
});
