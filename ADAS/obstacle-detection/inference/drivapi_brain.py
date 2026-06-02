"""
Decisão ADAS: Traduz deteções YOLO em controlos PWM determinísticos.
Integra: Filtro assimétrico, evaporação de perigo, clamp defensivo e prioridades de comando.
"""

import socket
import time
from dataclasses import dataclass
from typing import Iterable
from hailo_config import HailoConfig as cfg

class PersistenceTracker:
    """Reage no 1º frame (Zero Latência) e degrada o perigo se o sensor falhar."""
    def __init__(self, hold_frames: int):
        self.max_hold = hold_frames
        self.frames_left = 0
        self.active_det = None

    def update(self, detected: bool, det_obj=None) -> bool:
        if detected:
            self.frames_left = self.max_hold
            self.active_det = det_obj
            return True
        else:
            if self.frames_left > 0:
                self.frames_left -= 1
                
                # Evaporação progressiva do perigo para evitar ghost braking
                if self.active_det:
                    h_current = self.active_det.ymax - self.active_det.ymin
                    self.active_det = Detection(
                        label=self.active_det.label,
                        ymin=self.active_det.ymin,
                        ymax=self.active_det.ymin + (h_current * 0.88),  # Encolhe a altura em 12% por frame
                        confidence=self.active_det.confidence * 0.90     # Reduz confiança em 10% por frame
                    )
                return True
            else:
                self.active_det = None
                return False

@dataclass
class Detection:
    label: str; ymin: float; ymax: float; confidence: float

