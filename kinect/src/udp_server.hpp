#pragma once

#include <arpa/inet.h>
//#include <bits/stdc++.h>
#include <iostream>
#include <netinet/in.h>
#include <stdlib.h>
#include <string.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <opencv2/highgui.hpp>
#include <opencv2/imgcodecs.hpp> // Pour imread/imwrite si utilisé
#include <opencv2/imgproc.hpp> // Pour cv::threshold, cv::cvtColor, etc.

#define PORT_DEPTH 5555
#define PORT_RGB 5556
#define MAX_UDP_SIZE 16384 // 128 * 128

void udp_server_depth();

void udp_server_rgb();

void send_depth(cv::Mat depth_rgb);

void send_rgb(cv::Mat depth_rgb);
