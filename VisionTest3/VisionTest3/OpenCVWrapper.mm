// OpenCVWrapper.mm
#import "OpenCVWrapper.h"

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

using namespace cv;

@implementation OpenCVWrapper

+ (UIImage *)binarizeImage:(UIImage *)image threshold:(double)threshold {
    // UIImage를 cv::Mat으로 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // 컬러 이미지를 그레이스케일로 변환
    cv::Mat gray;
    cv::cvtColor(mat, gray, COLOR_BGR2GRAY);
    
    // 이진화 (검/희 변환)
    // THRESH_BINARY_INV: 밝은 부분(배경)은 0, 어두운 부분(전경)은 255로 변환
    // THRESH_OTSU를 함께 사용하면 임계값을 자동으로 결정하지만, 여기서는 threshold 값을 직접 사용합니다.
    cv::Mat binary;
    cv::threshold(gray, binary, threshold, 255, THRESH_BINARY);
    
    // 결과 이미지를 UIImage로 변환하여 반환
    UIImage *result = MatToUIImage(binary);
    return result;
}

+ (UIImage *)removeLinesUsingHough:(UIImage *)image {
    // UIImage를 cv::Mat으로 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // 검/희 변환이 이미 되어 있다고 가정하거나, 여기서 다시 그레이스케일로 변환
    cv::Mat gray;
    cv::cvtColor(mat, gray, COLOR_BGR2GRAY);
    
    // Canny 에지 검출 (파라미터는 이미지 특성에 따라 조정)
    cv::Mat edges;
    Canny(gray, edges, 50, 150, 3);
    
    // HoughLinesP를 사용하여 직선 검출
    std::vector<cv::Vec4i> lines;
    HoughLinesP(edges, lines, 1, CV_PI/180, 100, 50, 10);
    
    // 검출된 직선 중 수평선 또는 수직선에 가까운 선을 흰색(배경색)으로 덮어 제거
    for (size_t i = 0; i < lines.size(); i++) {
        cv::Vec4i l = lines[i];
        double dx = l[2] - l[0];
        double dy = l[3] - l[1];
        double angle = std::atan2(dy, dx) * 180.0 / CV_PI;
        
        // 수평선: angle이 0±10도 또는 180±10도
        // 수직선: angle이 90±10도 또는 -90±10도
        if ((std::abs(angle) < 10.0) || (std::abs(angle) > 170.0) ||
            (std::abs(std::abs(angle) - 90.0) < 10.0)) {
            // 검출된 선을 두께 2픽셀의 흰색 선으로 덮어 씁니다.
            cv::line(mat, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]),
                     cv::Scalar(255, 255, 255), 2);
        }
    }
    
    // 결과 cv::Mat을 UIImage로 변환하여 반환
    UIImage *result = MatToUIImage(mat);
    return result;
}

@end
