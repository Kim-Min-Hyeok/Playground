// OpenCVWrapper.h
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

/// OpenCV를 사용하여 이미지 이진화(검/희 변환)를 수행합니다.
/// - Parameters:
///   - image: 원본 이미지.
///   - threshold: 임계값 (0~255). 일반적으로 127 정도로 사용하거나 THRESH_OTSU를 함께 사용할 수 있습니다.
/// - Returns: 이진화(흑백)된 결과 이미지.
+ (UIImage *)binarizeImage:(UIImage *)image threshold:(double)threshold;

/// Hough 변환을 사용하여 이미지에서 수평 및 수직 직선을 검출 후 제거한 결과 이미지를 반환합니다.
+ (UIImage *)removeLinesUsingHough:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
