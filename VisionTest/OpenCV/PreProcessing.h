//
//  PreProcessing.h
//  VisionTest
//
//  Created by Minhyeok Kim on 1/29/25.
//

// PreProcessing.h
#ifndef PreProcessing_h
#define PreProcessing_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>

@interface PreProcessing : NSObject
+ (UIImage *)processImage:(UIImage *)image;
@end

#endif /* PreProcessing_h */
