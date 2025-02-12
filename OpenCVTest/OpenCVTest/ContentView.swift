import SwiftUI

struct ContentView: View {
    // 각 단계별 결과 이미지 상태 변수
    @State private var originalImage: UIImage? = nil
    @State private var noiseRemovedImage: UIImage? = nil
    @State private var stavesImage: UIImage? = nil
    @State private var normalizedImage: UIImage? = nil
    @State private var detectionImage: UIImage? = nil
    @State private var finalImage: UIImage? = nil

    @State private var stavesArray: [NSNumber]? = nil

    // 앨범에서 선택된 이미지
    @State private var selectedImage: UIImage? = nil
    @State private var isShowingImagePicker = false
    @State private var displayImage: UIImage? = nil

    var body: some View {
        HStack {
            if let img = displayImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 500)
                    .border(Color.gray, width: 1)
            } else {
                Text("이미지를 선택하세요")
                    .foregroundColor(.gray)
                    .frame(maxWidth: 500)
            }

            VStack(spacing: 10) {
                Button("앨범에서 선택") {
                    isShowingImagePicker = true
                }
                .padding()

                Button("노이즈 제거") {
                    guard let input = displayImage else {
                        print("노이즈 제거: 입력 이미지 없음")
                        return
                    }
                    let result = OpenCVWrapper.removeNoise(from: input)
                    noiseRemovedImage = result
                    displayImage = result
                    print("노이즈 제거 완료")
                }
                .padding()

                Button("오선 제거") {
                    guard let input = displayImage else {
                        print("오선 제거: 입력 이미지 없음")
                        return
                    }
                    let result = OpenCVWrapper.removeStaves(from: input)
                    if let sImage = result["image"] as? UIImage,
                       let staves = result["staves"] as? [NSNumber] {
                        stavesImage = sImage
                        stavesArray = staves
                        displayImage = sImage
                        print("오선 제거 완료")
                    } else {
                        print("오선 제거 에러")
                    }
                }
                .padding()

                Button("객체 검출") {
                    guard let input = stavesImage, let staves = stavesArray else {
                        print("⚠️ 객체 검출 실패: 입력 이미지 또는 staves 없음")
                        return
                    }

                    let result = OpenCVWrapper.detectObjects(in: input, withStaves: staves)

                    if let dictResult = result as? NSDictionary {
                        detectionImage = dictResult["image"] as? UIImage
                        displayImage = dictResult["image"] as? UIImage
                        print("✅ 객체 검출 완료")
                    } else {
                        print("⚠️ 객체 검출 실패: OpenCVWrapper에서 반환된 값이 없음")
                    }
                }
                .padding()

                Button("검출 객체 제거") {
                    // (기존 검출 객체 제거 코드)
                    guard let detectedImg = detectionImage else {
                        print("⚠️ 검출 객체 제거 실패: detectionImage가 없음")
                        return
                    }
                    
                    guard let originalImg = originalImage else {
                        print("⚠️ 검출 객체 제거 실패: 원본 이미지가 없음")
                        return
                    }
                    let procImg = OpenCVWrapper.processedImage(from: originalImg)
                    
                    guard let stavesOnlyDict = OpenCVWrapper.extractStavesOnly(noiseRemovedImage!) as? NSDictionary,
                          let stavesOnlyImg = stavesOnlyDict["image"] as? UIImage else {
                        print("⚠️ 검출 객체 제거 실패: 오선만 있는 이미지 생성 실패")
                        return
                    }
                    
                    if let finalDict = OpenCVWrapper.subtractMultipleImages(procImg,
                                                                            detectionImage: detectedImg,
                                                                            stavesOnlyImage: stavesOnlyImg) as? NSDictionary,
                       let finalImg = finalDict["image"] as? UIImage {
                        finalImage = finalImg
                        displayImage = finalImg
                        print("✅ 검출 객체 제거 완료 (이미지 차이 연산 적용)")
                    } else {
                        print("⚠️ 검출 객체 제거 실패")
                    }
                }
                .padding()
                
                // ★ 텍스트 인식 버튼 추가 ★
                Button("텍스트 인식") {
                    // 여기서는 displayImage(또는 원본/처리된 이미지 중 원하는 이미지를 사용)를 대상으로 인식합니다.
                    guard let input = displayImage else {
                        print("텍스트 인식: 입력 이미지 없음")
                        return
                    }
                    
                    TextExtractionManager.extractText(from: input) { recognizedImage in
                        DispatchQueue.main.async {
                            if let recognizedImage = recognizedImage {
                                displayImage = recognizedImage
                                print("텍스트 인식 완료")
                            } else {
                                print("텍스트 인식 실패")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("단계별 악보 인식")
        .sheet(isPresented: $isShowingImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { newValue in
            if let img = newValue {
                originalImage = img
                displayImage = img
                print("앨범에서 이미지 선택 완료")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
