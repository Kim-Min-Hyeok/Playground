//
//  ObjectAnalysis.h
//  ScanScore
//
//  Created by Minhyeok Kim on 1/28/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ObjectAnalysis : NSObject

+ (UIImage *)analyzeObjects:(UIImage *)image objects:(NSArray<NSDictionary *> *)objects;

@end

NS_ASSUME_NONNULL_END
