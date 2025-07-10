#include "CVCamera.h"

#include <opencv2/imgproc.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/classes/engine.hpp>

using namespace godot;

typedef cv::Vec<uint8_t, 4> Pixel;

void CVCamera::_bind_methods()
{
    ClassDB::bind_method(D_METHOD("_to_string"), &CVCamera::_to_string);
    ClassDB::bind_method(D_METHOD("open"), &CVCamera::open);
    ClassDB::bind_method(D_METHOD("open_file"), &CVCamera::open_file);
    ClassDB::bind_method(D_METHOD("close"), &CVCamera::close);
    ClassDB::bind_method(D_METHOD("get_image"), &CVCamera::get_image);
    ClassDB::bind_method(D_METHOD("get_gray_image"), &CVCamera::get_gray_image);
    ClassDB::bind_method(D_METHOD("get_overlay_image"), &CVCamera::get_overlay_image);
    ClassDB::bind_method(D_METHOD("get_width"), &CVCamera::get_width);
    ClassDB::bind_method(D_METHOD("get_height"), &CVCamera::get_height);
    ClassDB::bind_method(D_METHOD("flip"), &CVCamera::flip);
}

CVCamera::CVCamera()
{
    last_update_frame = -1;
    threshold = 0.0;
}

CVCamera::~CVCamera()
{
    close();
}

void CVCamera::open(int device, int width = 1920, int height = 1080)
{
    capture.open(device);
    capture.set(cv::CAP_PROP_FRAME_WIDTH, width);
    capture.set(cv::CAP_PROP_FRAME_HEIGHT, height);
    if (!capture.isOpened())
    {
        capture.release();
        UtilityFunctions::push_error("Couldn't open camera.");
    }
}

void CVCamera::open_file(String path)
{
    const cv::String pathStr(path.utf8());
    capture.open(pathStr);
    if (!capture.isOpened())
    {
        capture.release();
        UtilityFunctions::push_error("Couldn't open camera.");
    }
}

void CVCamera::close()
{
    capture.release();
}

void CVCamera::update_frame()
{
    // Only update the frame once per godot process frame
    uint64_t current_frame = Engine::get_singleton()->get_process_frames();
    if (current_frame == last_update_frame)
    {
        return;
    }
    last_update_frame = current_frame;

    // Read the frame from the camera
    capture.read(frame_raw);

    if (frame_raw.empty())
    {
        printf("Error: Could not read frame\n");
    }

    if (flip_lr || flip_ud)
    {
        int code = flip_lr ? (flip_ud ? -1 : 1) : 0;
        cv::flip(frame_raw, frame_raw, code);
    }

    cv::cvtColor(frame_raw, frame_rgb, cv::COLOR_BGR2RGB);
    cv::cvtColor(frame_rgb, frame_gray, cv::COLOR_RGB2GRAY);
    frame_overlay = cv::Mat::zeros(frame_raw.size(), CV_8UC4);
    cv::cvtColor(frame_overlay, frame_overlay, cv::COLOR_BGRA2RGBA);
}

Ref<Image> CVCamera::mat_to_image(cv::Mat mat)
{
    cv::Mat image_mat;
    if (mat.channels() == 1)
    {
        cv::cvtColor(mat, image_mat, cv::COLOR_GRAY2RGB);
    }
    else if (mat.channels() == 4)
    {
        // Turn Pixels alpha value opaque, where there is anything but black
        image_mat = mat;
        image_mat.forEach<Pixel>([](Pixel &p, const int *position) -> void
                                 {
            if (p[0] > 0 || p[1] > 0 || p[2] > 0)
            {
                p[3] = 255;
            } });
    }
    else
    {
        image_mat = mat;
    }

    int sizear = image_mat.cols * image_mat.rows * image_mat.channels();

    PackedByteArray bytes;
    bytes.resize(sizear);
    memcpy(bytes.ptrw(), image_mat.data, sizear);

    Ref<Image> image;
    if (image_mat.channels() == 4)
    {
        image = Image::create_from_data(image_mat.cols, image_mat.rows, false, Image::Format::FORMAT_RGBA8, bytes);
    }
    else
    {
        image = Image::create_from_data(image_mat.cols, image_mat.rows, false, Image::Format::FORMAT_RGB8, bytes);
    }
    return image;
}

Ref<Image> CVCamera::get_image()
{
    update_frame();

    cv::Mat output = frame_rgb.clone();
    cv::GaussianBlur(frame_gray, frame_gray, cv::Size(5, 5), 0);
    cv::medianBlur(frame_gray, frame_gray, 5);
    cv::adaptiveThreshold(frame_gray, frame_gray, 255, cv::ADAPTIVE_THRESH_GAUSSIAN_C,
                          cv::THRESH_BINARY, 11, 3.5);

    std::vector<cv::Vec3f> circles;
    cv::HoughCircles(frame_gray, circles, cv::HOUGH_GRADIENT_ALT, 1.5, 10,
                     350, 0.88, 0, 0);

    for (auto &c : circles) {
        cv::Point center(cvRound(c[0]), cvRound(c[1]));
        int radius = cvRound(c[2]);
        cv::circle(output, center, radius, cv::Scalar(0, 255, 0), 4);
        cv::rectangle(output, cv::Point(center.x - 5, center.y - 5),
                      cv::Point(center.x + 5, center.y + 5),
                      cv::Scalar(0, 128, 255), cv::FILLED);
    }
    return mat_to_image(output);
}

Ref<Image> CVCamera::get_gray_image()
{
    update_frame();

    return mat_to_image(frame_gray);
}

Ref<Image> CVCamera::get_overlay_image()
{
    update_frame();

    return mat_to_image(frame_overlay);
}

int CVCamera::get_width()
{
    return frame_raw.cols;
}

int CVCamera::get_height()
{
    return frame_raw.rows;
}

void CVCamera::flip(bool flip_lr, bool flip_ud)
{
    this->flip_lr = flip_lr;
    this->flip_ud = flip_ud;
}

String CVCamera::_to_string() const
{
    return "[ CVCamera instance ]";
}
