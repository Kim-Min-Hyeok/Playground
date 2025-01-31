//
//  ObjectDetection.m
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import "ObjectDetection.h"
#import "ObjectAnalysis.h"
#import "Utils.h"

@implementation ObjectDetection

+ (NSDictionary *)detectObjects:(UIImage *)image staves:(NSArray<NSNumber *> *)staves {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    // 📌 닫힘 연산 (커널 크기 조정: weighted(5) → weighted(3))
    cv::Mat closedImage;
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size([Utils weighted:3], [Utils weighted:3]));
    cv::morphologyEx(imageMat, closedImage, cv::MORPH_CLOSE, kernel);

    // 📌 findContours()를 사용하여 객체 검출
    std::vector<std::vector<cv::Point>> contours;
    cv::findContours(closedImage, contours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

    NSMutableArray *objects = [NSMutableArray array];

    for (size_t i = 0; i < contours.size(); i++) {
        cv::Rect boundingBox = cv::boundingRect(contours[i]);
        int x = boundingBox.x;
        int y = boundingBox.y;
        int w = boundingBox.width;
        int h = boundingBox.height;

        // 📌 너무 작은 객체는 무시 (weighted(5) → weighted(3))
        if (w >= [Utils weighted:3] && h >= [Utils weighted:3]) {
            cv::rectangle(imageMat, boundingBox, cv::Scalar(255), 1);
            
            // 📌 객체 유형 설정
            NSString *objectType = @"unknown";

            if (h >= [Utils weighted:15] && h <= [Utils weighted:50] && w < [Utils weighted:20]) {
                objectType = @"note";  // 음표
            } else if (h >= [Utils weighted:20] && w < [Utils weighted:10]) {
                objectType = @"key_signature"; // 조표
            } else if (h >= [Utils weighted:30] && w >= [Utils weighted:15]) {
                objectType = @"time_signature"; // 박자표
            } else if (w < [Utils weighted:5] && h >= [Utils weighted:30]) {
                objectType = @"bar_line"; // 마디선
            }

            NSDictionary *objectData = @{
                @"stats": [NSValue valueWithCGRect:CGRectMake(x, y, w, h)],
                @"type": objectType,
                @"stems": @[]
            };
            [objects addObject:objectData];
        }
    }

    // 📌 마디선 제거
    NSMutableArray *filteredObjects = [NSMutableArray array];
    for (NSDictionary *obj in objects) {
        if (![obj[@"type"] isEqualToString:@"bar_line"]) {
            [filteredObjects addObject:obj]; // 마디선 제외
        }
    }

    return @{@"image": MatToUIImage(imageMat), @"objects": filteredObjects};
}

@end
