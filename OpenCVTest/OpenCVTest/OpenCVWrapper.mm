//
//  OpenCVWrapper.m
//  OpenCVTest
//
//  Created by Minhyeok Kim on 2/7/25.
//

#import "OpenCVWrapper.h"

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/imgcodecs/ios.h>
#endif

#import <UIKit/UIKit.h>

using namespace cv;
using std::string;
using std::vector;

#pragma mark - 글로벌 스케일 변수

// 정규화 과정에서 계산된 가중치를 전역 변수로 관리 (초기값 1.0)
static double g_weight = 1.0;

#pragma mark - 헬퍼 함수

// fs.weighted: 주어진 값에 g_weight를 곱하여 반환
static inline double weighted(double val) {
    return val * g_weight;
}

// fs.get_center: 주어진 y 좌표와 높이로부터 중심 좌표(정수)를 반환
static inline int get_center(int y, int h) {
    return y + h / 2;
}

// fs.put_text: 이미지에 텍스트를 그립니다.
static inline void put_text(Mat &img, const string &text, cv::Point pt) {
    putText(img, text, pt, FONT_HERSHEY_SIMPLEX, 0.5, Scalar(0), 1);
}

// fs.count_rect_pixels: 지정한 사각형 영역 내의 흰색(255) 픽셀 수 반환
static int count_rect_pixels(const Mat &img, cv::Rect rect) {
    cv::Rect validRect = rect & cv::Rect(0, 0, img.cols, img.rows);
    Mat roi = img(validRect);
    return countNonZero(roi);
}

// fs.get_line: 주어진 행(또는 열)에서 연속 흰색 픽셀 수를 반환
// orientation: 0 - horizontal, 1 - vertical
static int get_line(const Mat &img, int orientation, int pos, int start, int end, int dummy) {
    int count = 0;
    if (orientation == 0) { // horizontal: pos = row, iterate over columns
        for (int col = start; col < end; col++) {
            if (img.at<uchar>(pos, col) == 255)
                count++;
        }
    } else { // vertical: pos = col, iterate over rows
        for (int row = start; row < end; row++) {
            if (img.at<uchar>(row, pos) == 255)
                count++;
        }
    }
    return count;
}

// fs.count_pixels_part: 특정 열에서 rowStart ~ rowEnd의 흰색 픽셀 수 반환
static int count_pixels_part(const Mat &img, int rowStart, int rowEnd, int col) {
    int cnt = 0;
    for (int r = rowStart; r < rowEnd && r < img.rows; r++) {
        if (img.at<uchar>(r, col) == 255)
            cnt++;
    }
    return cnt;
}

// fs.stem_detection: 객체 영역(rect) 내에서 세로 방향의 선분(Stem)을 탐색하여 반환
static vector<cv::Rect> stem_detection(const Mat &img, cv::Rect rect, int minLength) {
    vector<cv::Rect> stems;
    // 관심영역 추출
    Mat roi = img(rect);
    // 세로 선 검출을 위해 세로 방향 구조 요소 사용 (길이가 minLength 이상이면 stem으로 판단)
    int roiRows = roi.rows;
    int roiCols = roi.cols;
    // 단순 스캔: 각 열에 대해 연속 흰색 픽셀 수 체크
    for (int c = 0; c < roiCols; c++) {
        int consecutive = 0;
        int bestStart = -1;
        for (int r = 0; r < roiRows; r++) {
            if (roi.at<uchar>(r, c) == 255) {
                if (consecutive == 0)
                    bestStart = r;
                consecutive++;
            } else {
                if (consecutive >= minLength) {
                    // stem 영역: 위치 변환하여 원래 이미지 좌표 반환
                    cv::Rect stemRect(rect.x + c, rect.y + bestStart, 1, consecutive);
                    stems.push_back(stemRect);
                }
                consecutive = 0;
            }
        }
        if (consecutive >= minLength) {
            cv::Rect stemRect(rect.x + c, rect.y + bestStart, 1, consecutive);
            stems.push_back(stemRect);
        }
    }
    return stems;
}

