#include "calibrate-qt.hpp"
#include "utils.hpp"
#include "udp_server.hpp"

/*cv::Mat depthmap_colorize(cv::Mat _depth, int min_depth, int max_depth)
{
    static auto cmap = get_cmap(5.f);
    cv::Mat_<uint16_t> depth16 = _depth;

    // Scale the depth image
    if (min_depth > 0 && max_depth > 0)
    {
        min_depth = std::clamp((int) (0.75f * min_depth), 0, 2047);
        max_depth = std::clamp((int) (1.25f * max_depth), 0, 2047);
        depth16.forEach(
                [&](uint16_t& pixel, const int position[2])
                {
                    int value = (pixel - min_depth) * 2048 / (max_depth - min_depth);
                    pixel = std::clamp(value, 0, 2047);
                });
    }

    // Colorize the unwrapped depth image
    cv::Mat depth_rgb(depth16.rows, depth16.cols, CV_8UC3);
    depth16.forEach(
            [&](uint16_t& pixel, const int position[2])
            {
                rgb8 color = cmap[pixel];
                depth_rgb.at<cv::Vec3b>(position[0], position[1]) = cv::Vec3b(color.r, color.g, color.b);
            });

    send_depth(depth_rgb, sockfd_depth);

    return depth_rgb;
}*/

/*cv::Mat depthmap_manual_grayscale(cv::Mat _depth, int min_depth, int max_depth)
{
    static auto cmap = get_cmap(5.f);
    cv::Mat_<uint16_t> depth16 = _depth;

    // Scale the depth image
    if (min_depth > 0 && max_depth > 0)
    {
        min_depth = std::clamp((int) (0.75f * min_depth), 0, 2047);
        max_depth = std::clamp((int) (1.25f * max_depth), 0, 2047);
        depth16.forEach(
                [&](uint16_t& pixel, const int position[2])
                {
                    int value = (pixel - min_depth) * 2048 / (max_depth - min_depth);
                    pixel = std::clamp(value, 0, 2047);
                });
    }

    // Colorize the unwrapped depth image
    cv::Mat depth_rgb(depth16.rows, depth16.cols, CV_8UC1);
    depth16.forEach(
            [&](uint16_t& pixel, const int position[2])
            {
                rgb8 color = cmap[pixel];
                auto grayscale = static_cast<uchar>(0.299 * color.r + 0.587 * color.g + 0.114 * color.b);
                depth_rgb.at<uchar>(position[0], position[1]) = grayscale;
            });

    send_depth(depth_rgb, sockfd_depth);

    return depth_rgb;
}*/

cv::Mat depthmap_grayscale(cv::Mat _depth, int min_depth, int max_depth)
{
    // Étape 1 : Convertir vers 8 bits avec échelle entre min_depth et max_depth
    cv::Mat depth_gray;
    _depth.convertTo(depth_gray, CV_8UC1, 255.0 / (max_depth - min_depth),
                     -min_depth * 255.0 / (max_depth - min_depth));

    // Clamp les valeurs hors plage (facultatif mais recommandé)
    cv::threshold(depth_gray, depth_gray, 255, 255, cv::THRESH_TRUNC);
    cv::threshold(depth_gray, depth_gray, 0, 0, cv::THRESH_TOZERO);

    // Étape 2 : (facultatif) convertir en BGR si besoin pour affichage couleur
    cv::Mat depth_bgr;
    cv::cvtColor(depth_gray, depth_bgr, cv::COLOR_GRAY2BGR);

    // Envoie des données (par exemple depth_gray ou depth_bgr)
    //send_depth(depth_gray); // ou send_buffer(depth_bgr);
    //send_rgb(depth_rgb);

    return depth_bgr;
}

int main(int argc, char** argv)
{
    udp_server_depth();
    udp_server_rgb();

    // Create a QT application with a window and side-by-side RGB and Depth panel
    QApplication app(argc, argv);

    QCalibrationApp win;
    win.setOnDepthFrameChange(depthmap_grayscale);
    win.show();

    return app.exec();
}
