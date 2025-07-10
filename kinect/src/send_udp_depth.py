import socket
import time
import sys

# ==== Configuration ====
UDP_IP = "127.0.0.1"
UDP_PORT = 5555
MAX_UDP_SIZE = 65_000  # 16384 octets max par chunk

# ==== Socket ====
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

# ==== Lecture depuis reception.bin ====
if len(sys.argv) > 1:
    FILENAME = sys.argv[1]
else: 
    FILENAME = "reception_depth.bin"
while True:
    with open(FILENAME, "rb") as f:
        frame_data = bytearray()
        in_frame = False
        frame_count = 0

        while True:
            line = f.readline()
            if not line:
                print("[INFO] Fin du fichier atteinte.")
                break

            if line.strip() == b"NEW_FRAME":
                print(f"[INFO] Début d'une nouvelle frame...")
                frame_data = bytearray()
                in_frame = True
                continue

            elif line.strip() == b"END_FRAME":
                frame_data = frame_data[:-1]
                
                print(f"[INFO] Fin de la frame #{frame_count} — envoi UDP")

                # Envoyer NEW_FRAME
                sock.sendto(b"NEW_FRAME", (UDP_IP, UDP_PORT))
                time.sleep(0.001)

                # Envoyer en paquets de MAX_UDP_SIZE
                for i in range(0, len(frame_data), MAX_UDP_SIZE):
                    chunk = frame_data[i:i + MAX_UDP_SIZE]
                    sock.sendto(chunk, (UDP_IP, UDP_PORT))
                    time.sleep(0.001)

                # Envoyer END_FRAME
                sock.sendto(b"END_FRAME", (UDP_IP, UDP_PORT))
                time.sleep(0.1)

                print(f"[INFO] Frame #{frame_count} envoyée ({len(frame_data)} octets)")
                frame_count += 1
                in_frame = False
                continue

            # Ajout des données binaires
            if in_frame:
                frame_data.extend(line)