#pragma mark - OpenCVWrapper Implementation

@implementation OpenCVWrapper

+ (UIImage *)removeNoiseFromImage:(UIImage *)image {
    // 1. UIImage → cv::Mat 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // 2. 그레이스케일 변환
    cv::Mat gray;
    cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // 3. 이진화 (THRESH_BINARY_INV | THRESH_OTSU 사용하여 Python과 동일한 결과 생성)
    cv::Mat binary;
    // 임계값은 0을 지정하면 OTSU가 자동으로 결정합니다.
    threshold(gray, binary, 0, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    // 4. 보표 영역 추출을 위한 마스크 생성 (binary와 동일한 크기, 단일 채널)
    cv::Mat mask = cv::Mat::zeros(binary.size(), CV_8UC1);
    
    // 5. 연결 요소 분석
    cv::Mat labels, stats, centroids;
    int nLabels = connectedComponentsWithStats(binary, labels, stats, centroids);
    int imgWidth = binary.cols;
    for (int i = 1; i < nLabels; i++) {
        int x = stats.at<int>(i, cv::CC_STAT_LEFT);
        int y = stats.at<int>(i, cv::CC_STAT_TOP);
        int w = stats.at<int>(i, cv::CC_STAT_WIDTH);
        int h = stats.at<int>(i, cv::CC_STAT_HEIGHT);
        // 보표 영역: 이미지 너비의 50% 이상인 객체
        if (w > imgWidth * 0.5) {
            // FILLED 플래그로 사각형 내부를 채워 넣음
            cv::rectangle(mask, cv::Rect(x, y, w, h), cv::Scalar(255), cv::FILLED);
        }
    }
    
    // 6. 마스킹: binary 이미지와 mask의 bitwise_and 연산으로 보표 영역만 추출
    cv::Mat masked;
    cv::bitwise_and(binary, mask, masked);
    
    // 7. 결과 Mat을 UIImage로 변환하여 반환
    UIImage *result = MatToUIImage(masked);
    return result;
}

+ (NSDictionary *)removeStavesFromImage:(UIImage *)image {
    // 1. UIImage → cv::Mat 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    // 클론하여 처리 (원본을 보존)
    cv::Mat processed = mat.clone();
    
    int height = processed.rows;
    int width = processed.cols;
    
    // 오선 정보를 저장할 vector. 각 원소는 pair<int, int>로 (y 좌표, 오선 높이)
    std::vector<std::pair<int, int>> staves;
    
    // 2. 각 행에서 흰색 픽셀 개수 세기
    for (int row = 0; row < height; row++) {
        int whiteCount = 0;
        for (int col = 0; col < width; col++) {
            // processed는 단일 채널 이진화 이미지라고 가정 (픽셀 값 0 또는 255)
            if (processed.at<uchar>(row, col) == 255)
                whiteCount++;
        }
        // 만약 행의 흰색 픽셀 개수가 이미지 너비의 50% 이상이면 오선으로 판단
        if (whiteCount >= width * 0.5) {
            // 만약 아직 오선이 없거나, 마지막 오선의 (y좌표 + 높이)와 현재 row의 차이가 1 이상이면 새로운 오선
            if (staves.empty() || std::abs((staves.back().first + staves.back().second) - row) > 1) {
                staves.push_back(std::make_pair(row, 0));
            } else {
                // 그렇지 않으면 같은 오선으로 간주하고 높이를 증가
                staves.back().second += 1;
            }
        }
    }
    
    // 3. 오선 제거: 각 오선 영역에 대해 오선 위와 아래의 픽셀 존재 여부 확인 후 제거
    for (size_t i = 0; i < staves.size(); i++) {
        int top_pixel = staves[i].first;
        int bot_pixel = staves[i].first + staves[i].second; // Python 코드에서는 bot_pixel = top + height
        // 반복문 전에 인덱스 범위 확인: top_pixel - 1, bot_pixel + 1 이 이미지 내에 있어야 함
        if (top_pixel - 1 < 0 || bot_pixel + 1 >= height) {
            continue;
        }
        // 각 열마다 오선 위쪽과 아래쪽의 픽셀값 확인
        for (int col = 0; col < width; col++) {
            if (processed.at<uchar>(top_pixel - 1, col) == 0 &&
                processed.at<uchar>(bot_pixel + 1, col) == 0) {
                // 오선 영역의 모든 픽셀을 0으로 설정
                for (int row = top_pixel; row <= bot_pixel; row++) {
                    processed.at<uchar>(row, col) = 0;
                }
            }
        }
    }
    
    // 4. 결과 Mat을 UIImage로 변환
    UIImage *resultImage = MatToUIImage(processed);
    
    // 5. staves 벡터의 y 좌표들만 NSArray로 변환 (Python 코드에서는 [x[0] for x in staves])
    NSMutableArray *stavesArray = [NSMutableArray array];
    for (size_t i = 0; i < staves.size(); i++) {
        [stavesArray addObject:@(staves[i].first)];
    }
    
    return @{@"image": resultImage, @"staves": stavesArray};
}

+ (NSDictionary *)normalizeImage:(UIImage *)image withStaves:(NSArray<NSNumber *> *)staves standard:(double)standard {
    // 1. UIImage → cv::Mat 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    if (mat.empty()) {
        NSLog(@"Error: UIImageToMat conversion failed.");
        return @{@"image": image, @"staves": staves};
    }
    
    int height = mat.rows;
    int width = mat.cols;
    
    // 2. staves NSArray를 C++ vector<double>로 변환
    std::vector<double> stavesVector;
    for (NSNumber *num in staves) {
        stavesVector.push_back([num doubleValue]);
    }
    
    if (stavesVector.size() < 5) {
        NSLog(@"Normalization error: staves count is too low (%lu)", stavesVector.size());
        return @{@"image": image, @"staves": staves};
    }
    
    int count = (int)stavesVector.size();
    int lines = count / 5;
    if ((count - lines) == 0) {
        NSLog(@"Normalization error: (count - lines) is 0");
        return @{@"image": image, @"staves": staves};
    }
    
    // 3. 오선 간 평균 간격 계산
    double totalDistance = 0.0;
    for (int line = 0; line < lines; line++) {
        for (int staff = 0; staff < 4; staff++) {
            double staffAbove = stavesVector[line * 5 + staff];
            double staffBelow = stavesVector[line * 5 + staff + 1];
            totalDistance += fabs(staffBelow - staffAbove);
        }
    }
    double avgDistance = totalDistance / (count - lines);
    
    // 4. 스케일 가중치 계산 (standard는 외부에서 전달, 예: 10.0)
    double weight = standard / avgDistance;
    
    // 5. 새로운 이미지 크기 계산
    int newWidth = (int)(width * weight);
    int newHeight = (int)(height * weight);
    
    // 6. 이미지 리사이즈
    cv::Mat resized;
    cv::resize(mat, resized, cv::Size(newWidth, newHeight));
    
    // 7. 리사이즈된 이미지에 대해 그레이스케일 변환 (채널 수에 따라)
    cv::Mat gray;
    if (resized.channels() == 1) {
        gray = resized.clone();
    } else {
        cvtColor(resized, gray, cv::COLOR_BGR2GRAY);
    }
    
    // 8. 이진화 (OTSU 적용)
    cv::Mat binary;
    cv::threshold(gray, binary, 0, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);
    
    // 9. 오선 좌표에도 가중치(weight) 적용
    NSMutableArray *scaledStaves = [NSMutableArray arrayWithCapacity:staves.count];
    for (size_t i = 0; i < stavesVector.size(); i++) {
        double scaledValue = stavesVector[i] * weight;
        [scaledStaves addObject:@(scaledValue)];
    }
    
    UIImage *resultImage = MatToUIImage(binary);
    
    // **중요**: 계산된 weight(스케일)을 함께 반환합니다.
    return @{@"image": resultImage,
             @"staves": scaledStaves,
             @"scale": @(weight)};
}


