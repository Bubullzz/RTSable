#pragma once

#include <iostream>
#include <vector>
#include <cstring>
#include <arpa/inet.h>
#include <unistd.h>

#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp>
#include <opencv2/imgproc.hpp>

#define UDP_IP "127.0.0.1"
#define UDP_PORT 5556
#define IMG_WIDTH 640
#define IMG_HEIGHT 480
#define IMG_CHANNELS 3
#define IMG_SIZE (IMG_WIDTH * IMG_HEIGHT * IMG_CHANNELS)
#define MAX_PACKET_SIZE 65535

void udp_client_rgb();

cv::Mat receive_rgb();
