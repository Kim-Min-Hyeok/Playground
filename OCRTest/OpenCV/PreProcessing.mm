//
//  PreProcessing.mm
//  OCRTest
//
//  Created by Minhyeok Kim on 1/29/25.
//

#import "PreProcessing.h"

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

// 함수 선언: 오선(Staff Lines) 제거 함수
cv::Mat removeStaffLines(cv::Mat &inputImage);

@implementation PreProcessing

+ (UIImage *)processImage:(UIImage *)image {
    cv::Mat mat;
    // UIImage를 cv::Mat 형식으로 변환
    UIImageToMat(image, mat);
    
    // 오선을 제거한 이미지 생성
    cv::Mat processed = removeStaffLines(mat);
    
    // cv::Mat을 다시 UIImage로 변환하여 반환
    return MatToUIImage(processed);
}

cv::Mat removeStaffLines(cv::Mat &inputImage) {
    cv::Mat gray, binary;
    
    // 1. 그레이스케일 변환
    cv::cvtColor(inputImage, gray, cv::COLOR_BGR2GRAY);
    
    // 2. 이진화: THRESH_BINARY 사용 → 배경은 흰색, 요소는 검은색
    cv::threshold(gray, binary, 0, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    // 3. HoughLinesP를 이용한 수평선 검출
    std::vector<cv::Vec4i> lines;
    // 파라미터 설명:
    // - 1: 거리 해상도 (픽셀 단위)
    // - CV_PI/180: 각도 해상도 (1도)
    // - 100: 선 검출 임계값 (조정 필요)
    // - 최소 선 길이: 이미지 너비의 절반 (조정 가능)
    // - 최대 간격: 20픽셀 (조정 가능)
    cv::HoughLinesP(binary, lines, 1, CV_PI / 180, 100, binary.cols / 2, 20);
    
    // 4. 검출된 수평선 제거: 일정 길이 이상의, 수평(±10도 미만)의 선을 흰색으로 칠함
    for (size_t i = 0; i < lines.size(); i++) {
        cv::Vec4i l = lines[i];
        // 선의 기울기를 계산 (단위: 도)
        double angle = std::atan2(l[3] - l[1], l[2] - l[0]) * 180.0 / CV_PI;
        if (std::abs(angle) < 10.0) { // 수평선 판단 (±10도)
            // 선의 두께는 3픽셀 (필요에 따라 조정)
            cv::line(binary, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), cv::Scalar(255), 3);
        }
    }
    
    return binary;
}

@end
