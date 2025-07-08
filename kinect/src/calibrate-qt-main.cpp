#include <iostream>
#include <bits/stdc++.h> 
#include <stdlib.h> 
#include <unistd.h> 
#include <string.h> 
#include <sys/types.h> 
#include <sys/socket.h> 
#include <arpa/inet.h> 
#include <netinet/in.h> 

#include <opencv2/imgproc.hpp>     // Pour cv::threshold, cv::cvtColor, etc.
#include <opencv2/imgcodecs.hpp>   // Pour imread/imwrite si utilisé
#include <opencv2/highgui.hpp>  

#include "calibrate-qt.hpp"
#include "utils.hpp"

#define PORT     5555
#define MAXLINE 1024 
#define MAX_UDP_SIZE 128 * 128

struct sockaddr_in servaddr;
struct sockaddr_in cliaddr;

int sockfd; 
char buffer[MAXLINE]; 
const char *new_frame = "NEW_FRAME"; 
const char *end_frame = "END_FRAME"; 

ssize_t err;

// Driver code 
int udp_server() { 
    // Creating socket file descriptor 
    if ( (sockfd = socket(AF_INET, SOCK_DGRAM, 0)) < 0 ) { 
        perror("socket creation failed"); 
        exit(EXIT_FAILURE); 
    } 
      
    memset(&servaddr, 0, sizeof(servaddr)); 
    memset(&cliaddr, 0, sizeof(cliaddr)); 
      
    // Filling server information 
    servaddr.sin_family = AF_INET; // IPv4
    servaddr.sin_addr.s_addr = INADDR_ANY; 
    servaddr.sin_port = htons(PORT); 

    cliaddr.sin_family = AF_INET;
    cliaddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    cliaddr.sin_port = htons(PORT);

    // Bind the socket with the server address 
    /*if (bind(sockfd, (const struct sockaddr *)&servaddr,  
            sizeof(servaddr)) < 0 )
    { 
        perror("bind failed"); 
        exit(EXIT_FAILURE); 
    }*/
      
    socklen_t len;
    int n; 
  
    len = sizeof(cliaddr);  //len is value/result 
  
    /*n = recvfrom(sockfd, (char *)buffer, MAXLINE,  
                MSG_WAITALL, ( struct sockaddr *) &cliaddr, 
                &len); 
    buffer[n] = '\0'; 
    printf("Client : %s\n", buffer);*/

    return 0; 
}

void send_buffer(cv::Mat depth_rgb)
{
    uint8_t* array;
    if (depth_rgb.isContinuous())
        array = depth_rgb.ptr<uint8_t>(0);

    /*for (int i = 0; i < depth_rgb.total() * depth_rgb.channels(); i++)
    {
        std::cout << array[i] << " ";
    }*/

    std::cout << "Sending NEW_FRAME signal" << std::endl;
    err = sendto(sockfd, (const char *)new_frame, strlen(new_frame),  
            MSG_DONTWAIT, (struct sockaddr*) &cliaddr, 
            sizeof(cliaddr));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Sending depth_map packets" << std::endl;
    size_t depth_len = depth_rgb.total() * depth_rgb.channels();
    size_t i = 0;
    for (; i < depth_len - MAX_UDP_SIZE; i += MAX_UDP_SIZE)
    {
        err = sendto(sockfd, array + i, MAX_UDP_SIZE, 
                        MSG_DONTWAIT, (const struct sockaddr *) &cliaddr, 
                        sizeof(cliaddr));
        if (err == -1)
        {
            std::cout << "err :" << err << std::endl;
            std::cout << "errno :" << errno << std::endl;
        }
        usleep(1000);
    }
    err = sendto(sockfd, array + i, depth_len - i, 
        MSG_DONTWAIT, (const struct sockaddr *) &cliaddr, 
        sizeof(cliaddr));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Sending END_FRAME signal" << std::endl;
    err = sendto(sockfd, (const char *)end_frame, strlen(end_frame),  
            MSG_DONTWAIT, (struct sockaddr*) &cliaddr, 
            sizeof(cliaddr));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Buffer sent" << std::endl;
}

