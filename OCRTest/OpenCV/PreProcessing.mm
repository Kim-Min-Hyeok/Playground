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

@implementation PreProcessing

+ (UIImage *)processImage:(UIImage *)image {
    cv::Mat mat;
    UIImageToMat(image, mat);
    cv::Mat processed = removeStaffLines(mat);
    return MatToUIImage(processed);
}

cv::Mat removeStaffLines(cv::Mat &inputImage) {
    cv::Mat gray, binary, horizontal;
    
    // Convert to grayscale
    cv::cvtColor(inputImage, gray, cv::COLOR_BGR2GRAY);
    cv::threshold(gray, binary, 0, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    // Remove horizontal lines
    int horizontalSize = binary.cols / 40;
    cv::Mat horizontalStructure = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(horizontalSize, 1));
    cv::erode(binary, horizontal, horizontalStructure);
    cv::dilate(horizontal, horizontal, horizontalStructure);
    
    // Subtract lines from image
    cv::Mat result;
    cv::bitwise_and(binary, ~horizontal, result);
    
    return result;
}

@end
