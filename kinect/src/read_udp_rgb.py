import socket
import numpy as np
import cv2
import matplotlib.pyplot as plt

# ==== Configuration ====
UDP_IP = "127.0.0.1"
UDP_PORT = 5556

IMG_WIDTH = 640
IMG_HEIGHT = 480
IMG_CHANNELS = 3
IMG_SIZE = IMG_WIDTH * IMG_HEIGHT * IMG_CHANNELS

TILE_SIZE = 128 * 128  # = 16384

# ==== Socket UDP ====
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((UDP_IP, UDP_PORT))

print(f"[INFO] UDP server listening on port {UDP_PORT}")

# ==== Fichier de log binaire ====
output_file = open("reception_rgb.bin", "wb")

# ==== Réception boucle ====
buffer = bytearray()
frame_started = False
i = 1

while True:
    data, addr = sock.recvfrom(65535)

    # Marqueurs de début/fin
    if data == b"NEW_FRAME":
        print("[INFO] Nouvelle image entrante.")
        output_file.write(b"NEW_FRAME\n")
        buffer = bytearray()
        frame_started = True
        continue

    elif data == b"END_FRAME":
        print("[INFO] Fin d'image reçue.")
        output_file.write(b"\nEND_FRAME\n")

        if frame_started:
            if len(buffer) != IMG_SIZE:
                print(f"[WARN] Image incomplète : {len(buffer)} bytes reçus.")
                continue

            # Conversion image et affichage
            img_array = np.frombuffer(buffer, dtype=np.uint8)
            img = img_array.reshape((IMG_HEIGHT, IMG_WIDTH, 3))
            if i == 1:
                plt.imshow(img)
                plt.show()
                i+=1
        else:
            print("[WARN] END_FRAME reçu sans NEW_FRAME")
        frame_started = False
        continue

    # Données d'image
    if frame_started:
        buffer.extend(data)
        output_file.write(data)
    else:
        print("[WARN] Paquet ignoré hors image active.")