+ (NSDictionary *)detectObjectsInImage:(UIImage *)image withStaves:(NSArray<NSNumber *> *)staves {
    // 1. UIImage → cv::Mat 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // 2. 닫힘 연산 (Closing)으로 분할된 객체들을 연결
    cv::Mat kernel = getStructuringElement(MORPH_RECT, cv::Size(3, 3));
    cv::Mat closed;
    morphologyEx(mat, closed, MORPH_CLOSE, kernel);
    
    // 3. 연결 요소 분석으로 모든 객체 검출
    cv::Mat labels, stats, centroids;
    int nLabels = connectedComponentsWithStats(closed, labels, stats, centroids);
    
    // 보표(스태프) 개수: staves 배열은 보표 당 5개의 오선 좌표를 가지므로
    int lines = (int)staves.count / 5;
    NSMutableArray *objects = [NSMutableArray array];
    
    // 4. 각 객체에 대해 조건 검사 및 보표 할당
    for (int i = 1; i < nLabels; i++) {
        int x = stats.at<int>(i, cv::CC_STAT_LEFT);
        int y = stats.at<int>(i, cv::CC_STAT_TOP);
        int w = stats.at<int>(i, cv::CC_STAT_WIDTH);
        int h = stats.at<int>(i, cv::CC_STAT_HEIGHT);
        int area = stats.at<int>(i, cv::CC_STAT_AREA);
        
        // 너비와 높이가 일정 크기 이상이어야 객체로 판단 (예: w, h >= 5)
        if (w >= 5 && h >= 5) {
            int centerY = y + h / 2;
            
            // 각 보표(스태프 그룹)에 대해 반복 (staves 배열의 인덱스를 5씩 증가)
            for (int line = 0; line < lines; line++) {
                int staffTop = [[staves objectAtIndex:(line * 5)] intValue] - 20;
                int staffBottom = [[staves objectAtIndex:(line * 5 + 4)] intValue] + 20;
                
                if (centerY >= staffTop && centerY <= staffBottom) {
                    // 검출된 객체의 바운딩 박스 좌표를 딕셔너리로 저장
                    NSDictionary *rectDict = @{
                        @"x": @(x),
                        @"y": @(y),
                        @"w": @(w),
                        @"h": @(h),
                        @"area": @(area)
                    };
                    NSDictionary *objDict = @{@"line": @(line), @"rect": rectDict};
                    [objects addObject:objDict];
                    break;
                }
            }
        }
    }
    
    // 5. 검출된 객체 영역만 남기기 위한 마스크 생성
    //    (마스크는 검은색(0)으로 초기화된 이미지와 동일한 크기로 생성)
    cv::Mat objectMask = cv::Mat::zeros(mat.size(), CV_8UC1);
    for (NSDictionary *obj in objects) {
        NSDictionary *rectDict = obj[@"rect"];
        int x = [rectDict[@"x"] intValue];
        int y = [rectDict[@"y"] intValue];
        int w = [rectDict[@"w"] intValue];
        int h = [rectDict[@"h"] intValue];
        // 검출된 객체 영역을 흰색(255)로 채움
        cv::rectangle(objectMask, cv::Rect(x, y, w, h), cv::Scalar(255), cv::FILLED);
    }
    
    // 6. 원본 이미지(mat)에서 objectMask가 255인 부분만 복사하여 나머지는 검은색으로 만듦.
    cv::Mat resultMat;
    // copyTo는 마스크가 255인 부분만 복사합니다.
    mat.copyTo(resultMat, objectMask);
    
    // 7. 결과 이미지를 UIImage로 변환하여 반환
    UIImage *result = MatToUIImage(resultMat);
    return @{@"image": result, @"objects": objects};
}



