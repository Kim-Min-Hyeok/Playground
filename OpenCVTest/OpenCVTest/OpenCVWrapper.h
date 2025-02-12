//
//  OpenCVWrapper.h
//  OpenCVTest
//
//  Created by Minhyeok Kim on 2/7/25.
//

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject

// 1. 보표 영역 추출 및 노이즈 제거
+ (UIImage *)removeNoiseFromImage:(UIImage *)image;

// 2. 오선 제거 (결과로 이미지와 오선의 y 좌표 배열을 반환)
+ (NSDictionary *)removeStavesFromImage:(UIImage *)image;

// 3. 악보 이미지 정규화 (정규화된 이미지와 스케일링된 오선 좌표 배열 반환)
+ (NSDictionary *)normalizeImage:(UIImage *)image withStaves:(NSArray<NSNumber *> *)staves standard:(double)standard;

// 4. 객체 검출 (검출된 객체 리스트와 처리된 이미지를 반환)
+ (NSDictionary *)detectObjectsInImage:(UIImage *)image withStaves:(NSArray<NSNumber *> *)staves;

// 7. 노드 추출 (음표 및 코드 노드 추출, 여기서는 단순 로그 출력)
+ (void)nodeExtractionFromNotes:(NSArray *)notes;

+ (NSDictionary *)applyNormalizationScale:(UIImage *)image reference:(UIImage *)reference;

+ (NSDictionary *)removeDetectedObjects:(UIImage *)image detected:(NSArray *)objects;

+ (NSDictionary *)subtractImages:(UIImage *)image1 detectionImage:(UIImage *)image2;

+ (NSDictionary *)extractStavesOnly:(UIImage *)image;

+ (NSDictionary *)subtractMultipleImages:(UIImage *)image1 detectionImage:(UIImage *)image2 stavesOnlyImage:(UIImage *)image3;

+ (UIImage *)processedImageFromImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
