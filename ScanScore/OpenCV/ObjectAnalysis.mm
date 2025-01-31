//
//  ObjectAnalysis.m
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import "ObjectAnalysis.h"
#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif
#import "Utils.h"

@implementation ObjectAnalysis

+ (std::pair<int, int>)getLine:(cv::Mat &)image axis:(bool)axis axisValue:(int)axisValue start:(int)start end:(int)end length:(int)length {
    std::vector<std::pair<int, int>> points;
    int pixels = 0;
    
    if (axis) {
        for (int i = start; i < end; i++) {
            points.push_back({i, axisValue});
        }
    } else {
        for (int i = start; i < end; i++) {
            points.push_back({axisValue, i});
        }
    }

    int found = 0;
    for (size_t i = 0; i < points.size(); i++) {
        int y = points[i].first, x = points[i].second;
        pixels += (image.at<uchar>(y, x) == 255);
        int next_point = (axis ? image.at<uchar>(y + 1, x) : image.at<uchar>(y, x + 1));

        if (next_point == 0 || i == points.size() - 1) {
            if (pixels >= [Utils weighted:length]) {
                found = 1;
                break;
            } else {
                pixels = 0;
            }
        }
    }

    return {axis ? points.back().first : points.back().second, pixels};
}

+ (std::vector<cv::Rect>)stemDetection:(cv::Mat &)image stats:(CGRect)stats length:(int)length {
    std::vector<cv::Rect> stems;

    int x = (int)CGRectGetMinX(stats);
    int y = (int)CGRectGetMinY(stats);
    int w = (int)CGRectGetWidth(stats);
    int h = (int)CGRectGetHeight(stats);

    for (int col = x; col < x + w; col++) {
        int end = -1;
        int pixels = 0;
        for (int row = y; row < y + h; row++) {
            if (image.at<uchar>(row, col) == 255) {
                pixels++;
            } else {
                if (pixels >= length) {
                    end = row;
                    break;
                }
                pixels = 0;
            }
        }

        if (pixels >= length) {
            stems.push_back(cv::Rect(col, end - pixels + 1, 1, pixels));
        }
    }

    return stems;
}

+ (UIImage *)analyzeObjects:(UIImage *)image objects:(NSArray<NSDictionary *> *)objects {
    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    for (int i = 0; i < objects.count; i++) {
        NSMutableDictionary *obj = [objects[i] mutableCopy];

        // ✅ `obj`가 NSDictionary인지 확인
        if (![obj isKindOfClass:[NSDictionary class]]) {
            NSLog(@"[ERROR] 객체 %d가 NSDictionary가 아님: %@", i, obj);
            continue;
        }

        // ✅ "stats" 키가 존재하는지 확인하고 `NSValue` 변환
        NSValue *statsValue = obj[@"stats"];
        if (![statsValue isKindOfClass:[NSValue class]]) {
            NSLog(@"[ERROR] 객체 %d의 stats가 NSValue가 아님: %@", i, statsValue);
            continue;
        }

        // ✅ 객체 유형 확인
        NSString *type = obj[@"type"];
        if (![type isKindOfClass:[NSString class]]) {
            NSLog(@"[ERROR] 객체 %d의 type이 NSString이 아님", i);
            continue;
        }

        // 📌 음표가 아닌 경우 건너뛰기
        if (![type isEqualToString:@"note"]) {
            continue;
        }

        // ✅ CGRect로 변환
        CGRect statsRect = [statsValue CGRectValue];

        // ✅ CGRect → cv::Rect 변환
        cv::Rect stats(
            (int)CGRectGetMinX(statsRect),
            (int)CGRectGetMinY(statsRect),
            (int)CGRectGetWidth(statsRect),
            (int)CGRectGetHeight(statsRect)
        );

        int x = stats.x;
        int y = stats.y;
        int w = stats.width;
        int h = stats.height;

        // 📌 음표 기둥(Stem) 검출
        std::vector<cv::Rect> stems = [Utils stemDetection:imageMat stats:stats length:30];

        // 📌 기둥 개수 디버깅
        NSLog(@"[DEBUG] 음표 객체 %d (%d, %d), 기둥 개수: %lu", i, x, y, stems.size());

        // 📌 기둥이 있는 객체에만 숫자 표시
        if (!stems.empty()) {
            cv::putText(imageMat, std::to_string(stems.size()), cv::Point(x, y + h + 20),
                        cv::FONT_HERSHEY_SIMPLEX, 0.8, cv::Scalar(255, 0, 0), 2);
        }

        // 📌 객체 테두리 그리기
        cv::rectangle(imageMat, stats, cv::Scalar(255, 0, 0), 1);
    }

    return MatToUIImage(imageMat);
}


@end
