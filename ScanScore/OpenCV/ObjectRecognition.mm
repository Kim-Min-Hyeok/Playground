//
//  ObjectRecognition.m
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import "ObjectRecognition.h"
#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif
#import "RecognitionModules.h"
#import "Utils.h"

@implementation ObjectRecognition

+ (UIImage *)recognition:(UIImage *)image staves:(NSArray<NSNumber *> *)staves objects:(NSArray<NSDictionary *> *)objects {
    NSLog(@"[DEBUG] 조표 인식 시작");

    if (!objects || objects.count == 0) {
        NSLog(@"[ERROR] 검출된 객체가 없음. 조표 인식 중단.");
        return image;
    }

    cv::Mat imageMat;
    UIImageToMat(image, imageMat);

    int key = 0;
    bool timeSignatureDetected = false;

    int totalStaves = (int)staves.count;
    NSLog(@"[DEBUG] 총 오선 개수: %d", totalStaves);

    for (int i = 1; i < objects.count; i++) {
        NSDictionary *obj = objects[i];

        if (!obj[@"stats"]) {
            NSLog(@"[ERROR] 객체[%d]의 stats 값이 없음", i);
            continue;
        }

        CGRect statsRect = [obj[@"stats"] CGRectValue];
        int x = (int)CGRectGetMinX(statsRect);
        int y = (int)CGRectGetMinY(statsRect);
        int w = (int)CGRectGetWidth(statsRect);
        int h = (int)CGRectGetHeight(statsRect);

        int line = i / 5;
        int rangeStart = line * 5;

        if (rangeStart + 5 > totalStaves) {
            NSLog(@"[ERROR] 범위를 초과하는 요청 (rangeStart: %d, totalStaves: %d)", rangeStart, totalStaves);
            continue;
        }

        NSRange staffRange = NSMakeRange(rangeStart, 5);
        NSArray<NSNumber *> *staffLines = [staves subarrayWithRange:staffRange];

        if (!timeSignatureDetected) {
            NSDictionary *result = [RecognitionModules recognizeKey:imageMat staves:staffLines stats:statsRect];

            if (!result || !result[@"key"]) {
                NSLog(@"[ERROR] 조표 인식 실패 (index: %d)", i);
                continue;
            }

            bool tsDetected = [result[@"timeSignatureDetected"] boolValue];
            int tempKey = [result[@"key"] intValue];

            NSLog(@"[DEBUG] 객체 %d, 조표 값: %d", i, tempKey);

            timeSignatureDetected = tsDetected;
            key += tempKey;

            if (timeSignatureDetected) {
                int textX = x + w / 2;
                int textY = y + h - 5;  // ✅ 기존보다 위쪽에 배치하여 가독성 향상
                NSLog(@"[DEBUG] putText 실행: key=%d, 위치=(%d, %d)", key, textX, textY);

                cv::putText(imageMat, std::to_string(key), cv::Point(textX, textY),
                            cv::FONT_HERSHEY_SIMPLEX, 0.8, cv::Scalar(0, 0, 255), 2); // ✅ 빨간색 적용
            }
        }
    }

    NSLog(@"[DEBUG] 조표 인식 완료");
    return MatToUIImage(imageMat);
}

@end

