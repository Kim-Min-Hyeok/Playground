//
//  Utils.m
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import "Utils.h"

@implementation Utils

+ (int)weighted:(int)value {
    int standard = 10;
    return (int)(value * (standard / 10.0));
}

// 📌 Morphological Closing 적용하여 객체 내부의 노이즈 제거
+ (cv::Mat)closing:(cv::Mat)image {
    cv::Mat processedImage;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size([Utils weighted:3], [Utils weighted:3]));

    // 🔹 닫힘 연산 (Closing) 적용: 객체 내부의 노이즈 제거
    cv::morphologyEx(image, processedImage, cv::MORPH_CLOSE, kernel);

    // 🔹 열림 연산 (Opening) 적용: 객체를 분리하여 작은 연결 제거
    cv::morphologyEx(processedImage, processedImage, cv::MORPH_OPEN, kernel);

    return processedImage;
}

+ (int)getCenter:(int)y height:(int)h {
    return y + (h / 2);
}

+ (std::vector<cv::Rect>)stemDetection:(cv::Mat &)image stats:(cv::Rect)stats length:(int)length {
    std::vector<cv::Rect> stems;

    for (int col = stats.x; col < stats.x + stats.width; col++) {
        int startY = 0, pixels = 0;

        for (int row = stats.y; row < stats.y + stats.height; row++) {
            if (image.at<uchar>(row, col) == 255) {
                if (pixels == 0) startY = row;
                pixels++;
            } else if (pixels >= length) {
                stems.push_back(cv::Rect(col, startY, 1, pixels));
                pixels = 0;
            } else {
                pixels = 0;
            }
        }

        if (pixels >= length) {
            stems.push_back(cv::Rect(col, startY, 1, pixels));
        }
    }

    return stems;
}

@end
