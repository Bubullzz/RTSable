#include "udp_server.hpp"

int sockfd_depth;
struct sockaddr_in servaddr_depth;
struct sockaddr_in cliaddr_depth;

int sockfd_rgb;
struct sockaddr_in servaddr_rgb;
struct sockaddr_in cliaddr_rgb;

const char* new_frame = "NEW_FRAME";
const char* end_frame = "END_FRAME";

ssize_t err;

void udp_server_depth()
{
    sockfd_depth = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd_depth < 0)
    {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&servaddr_depth, 0, sizeof(servaddr_depth));
    memset(&cliaddr_depth, 0, sizeof(cliaddr_depth));

    servaddr_depth.sin_family = AF_INET;
    servaddr_depth.sin_addr.s_addr = INADDR_ANY;
    servaddr_depth.sin_port = htons(PORT_DEPTH);

    cliaddr_depth.sin_family = AF_INET;
    cliaddr_depth.sin_addr.s_addr = inet_addr("127.0.0.1");
    cliaddr_depth.sin_port = htons(PORT_DEPTH);
}

void udp_server_rgb()
{
    sockfd_rgb = socket(AF_INET, SOCK_DGRAM, 0);
    if (sockfd_rgb < 0)
    {
        perror("socket creation failed");
        exit(EXIT_FAILURE);
    }

    memset(&servaddr_rgb, 0, sizeof(servaddr_rgb));
    memset(&cliaddr_rgb, 0, sizeof(cliaddr_rgb));

    servaddr_rgb.sin_family = AF_INET;
    servaddr_rgb.sin_addr.s_addr = INADDR_ANY;
    servaddr_rgb.sin_port = htons(PORT_RGB);

    cliaddr_rgb.sin_family = AF_INET;
    cliaddr_rgb.sin_addr.s_addr = inet_addr("127.0.0.1");
    cliaddr_rgb.sin_port = htons(PORT_RGB);
}

void send_depth(cv::Mat depth_rgb)
{
    uint8_t* array;
    if (depth_rgb.isContinuous())
        array = depth_rgb.ptr<uint8_t>(0);

    std::cout << "Sending NEW_FRAME signal" << std::endl;
    err = sendto(sockfd_depth, new_frame, strlen(new_frame), MSG_DONTWAIT, (struct sockaddr*) &cliaddr_depth,
                 sizeof(cliaddr_depth));
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
        err = sendto(sockfd_depth, array + i, MAX_UDP_SIZE, MSG_DONTWAIT, (const struct sockaddr*) &cliaddr_depth, sizeof(cliaddr_depth));
        if (err == -1)
        {
            std::cout << "err :" << err << std::endl;
            std::cout << "errno :" << errno << std::endl;
        }
        usleep(1000);
    }
    err = sendto(sockfd_depth, array + i, depth_len - i, MSG_DONTWAIT, (const struct sockaddr*) &cliaddr_depth, sizeof(cliaddr_depth));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Sending END_FRAME signal" << std::endl;
    err = sendto(sockfd_depth, end_frame, strlen(end_frame), MSG_DONTWAIT, (struct sockaddr*) &cliaddr_depth,
                 sizeof(cliaddr_depth));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Buffer sent" << std::endl;
}

void send_rgb(cv::Mat depth_rgb)
{
    uint8_t* array;
    if (depth_rgb.isContinuous())
        array = depth_rgb.ptr<uint8_t>(0);

    std::cout << "Sending NEW_FRAME signal" << std::endl;
    err = sendto(sockfd_rgb, new_frame, strlen(new_frame), MSG_DONTWAIT, (struct sockaddr*) &cliaddr_rgb,
                 sizeof(cliaddr_rgb));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Sending rgb_video packets" << std::endl;
    size_t depth_len = depth_rgb.total() * depth_rgb.channels();
    size_t i = 0;
    for (; i < depth_len - MAX_UDP_SIZE; i += MAX_UDP_SIZE)
    {
        err = sendto(sockfd_rgb, array + i, MAX_UDP_SIZE, MSG_DONTWAIT, (const struct sockaddr*) &cliaddr_rgb, sizeof(cliaddr_rgb));
        if (err == -1)
        {
            std::cout << "err :" << err << std::endl;
            std::cout << "errno :" << errno << std::endl;
        }
        usleep(1000);
    }
    err = sendto(sockfd_rgb, array + i, depth_len - i, MSG_DONTWAIT, (const struct sockaddr*) &cliaddr_rgb, sizeof(cliaddr_rgb));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Sending END_FRAME signal" << std::endl;
    err = sendto(sockfd_rgb, end_frame, strlen(end_frame), MSG_DONTWAIT, (struct sockaddr*) &cliaddr_rgb,
                 sizeof(cliaddr_rgb));
    if (err == -1)
    {
        std::cout << "err :" << err << std::endl;
        std::cout << "errno :" << errno << std::endl;
    }
    usleep(1000);

    std::cout << "Buffer sent" << std::endl;
}
