#include "udp_client.hpp"

namespace {
    int sockfd;
    struct sockaddr_in servaddr{};
    std::vector<uint8_t> image_buffer;
    bool frame_started = false;
}

void udp_client_rgb() {
    // Création socket
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd < 0)
    {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }

    servaddr.sin_family = AF_INET;
    servaddr.sin_addr.s_addr = inet_addr(UDP_IP);
    servaddr.sin_port = htons(UDP_PORT);

    int err = bind(sockfd, (const struct sockaddr*)&servaddr, sizeof(servaddr));
    if (err < 0) {
        perror("bind failed");
        exit(EXIT_FAILURE);
    }

    std::cout << "[INFO] UDP client listening on port " << UDP_PORT << std::endl;
}

cv::Mat receive_rgb()
{
    std::cout << "In receive" << std::endl;
    printf("In receive");
    char buffer[MAX_PACKET_SIZE];
    socklen_t len = sizeof(servaddr);

    while (true) {
        ssize_t n = recvfrom(sockfd, buffer, MAX_PACKET_SIZE, 0, (struct sockaddr*)&servaddr, &len);
        if (n <= 0) 
        {
            std::cout << "Received nothing" << std::endl;
        }//continue;

        std::string data(buffer, buffer + n);

        if (data == "NEW_FRAME") {
            image_buffer.clear();
            frame_started = true;
            continue;
        } else if (data == "END_FRAME") {
            if (frame_started) {
                if (image_buffer.size() != IMG_SIZE) {
                    std::cerr << "[WARN] Image incomplète : " << image_buffer.size() << " bytes reçus." << std::endl;
                    frame_started = false;
                    return cv::Mat();
                }

                cv::Mat img(IMG_HEIGHT, IMG_WIDTH, CV_8UC3, image_buffer.data());
                frame_started = false;
                return img.clone();
            } else {
                std::cerr << "[WARN] END_FRAME reçu sans NEW_FRAME" << std::endl;
            }
            frame_started = false;
            continue;
        }

        if (frame_started) {
            image_buffer.insert(image_buffer.end(), buffer, buffer + n);
        } else {
            std::cerr << "[WARN] Paquet ignoré hors image active." << std::endl;
        }
    }
} 
