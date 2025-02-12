    //
    //  PreProcessing.mm
    //  ScanScore
    //
    //  Created by Minhyeok Kim on 1/28/25.
    //

    #import "PreProcessing.h"

    #ifdef __cplusplus
    #import <opencv2/core.hpp>
    #import <opencv2/imgproc.hpp>
    #import <opencv2/highgui.hpp>
    #import <opencv2/imgcodecs/ios.h>
    #endif

    #import <UIKit/UIKit.h>

    @implementation PreProcessing

    // 📌 1. 악보 이미지를 이진화하여 배경 제거
    + (UIImage *)threshold:(UIImage *)image {
        cv::Mat imageMat;
        UIImageToMat(image, imageMat);
        
        // 그레이스케일 변환
        cv::cvtColor(imageMat, imageMat, cv::COLOR_BGR2GRAY);
        
        // OTSU 임계처리 (이진화)
        cv::threshold(imageMat, imageMat, 127, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
        
        return MatToUIImage(imageMat);
    }

    // 📌 2. 보표(오선) 영역 검출 및 노이즈 제거
    + (UIImage *)removeNoise:(UIImage *)image {
        cv::Mat imageMat;
        UIImageToMat(image, imageMat);
        
        // 그레이스케일 변환
        cv::cvtColor(imageMat, imageMat, cv::COLOR_BGR2GRAY);
        
        // OTSU 임계처리 (이진화)
        cv::threshold(imageMat, imageMat, 127, 255, cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
        
        // 마스크 초기화
        cv::Mat mask = cv::Mat::zeros(imageMat.size(), CV_8UC1);
        
        // 레이블링을 통한 객체 검출
        cv::Mat labels, stats, centroids;
        int cnt = cv::connectedComponentsWithStats(imageMat, labels, stats, centroids);
        
        // 보표 영역 찾기
        for (int i = 1; i < cnt; i++) { // 0번은 배경이므로 제외
            int x = stats.at<int>(i, cv::CC_STAT_LEFT);
            int y = stats.at<int>(i, cv::CC_STAT_TOP);
            int w = stats.at<int>(i, cv::CC_STAT_WIDTH);
            int h = stats.at<int>(i, cv::CC_STAT_HEIGHT);
            
            if (w > imageMat.cols * 0.5) {  // 보표(오선) 영역만 선택
                cv::rectangle(mask, cv::Rect(x, y, w, h), cv::Scalar(255), -1);
            }
        }
        
        // 마스크 적용하여 보표만 추출
        cv::Mat maskedImage;
        cv::bitwise_and(imageMat, mask, maskedImage);
        
        return MatToUIImage(maskedImage);
    }

    // 📌 3. 오선 제거
    // 📌 2. 오선 제거 및 좌표 반환
    + (UIImage *)removeStaves:(UIImage *)image staves:(NSArray<NSNumber *> * _Nonnull * _Nonnull)staves {
        cv::Mat imageMat;
        UIImageToMat(image, imageMat);

        int height = imageMat.rows;
        int width = imageMat.cols;
        cv::Mat processedImage = imageMat.clone();

        std::vector<std::pair<int, int>> stavesVec;

        // 📌 1. 오선 감지 (수평 히스토그램 활용)
        for (int row = 0; row < height; row++) {
            int pixels = 0;
            for (int col = 0; col < width; col++) {
                if (imageMat.at<uchar>(row, col) == 255) {
                    pixels++;
                }
            }
            
            if (pixels >= width * 0.5) { // 이미지 넓이의 50% 이상이라면 오선으로 간주
                if (stavesVec.empty() || abs(stavesVec.back().first + stavesVec.back().second - row) > 1) {
                    stavesVec.push_back(std::make_pair(row, 1));
                } else {
                    stavesVec.back().second++;
                }
            }
        }

        if (stavesVec.empty()) {
            NSLog(@"[ERROR] 오선 감지 실패: 검출된 오선 없음");
            *staves = @[];
            return MatToUIImage(processedImage);
        }

        // 📌 2. 오선 제거 (위아래 픽셀 확인 후 삭제)
        for (const auto &staff : stavesVec) {
            int top_pixel = staff.first;
            int bot_pixel = staff.first + staff.second;

            for (int col = 0; col < width; col++) {
                if (top_pixel > 0 && bot_pixel < height - 1) {
                    if (imageMat.at<uchar>(top_pixel - 1, col) == 0 && imageMat.at<uchar>(bot_pixel + 1, col) == 0) {
                        for (int row = top_pixel; row <= bot_pixel; row++) {
                            processedImage.at<uchar>(row, col) = 0;
                        }
                    }
                }
            }
        }

        NSMutableArray<NSNumber *> *stavesArray = [NSMutableArray array];
        for (const auto &staff : stavesVec) {
            [stavesArray addObject:@(staff.first)];
        }
        
        *staves = [stavesArray copy];
        return MatToUIImage(processedImage);
    }

    // 📌 4. 악보 이미지 정규화
    + (UIImage *)normalizeImage:(UIImage *)image staves:(NSArray<NSNumber *> *)staves standard:(CGFloat)standard {
        if (staves.count == 0) {
            NSLog(@"[ERROR] 악보 정규화 실패: 오선 좌표(staves)가 비어 있음");
            return image;
        }

        cv::Mat imageMat;
        UIImageToMat(image, imageMat);

        int height = imageMat.rows;
        int width = imageMat.cols;

        double avgDistance = 0.0;
        int numStaves = (int)staves.count;
        int numLines = numStaves / 5;

        for (int line = 0; line < numLines; line++) {
            for (int staff = 0; staff < 4; staff++) {
                int staffAbove = [staves[line * 5 + staff] intValue];
                int staffBelow = [staves[line * 5 + staff + 1] intValue];
                avgDistance += std::abs(staffAbove - staffBelow);
            }
        }
        avgDistance /= (numStaves - numLines);

        // 🔹 가중치 계산 및 이미지 리사이징
        double scaleFactor = standard / avgDistance;
        int newWidth = static_cast<int>(width * scaleFactor);
        int newHeight = static_cast<int>(height * scaleFactor);

        cv::resize(imageMat, imageMat, cv::Size(newWidth, newHeight));
        cv::threshold(imageMat, imageMat, 127, 255, cv::THRESH_BINARY | cv::THRESH_OTSU);

        return MatToUIImage(imageMat);
    }

    @end
