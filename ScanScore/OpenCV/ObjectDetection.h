//
//  ObjectDetection.h
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

@interface ObjectDetection : NSObject

+ (NSDictionary *)detectObjects:(UIImage *)image staves:(NSArray<NSNumber *> *)staves;

@end

NS_ASSUME_NONNULL_END
