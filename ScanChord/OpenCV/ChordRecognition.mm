//
//  ChordRecognition.m
//  ScanChord
//
//  Created by Minhyeok Kim on 1/29/25.
//

#import "ChordRecognition.h"
#import "PreProcessing.h"

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

#import <Vision/Vision.h>

@implementation ChordRecognition

+ (UIImage *)detectChords:(UIImage *)image staves:(NSArray<NSNumber *> *)staves {
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    cv::cvtColor(mat, mat, cv::COLOR_BGR2GRAY);
    cv::threshold(mat, mat, 127, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    cv::Mat labels, stats, centroids;
    int cnt = cv::connectedComponentsWithStats(mat, labels, stats, centroids);
    
    for (int i = 1; i < cnt; i++) {
        int x = stats.at<int>(i, cv::CC_STAT_LEFT);
        int y = stats.at<int>(i, cv::CC_STAT_TOP);
        int w = stats.at<int>(i, cv::CC_STAT_WIDTH);
        int h = stats.at<int>(i, cv::CC_STAT_HEIGHT);
        
        if (w > 30 && h > 20) {
            cv::rectangle(mat, cv::Rect(x, y, w, h), cv::Scalar(0, 255, 0), 3);
        }
    }
    
    return MatToUIImage(mat);
}

+ (NSString *)recognizeText:(UIImage *)image {
    NSError *error = nil;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:image.CGImage options:@{}];
    
    __block NSString *result = @"";
    VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        NSArray *observations = request.results;
        NSMutableArray *recognizedStrings = [NSMutableArray array];
        
        for (VNRecognizedTextObservation *observation in observations) {
            VNRecognizedText *topCandidate = [[observation topCandidates:1] firstObject];
            if (topCandidate) {
                [recognizedStrings addObject:topCandidate.string];
                // 콘솔에 각 인식된 텍스트 출력
                NSLog(@"인식된 텍스트: %@", topCandidate.string);
            }
        }
        
        result = [recognizedStrings componentsJoinedByString:@"\n"];
        // 전체 결과 출력
        NSLog(@"=== OCR 전체 결과 ===\n%@", result);
    }];
    
    [handler performRequests:@[request] error:&error];
    
    if (error) {
        NSLog(@"OCR 에러 발생: %@", error.localizedDescription);
    }
    
    return result;
}

@end