+ (UIImage *)removeStavesAndObjectsFromImage:(UIImage *)image
                                    staves:(NSArray<NSNumber *> *)staves
                                   objects:(NSArray *)objects
                                 normScale:(double)normScale {
    double scale = normScale;
    
    // 1. 원본 이미지(Mat) 변환
    cv::Mat originalMat;
    UIImageToMat(image, originalMat);
    
    // 2. 이미지 이진화 처리
    cv::Mat binaryMat;
    
    // 채널 수에 따라 다르게 처리
    if (originalMat.channels() > 1) {
        cv::cvtColor(originalMat, binaryMat, cv::COLOR_BGR2GRAY);
    } else {
        binaryMat = originalMat.clone();
    }
    
    // 이진화 처리
    cv::threshold(binaryMat, binaryMat, 127, 255, cv::THRESH_BINARY);
    
    // 3. 오선(스태프) 영역 제거: 정규화된 staves 좌표를 원본 좌표로 변환하여 흰색(255)으로 채움
    for (NSNumber *n in staves) {
        int y_norm = [n intValue];
        int y_orig = (int)((double)y_norm / scale);
        // 오선 두께: 원본 기준으로 약 2픽셀 (필요에 따라 조정)
        cv::Rect staffRect(0, y_orig, binaryMat.cols, 2);
        cv::rectangle(binaryMat, staffRect, cv::Scalar(255), cv::FILLED);
    }
    
    // 4. 객체 영역 제거: 정규화된 객체 좌표를 원본 좌표로 변환하여 흰색(255)으로 채움
    for (NSDictionary *obj in objects) {
        NSDictionary *rectDict = obj[@"rect"];
        int x_norm = [rectDict[@"x"] intValue];
        int y_norm = [rectDict[@"y"] intValue];
        int w_norm = [rectDict[@"w"] intValue];
        int h_norm = [rectDict[@"h"] intValue];
        
        int x_orig = (int)((double)x_norm / scale);
        int y_orig = (int)((double)y_norm / scale);
        int w_orig = (int)((double)w_norm / scale);
        int h_orig = (int)((double)h_norm / scale);
        
        cv::Rect objRect(x_orig, y_orig, w_orig, h_orig);
        cv::rectangle(binaryMat, objRect, cv::Scalar(255), cv::FILLED);
    }
    
    // 5. 결과 이미지 변환 후 반환
    UIImage *resultImage = MatToUIImage(binaryMat);
    return resultImage;
}

