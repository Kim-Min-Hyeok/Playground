//
//  ChordRecognition.h
//  ScanChord
//
//  Created by Minhyeok Kim on 1/29/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChordRecognition : NSObject

+ (UIImage *)detectChords:(UIImage *)image staves:(NSArray<NSNumber *> *)staves;
+ (NSString *)recognizeText:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
