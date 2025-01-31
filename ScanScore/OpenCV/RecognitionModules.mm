//
//  RecognitionModules.m
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import "RecognitionModules.h"
#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#endif
#import "Utils.h"

@implementation RecognitionModules

+ (NSDictionary *)recognizeKey:(cv::Mat &)image staves:(NSArray<NSNumber *> *)staves stats:(CGRect)stats {
    bool tsDetected = false;
    int key = 0;

    if (!staves || staves.count < 5) {
        NSLog(@"[ERROR] 오선 데이터 부족");
        return @{@"timeSignatureDetected": @(false), @"key": @(0)};
    }

    cv::Rect cvStats = cv::Rect((int)CGRectGetMinX(stats),
                                (int)CGRectGetMinY(stats),
                                (int)CGRectGetWidth(stats),
                                (int)CGRectGetHeight(stats));

    bool isTimeSignature = (
        abs([staves[0] intValue] - cvStats.y) <= [Utils weighted:5] &&
        abs([staves[4] intValue] - (cvStats.y + cvStats.height)) <= [Utils weighted:5] &&
        abs([staves[2] intValue] - ([Utils getCenter:cvStats.y height:cvStats.height])) <= [Utils weighted:5] &&
        cvStats.width >= [Utils weighted:10] && cvStats.width <= [Utils weighted:18] &&
        cvStats.height >= [Utils weighted:35] && cvStats.height <= [Utils weighted:45]
    );

    if (isTimeSignature) {
        tsDetected = true;
        NSLog(@"[DEBUG] 박자표 감지됨");
    } else {
        std::vector<cv::Rect> stems = [Utils stemDetection:image stats:cvStats length:20];

        if (!stems.empty()) {
            if (stems[0].x - cvStats.x >= [Utils weighted:3]) {
                key = 10 * (int)(stems.size() / 2);
            } else {
                key = 100 * (int)stems.size();
            }

            NSLog(@"[DEBUG] 조표 감지됨: %d", key);
        } else {
            NSLog(@"[ERROR] 조표 검출 실패");
        }
    }

    return @{@"timeSignatureDetected": @(tsDetected), @"key": @(key ?: 0)};
}

@end
