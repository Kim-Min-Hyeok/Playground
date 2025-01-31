//
//  PreProcessing.h
//  ScanChord
//
//  Created by Minhyeok Kim on 1/29/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreProcessing : NSObject

+ (UIImage *)threshold:(UIImage *)image;
+ (UIImage *)removeNoise:(UIImage *)image;
+ (NSDictionary *)removeStavesAndReturnInfo:(UIImage *)image;  

@end

NS_ASSUME_NONNULL_END