class DrivaPiBrain:
    def __init__(self) -> None:
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.target = (cfg.UDP_IP, cfg.UDP_PORT)
        
        self.current_pwm = 0.0     
        self.speed_limit = cfg.PWM_CRUISE
        self.limit_expiry = 0.0      
        
        # Gestão inteligente do STOP
        self.stop_at = 0.0         # Carimbo de tempo para quando a paragem deve iniciar
        self.last_stop_time = 0.0  # Janela de proteção contra re-bloqueio do sinal de STOP
        
        self.last_udp_send_time = 0.0
        self.last_sent_msg = ""
        self.last_log = 0

        # Alocação de Trackers
        self.trackers = {}
        for label in cfg.CLASSES:
            if label in ["car", "obstacle", "gate"]:
                self.trackers[label] = PersistenceTracker(hold_frames=6)
            else:
                self.trackers[label] = PersistenceTracker(hold_frames=4)

        self.accel_rate = 0.5         
        self.decel_rate = 9.0         

    def process_detections(self, detections: Iterable[Detection]):
        now = time.time()
        
        # Expiração de limites de velocidade de sinalização (50 / 80)
        if now > self.limit_expiry and self.speed_limit != cfg.PWM_CRUISE:
            print("[BRAIN] Limite de velocidade expirado. Retornando para Cruise.")
            self.speed_limit = cfg.PWM_CRUISE

        # --- CONTROLO SEQUENCIAL DO SINAL DE STOP (Truque do Atraso por Software) ---
        if self.stop_at > 0.0:
            if now < self.stop_at:
                # FASE 1: O carro viu o STOP mas continua a andar um bocado para se aproximar da linha
                self.current_pwm = cfg.PWM_SLOW
                self.send_command(int(self.current_pwm), cfg.FORWARD, cfg.PWM_SLOW, "APPROACHING_STOP_LINE")
                return
            elif now < self.stop_at + 3.0:
                # FASE 2: O temporizador de aproximação esgotou, ativa a paragem obrigatória de 3 segundos
                self.current_pwm = 0.0
                self.send_command(0, cfg.BRAKE, 0, "STOP_TIMER_ACTIVE")
                return
            else:
                # FASE 3: Paragem concluída. Limpa os estados e ativa o cooldown do STOP
                print("[BRAIN] Paragem de 3s concluída. Retomando marcha.")
                self.last_stop_time = now
                self.stop_at = 0.0

        # 1. Captura imediata e atualização dos Trackers (Alinhado a 0.20 com o teu main_inference)
        detected_this_frame = {d.label for d in detections if d.confidence > 0.20}
        confirmed_detections = []
        
        for label in cfg.CLASSES:
            is_present = label in detected_this_frame
            current_det = next((d for d in detections if d.label == label), None)
            
            if self.trackers[label].update(is_present, current_det):
                valid_det = current_det if current_det else self.trackers[label].active_det
                if valid_det:
                    confirmed_detections.append(valid_det)

        temp_target = self.speed_limit
        reason = "NORMAL"
        
        # Hierarquia de prioridades explícita para evitar conflitos de atuação
        # 0 = Normal, 1 = Cautela, 2 = Following (Proporcional), 3 = Emergência/STOP
        current_priority = 0 

        # 2. Processamento das Deteções Confirmadas
        for det in confirmed_detections:
            h = round(det.ymax - det.ymin, 3)

            # --- PRIORIDADE 3: PARAGEM TOTAL / EMERGÊNCIA ---
            if det.label in ["gate", "traffic_light_red"] and h > cfg.H_STOP:
                if current_priority <= 3:
                    temp_target = 0
                    reason = f"STOP({det.label})"
                    current_priority = 3
            
            elif det.label == "stop_sign" and h > cfg.H_STOP:
                # Só agenda uma nova paragem se o carro não estiver em imunidade de pós-stop
                if now - self.last_stop_time > 6.0:
                    if current_priority <= 3:
                        # Agenda a paragem real para daqui a 0.3 segundos para deixar o carro deslizar mais um bocado
                        self.stop_at = now + 0.3
                        temp_target = cfg.PWM_SLOW
                        reason = "STOP_SIGN_DETECTED"
                        current_priority = 3
                else:
                    # Imunidade pós-stop ativa: força o carro a andar devagar para desimpedir a zona do sinal
                    if current_priority < 1:
                        temp_target = min(temp_target, cfg.PWM_SLOW)
                        reason = "LEAVING_STOP_ZONE"
                        current_priority = 1

            elif det.label in ["car", "obstacle"] and h > cfg.H_EMERGENCY:
                if current_priority <= 3:
                    temp_target = 0
                    reason = f"EMERGENCY({det.label})"
                    current_priority = 3

            # --- PRIORIDADE 2: SEGUIRE PROPORCIONAL (Carros/Obstáculos) ---
            elif det.label in ["car", "obstacle"] and h > 0.15:
                if current_priority < 2:
                    ratio = (h - 0.15) / (cfg.H_EMERGENCY - 0.15)
                    ratio = max(0.0, min(ratio, 1.0))
                    
                    temp_target = min(temp_target, cfg.PWM_CRUISE - (cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio)
                    reason = f"FOLLOWING({det.label}_h={h})"
                    current_priority = 2

            # --- PRIORIDADE 1: ZONAS DE CAUTELA (Abrandamento progressivo real na pista) ---
            elif det.label in ["crosswalk_sign", "yield_sign", "danger_sign", "traffic_light_yellow", "stop_sign"]:
                if current_priority < 1:
                    # Começa a travar suavemente a partir de h=0.07 e vai descendo até ao PWM_SLOW (6)
                    h_start = 0.07
                    h_end = cfg.H_STOP if det.label == "stop_sign" else 0.25
                    
                    if h >= h_start:
                        ratio = (h - h_start) / (h_end - h_start)
                        ratio = max(0.0, min(ratio, 1.0))
                        
                        # Alarga a dinâmica de travagem usando o PWM_SLOW como alvo de segurança mínimo
                        caution_pwm = cfg.PWM_CRUISE - ((cfg.PWM_CRUISE - cfg.PWM_SLOW) * ratio)
                        temp_target = min(temp_target, caution_pwm)
                        reason = f"CAUTION({det.label}_h={h})"
                        current_priority = 1

	   # --- PRIORIDADE 0: ALTERAÇÕES DE BASELINE (Sinais de Velocidade) ---
            elif det.label == "50_sign": 
                self.speed_limit = cfg.PWM_50    # FIX: Atualizado de PWM_CRUISE para PWM_50
                self.limit_expiry = now + 10.0
            elif det.label == "80_sign": 
                self.speed_limit = cfg.PWM_80    # FIX: Atualizado de PWM_HIGH para PWM_80
                self.limit_expiry = now + 10.0
            elif det.label == "traffic_light_green":
                self.speed_limit = cfg.PWM_CRUISE
		
        # 3. Execução da Rampa Adaptativa de PWM
        if self.current_pwm < temp_target:
            self.current_pwm = min(self.current_pwm + self.accel_rate, temp_target)
        elif self.current_pwm > temp_target:
            if temp_target == 0:
                self.current_pwm = 0  # Corte elétrico imediato em travagens de emergência
            else:
                self.current_pwm = max(self.current_pwm - self.decel_rate, temp_target)

        final = int(self.current_pwm)
        self.send_command(final, cfg.FORWARD if final > 0 else cfg.BRAKE, temp_target, reason)

    def send_command(self, speed, direction, target_frame, reason):
        now = time.time()
        msg = f"{int(speed)},{int(direction)},{cfg.MID_SERVO}"
        
        is_emergency = "STOP" in reason or "EMERGENCY" in reason or speed == 0
        time_passed = (now - self.last_udp_send_time) >= cfg.UDP_INTERVAL
        msg_changed = msg != self.last_sent_msg

        # Envia pacotes imediatamente se for emergência ou se o comando mudar de estado
        if is_emergency or msg_changed or time_passed:
            self.sock.sendto(msg.encode("utf-8"), self.target)
            self.last_udp_send_time = now
            self.last_sent_msg = msg

        # Throttle de telemetria no terminal para não inundar o ecrã do Pi 5
        if now - self.last_log > 0.2:
            print(f"[FSM] PWM: {int(speed):02d} -> Target: {int(target_frame):02d} | Reason: {reason}")
            self.last_log = now
