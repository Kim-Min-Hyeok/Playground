//
//  Utils.h
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utils : NSObject

+ (int)weighted:(int)value;  // 오선 간격에 따른 가중치 적용
+ (cv::Mat)closing:(cv::Mat)image;  // Morphological Closing 적용
+ (int)getCenter:(int)y height:(int)h;
+ (std::vector<cv::Rect>)stemDetection:(cv::Mat &)image stats:(cv::Rect)stats length:(int)length;

@end

NS_ASSUME_NONNULL_END
