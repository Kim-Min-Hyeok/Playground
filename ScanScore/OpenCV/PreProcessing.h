//
//  PreProcessing.h
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreProcessing : NSObject

+ (UIImage *)threshold:(UIImage *)image;  // 이진화 적용
+ (UIImage *)removeNoise:(UIImage *)image; // 보표 추출 및 노이즈 제거
+ (UIImage *)removeStaves:(UIImage *)image; // 오선 제거
+ (UIImage *)normalizeImage:(UIImage *)image staves:(NSArray<NSNumber *> *)staves standard:(CGFloat)standard
    NS_SWIFT_NAME(normalizeImage(_:staves:standard:));
+ (UIImage *)removeStaves:(UIImage *)image staves:(NSArray<NSNumber *> * _Nonnull * _Nonnull)staves;

@end

NS_ASSUME_NONNULL_END
