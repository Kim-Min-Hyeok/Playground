//
//  ObjectRecognition.h
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectRecognition : NSObject

+ (UIImage *)recognition:(UIImage *)image staves:(NSArray<NSNumber *> *)staves objects:(NSArray<NSDictionary *> *)objects;

@end

NS_ASSUME_NONNULL_END