+ (NSDictionary *)extractStavesOnly:(UIImage *)image {
    // 1. UIImage → cv::Mat 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    if (mat.empty()) {
        NSLog(@"extractStavesOnly: UIImageToMat 변환 실패");
        return @{@"image": image};
    }
    
    // 2. 그레이스케일 변환 및 이진화 (단일 채널로)
    cv::Mat gray;
    if (mat.channels() > 1) {
        cv::cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    } else {
        gray = mat;
    }
    cv::Mat binary;
    cv::threshold(gray, binary, 127, 255, cv::THRESH_BINARY);
    
    int height = binary.rows;
    int width = binary.cols;
    
    // 3. removeStavesFromImage와 동일한 방식으로 오선(보표) 영역을 그룹화합니다.
    //    각 원소는 (y 좌표, 오선 높이)로 구성됩니다.
    std::vector<std::pair<int, int>> staves;
    for (int row = 0; row < height; row++) {
        int whiteCount = 0;
        for (int col = 0; col < width; col++) {
            if (binary.at<uchar>(row, col) == 255)
                whiteCount++;
        }
        // 여기서는 이미지 너비의 50% 이상이 흰색이면 오선으로 판단합니다.
        if (whiteCount >= width * 0.5) {
            // 연속된 행이면 같은 오선으로 취급
            if (staves.empty() || std::abs((staves.back().first + staves.back().second) - row) > 1) {
                staves.push_back(std::make_pair(row, 0));
            } else {
                staves.back().second += 1;
            }
        }
    }
    
    // 4. 오선 영역만 표시하는 마스크 생성: 그룹화된 각 오선의 y 좌표부터 y+높이까지를 흰색(255)로 채웁니다.
    cv::Mat stavesMask = cv::Mat::zeros(binary.size(), binary.type());
    for (size_t i = 0; i < staves.size(); i++) {
        int top = staves[i].first;
        int bot = staves[i].first + staves[i].second;
        for (int row = top; row <= bot && row < height; row++) {
            for (int col = 0; col < width; col++) {
                stavesMask.at<uchar>(row, col) = 255;
            }
        }
    }
    
    // 5. (선택 사항) 팽창 연산을 적용하여 오선 영역을 확장합니다.
    //    커널 크기는 이미지와 오선 두께에 따라 조정 가능합니다.
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(15, 3));
    cv::Mat stavesDilated;
    cv::dilate(stavesMask, stavesDilated, kernel);
    
    UIImage *result = MatToUIImage(stavesDilated);
    return @{@"image": result};
}


