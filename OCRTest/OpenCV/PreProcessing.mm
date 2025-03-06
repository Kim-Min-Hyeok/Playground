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
    
    // 2. 이진화: 배경은 흰색, 요소는 검은색 (반전 없이)
    cv::threshold(gray, binary, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    
    // 3. HoughLinesP를 이용한 수평선 검출
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(binary, lines, 1, CV_PI / 180, 100, binary.cols / 3, 20);
    
    // 검출된 오선들의 중앙 y 좌표를 저장할 벡터
    std::vector<int> staffYs;
    int thickness = 5; // 각 오선의 두께를 보정할 값 (조정 가능)
    
    for (size_t i = 0; i < lines.size(); i++) {
        cv::Vec4i l = lines[i];
        // 선의 기울기를 계산 (단위: 도)
        double angle = std::atan2(l[3] - l[1], l[2] - l[0]) * 180.0 / CV_PI;
        if (std::abs(angle) < 10.0) { // 수평선으로 간주 (±10도 미만)
            // 선의 중앙 y 좌표
            int y = (l[1] + l[3]) / 2;
            staffYs.push_back(y);
        }
    }
    
    // 검출된 오선이 있다면, 최소 y와 최대 y를 계산하여 그 영역을 하나의 rectangle으로 채움
    if (!staffYs.empty()) {
        int minY = *std::min_element(staffYs.begin(), staffYs.end()) - thickness / 2;
        int maxY = *std::max_element(staffYs.begin(), staffYs.end()) + thickness / 2;
        
        // 이미지 경계를 벗어나지 않도록 보정
        minY = std::max(minY, 0);
        maxY = std::min(maxY, binary.rows);
        
        // 이미지 전체 너비에 대해 오선 영역만 흰색으로 칠함
        cv::rectangle(binary, cv::Point(0, minY), cv::Point(binary.cols, maxY), cv::Scalar(255), cv::FILLED);
    }
    
    return binary;
}


@end
