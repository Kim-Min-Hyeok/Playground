//
//  PreProcessing.m
//  ScanChord
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

+ (UIImage *)threshold:(UIImage *)image {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::cvtColor(imageMat, imageMat, cv::COLOR_BGR2GRAY);
    cv::threshold(imageMat, imageMat, 127, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    return MatToUIImage(imageMat);
}

+ (UIImage *)removeNoise:(UIImage *)image {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);
    
    cv::cvtColor(imageMat, imageMat, cv::COLOR_BGR2GRAY);
    cv::threshold(imageMat, imageMat, 127, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    cv::Mat labels, stats, centroids;
    int cnt = cv::connectedComponentsWithStats(imageMat, labels, stats, centroids);

    for (int i = 1; i < cnt; i++) {
        int area = stats.at<int>(i, cv::CC_STAT_AREA);
        if (area < 50) {
            int x = stats.at<int>(i, cv::CC_STAT_LEFT);
            int y = stats.at<int>(i, cv::CC_STAT_TOP);
            int w = stats.at<int>(i, cv::CC_STAT_WIDTH);
            int h = stats.at<int>(i, cv::CC_STAT_HEIGHT);
            cv::rectangle(imageMat, cv::Rect(x, y, w, h), cv::Scalar(0), -1);
        }
    }

    return MatToUIImage(imageMat);
}

+ (NSDictionary *)removeStavesAndReturnInfo:(UIImage *)image {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    int height = imageMat.rows;
    int width = imageMat.cols;
    
    std::vector<int> staveLines;

    for (int row = 0; row < height; row++) {
        int pixelCount = 0;
        for (int col = 0; col < width; col++) {
            if (imageMat.at<uchar>(row, col) == 255) {
                pixelCount++;
            }
        }
        
        if (pixelCount >= width * 0.5) {
            if (staveLines.empty() || abs(staveLines.back() - row) > 2) {
                staveLines.push_back(row);
            }
        }
    }

    for (int row : staveLines) {
        for (int col = 0; col < width; col++) {
            imageMat.at<uchar>(row, col) = 0;
        }
    }

    NSMutableArray<NSNumber *> *stavesArray = [NSMutableArray array];
    for (int row : staveLines) {
        [stavesArray addObject:@(row)];
    }
    
    UIImage *resultImage = MatToUIImage(imageMat);
    
    return @{
        @"image": resultImage,
        @"staves": stavesArray
    };
}

@end