+ (NSDictionary *)subtractMultipleImages:(UIImage *)processedImage
                           detectionImage:(UIImage *)detectionImage
                          stavesOnlyImage:(UIImage *)stavesOnlyImage {
    // 모든 이미지를 cv::Mat으로 변환
    cv::Mat procMat, detectMat, stavesMat;
    UIImageToMat(processedImage, procMat);
    UIImageToMat(detectionImage, detectMat);
    UIImageToMat(stavesOnlyImage, stavesMat);
    
    // 그레이스케일 변환 (필요 시)
    if (procMat.channels() > 1) {
        cv::cvtColor(procMat, procMat, cv::COLOR_BGR2GRAY);
    }
    if (detectMat.channels() > 1) {
        cv::cvtColor(detectMat, detectMat, cv::COLOR_BGR2GRAY);
    }
    if (stavesMat.channels() > 1) {
        cv::cvtColor(stavesMat, stavesMat, cv::COLOR_BGR2GRAY);
    }
    
    // 이진화
    cv::threshold(procMat, procMat, 127, 255, cv::THRESH_BINARY);
    cv::threshold(detectMat, detectMat, 127, 255, cv::THRESH_BINARY);
    cv::threshold(stavesMat, stavesMat, 127, 255, cv::THRESH_BINARY);
    
    // detectionImage와 stavesOnlyImage를 합친 마스크 생성 (두 영역은 제거되어야 함)
    cv::Mat combinedMask;
    cv::bitwise_or(detectMat, stavesMat, combinedMask);
    
    // 마스크 반전: 제거하지 않을 영역은 255로
    cv::Mat invMask;
    cv::bitwise_not(combinedMask, invMask);
    
    // processedImage와 invMask의 bitwise_and 연산으로 객체와 오선 영역 제거
    cv::Mat resultMat;
    cv::bitwise_and(procMat, invMask, resultMat);
    
    UIImage *resultImage = MatToUIImage(resultMat);
    return @{@"image": resultImage};
}

+ (UIImage *)processedImageFromImage:(UIImage *)image {
    // 1. UIImage → cv::Mat 변환
    cv::Mat mat;
    UIImageToMat(image, mat);
    
    // 2. 그레이스케일 변환
    cv::Mat gray;
    cvtColor(mat, gray, cv::COLOR_BGR2GRAY);
    
    // 3. 이진화 (THRESH_BINARY_INV | THRESH_OTSU 사용)
    cv::Mat binary;
    threshold(gray, binary, 0, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
    
    // processedImage: 여기서는 단순히 binary 이미지를 반환합니다.
    UIImage *result = MatToUIImage(binary);
    return result;
}

@end
