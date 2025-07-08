import socket
import numpy as np
import time
from noise import pnoise2  # Requires 'noise' package (pip install noise)

UDP_IP = "127.0.0.1"
UDP_PORT = 5555
WIDTH, HEIGHT = 640, 480  # Frame dimensions
MAX_UDP_SIZE = 128 * 128 # Maximum safe UDP payload size

SCALE = 0.1  # Adjust for noise granularity
OCTAVES = 6   # More octaves = more detail

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
time_offset = 0.0
evolution_speed = 0.002  # How fast the noise evolves

current_value = 0
print(f"UDP Perlin noise stream started on {UDP_IP}:{UDP_PORT}")

def generate_perlin_frame(offset):
    # Generate all coordinates at once
    y_coords, x_coords = np.mgrid[0:HEIGHT, 0:WIDTH]
    
    # Vectorized Perlin noise calculation
    # Note: This requires a vectorized version of pnoise2
    # If using noise.pnoise2, we'll need to use np.vectorize
    noise_func = np.vectorize(lambda x, y: pnoise2(x * SCALE, y * SCALE + offset, octaves=OCTAVES))
    frame = noise_func(x_coords, y_coords)
    
    # Normalize to 0-255
    frame_normalized = ((frame - frame.min()) / (frame.max() - frame.min()) * 255).astype(np.uint8)
    
    for i in range(HEIGHT):
        frame_normalized[i][0] = 0
        frame_normalized[i][1] = 0
        frame_normalized[i][2] = 0
        frame_normalized[i][-1] = 0
        frame_normalized[i][-2] = 0
        frame_normalized[i][-3] = 0
    for j in range(WIDTH):
        frame_normalized[0][j] = 0
        frame_normalized[1][j] = 0
        frame_normalized[2][j] = 0
        frame_normalized[-1][j] = 0
        frame_normalized[-2][j] = 0
        frame_normalized[-3][j] = 0
    return frame_normalized

while True:
    frame = generate_perlin_frame(time_offset)
    frame_bytes = frame.tobytes()
    sock.sendto(b'NEW_FRAME', (UDP_IP, UDP_PORT))  # Signal new frame

    time.sleep(0.001) 
    # Split into chunks
    for i in range(0, len(frame_bytes), MAX_UDP_SIZE):
        chunk = frame_bytes[i:i + MAX_UDP_SIZE]
        sock.sendto(chunk, (UDP_IP, UDP_PORT))
        time.sleep(0.001) 

    time_offset += evolution_speed

    sock.sendto(b'END_FRAME', (UDP_IP, UDP_PORT))
    print("Sent END_FRAME signal")
    print(f"Sent frame (value: {current_value})")

    time.sleep(0.01)
