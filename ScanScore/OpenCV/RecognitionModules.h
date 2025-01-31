//
//  RecognitionModules.h
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import <Foundation/Foundation.h>
#ifdef __cplusplus
#import <opencv2/core.hpp>
#endif

NS_ASSUME_NONNULL_BEGIN

@interface RecognitionModules : NSObject

+ (NSDictionary *)recognizeKey:(cv::Mat &)image staves:(NSArray<NSNumber *> *)staves stats:(CGRect)stats;

@end

NS_ASSUME_NONNULL_END