cv::Mat depthmap_colorize(cv::Mat _depth, int min_depth, int max_depth)
{
    static auto cmap = get_cmap(5.f);
    cv::Mat_<uint16_t> depth16 = _depth;

    // Scale the depth image
    if (min_depth > 0 && max_depth > 0)
    {
        min_depth = std::clamp((int)(0.75f * min_depth), 0, 2047);
        max_depth = std::clamp((int)(1.25f * max_depth), 0, 2047);
        depth16.forEach([&](uint16_t &pixel, const int position[2]) {
            int value = (pixel - min_depth) * 2048 / (max_depth - min_depth);
            pixel = std::clamp(value, 0, 2047);
        });
    }

    // Colorize the unwrapped depth image
    cv::Mat depth_rgb(depth16.rows, depth16.cols, CV_8UC3);
    depth16.forEach([&](uint16_t &pixel, const int position[2]) {
        rgb8 color = cmap[pixel];
        depth_rgb.at<cv::Vec3b>(position[0], position[1]) = cv::Vec3b(color.r, color.g, color.b); }
    );

    send_buffer(depth_rgb);

    return depth_rgb;
}

cv::Mat depthmap_manual_grayscale(cv::Mat _depth, int min_depth, int max_depth)
{
    static auto cmap = get_cmap(5.f);
    cv::Mat_<uint16_t> depth16 = _depth;

    // Scale the depth image
    if (min_depth > 0 && max_depth > 0)
    {
        min_depth = std::clamp((int)(0.75f * min_depth), 0, 2047);
        max_depth = std::clamp((int)(1.25f * max_depth), 0, 2047);
        depth16.forEach([&](uint16_t &pixel, const int position[2]) {
            int value = (pixel - min_depth) * 2048 / (max_depth - min_depth);
            pixel = std::clamp(value, 0, 2047);
        });
    }

    // Colorize the unwrapped depth image
    cv::Mat depth_rgb(depth16.rows, depth16.cols, CV_8UC1);
    depth16.forEach([&](uint16_t &pixel, const int position[2]) {
        rgb8 color = cmap[pixel];
        auto grayscale = static_cast<uchar>(
            0.299 * color.r + 0.587 * color.g + 0.114 * color.b
        );
        depth_rgb.at<uchar>(position[0], position[1]) = grayscale;
    }
    );

    send_buffer(depth_rgb);

    return depth_rgb;
}

cv::Mat depthmap_grayscale(cv::Mat _depth, int min_depth, int max_depth)
{
    // Étape 1 : Convertir vers 8 bits avec échelle entre min_depth et max_depth
    cv::Mat depth_gray;
    _depth.convertTo(depth_gray, CV_8UC1, 255.0 / (max_depth - min_depth), -min_depth * 255.0 / (max_depth - min_depth));

    // Clamp les valeurs hors plage (facultatif mais recommandé)
    cv::threshold(depth_gray, depth_gray, 255, 255, cv::THRESH_TRUNC);
    cv::threshold(depth_gray, depth_gray, 0, 0, cv::THRESH_TOZERO);

    // Étape 2 : (facultatif) convertir en BGR si besoin pour affichage couleur
    cv::Mat depth_bgr;
    cv::cvtColor(depth_gray, depth_bgr, cv::COLOR_GRAY2BGR);

    // Envoie des données (par exemple depth_gray ou depth_bgr)
    send_buffer(depth_gray);  // ou send_buffer(depth_bgr);

    return depth_bgr;
}

int main(int argc, char** argv)
{
    udp_server();

    // Create a QT application with a window and side-by-side RGB and Depth panel
    QApplication app(argc, argv);

    QCalibrationApp win;
    win.setOnDepthFrameChange(depthmap_grayscale);
    win.show();

    return app.exec();
}