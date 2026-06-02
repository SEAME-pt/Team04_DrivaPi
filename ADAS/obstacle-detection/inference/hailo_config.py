from pathlib import Path

class HailoConfig:
    CLASSES = [
        '50_sign', '80_sign', 'gate', 'crosswalk_sign', 'stop_sign', 
        'yield_sign', 'car', 'danger_sign', 'obstacle', 
        'traffic_light_green', 'traffic_light_off', 'traffic_light_red', 'traffic_light_yellow'
    ]
    
    UDP_IP = "127.0.0.1"
    UDP_PORT = 5555
    HEF_PATH = Path("yolo26_obstacle.hef")

    # Nomes dos VStreams do modelo estável atual
    OUT_SLICE1 = "yolo26_v9/slice1"
    OUT_SLICE2 = "yolo26_v9/slice2"
    OUT_ACT3   = "yolo26_v9/activation3"

    # ========================================================
    # CALIBRAÇÃO ADAPTADA PARA DINÂMICA ALTA
    # ========================================================
    PWM_MAX = 40        # Teto absoluto
    PWM_80 = 30         # Velocidade limite para sinal de 80
    PWM_50 = 20         # Velocidade limite para sinal de 50
    PWM_CRUISE = 15     # Velocidade padrão em pista limpa
    PWM_SLOW = 10       # Velocidade base para aproximações de paragem
    PWM_CAUTION = 12    # Velocidade limite padrão em zonas de pedestres
    
    UDP_INTERVAL = 0.05 
    H_EMERGENCY = 0.35
    H_STOP = 0.12       # Ponto ótimo de blackout ótico medido a 40cm
    
    FORWARD = 1
    BRAKE = 3
    MID_SERVO = 90
