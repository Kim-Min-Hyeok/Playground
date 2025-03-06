// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var pdfURL: URL?
    @State private var rawPages: [UIImage] = []         // 파일 또는 사진에서 추출한 원본 페이지 이미지
    @State private var scorePages: [ScorePageData] = []   // 전처리+OCR 결과가 적용된 페이지 데이터
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 악보 영역: 버튼 영역을 제외한 영역에 맞게 표시
                ScoreView(scorePages: scorePages.isEmpty ? rawPages.map {
                    // OCR 전처리 전인 경우, 빈 OCR 결과 및 전처리 이미지 없이 ScorePageData 생성
                    let pageModel = ScorePageModel(s_pid: UUID(), rotation: 0, scoreAnnotations: [], scoreMemos: [], scoreChords: [])
                    return ScorePageData(originalImage: $0, processedImage: nil, pageModel: pageModel, chords: [])
                } : scorePages)
                .frame(width: geometry.size.width,
                       height: geometry.size.height - buttonAreaHeight(in: geometry))
                .background(Color.gray.opacity(0.1))
                
                // 버튼 영역
                buttonArea
                    .frame(width: geometry.size.width, height: buttonAreaHeight(in: geometry))
                    .background(Color(white: 0.95))
                    .padding(.top, 20)
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            FilePicker { url in
                self.pdfURL = url
                self.extractPages(from: url)
            }
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPicker { url in
                self.pdfURL = url
                self.extractPages(from: url)
            }
        }
    }
    
    /// 버튼 영역 높이 (상황에 맞게 조정 가능)
    private func buttonAreaHeight(in geometry: GeometryProxy) -> CGFloat {
        return 80
    }
    
    /// 버튼 영역: 파일 선택, 앨범 선택, 코드 인식
    private var buttonArea: some View {
        HStack(spacing: 20) {
            Button("파일 앱에서 선택") {
                showingFilePicker = true
            }
            .padding()
            
            Button("앨범에서 선택") {
                showingPhotoPicker = true
            }
            .padding()
            
            Button("코드 인식") {
                processScoreRecognition()
            }
            .padding()
        }
    }
    
    /// PDF 파일에서 페이지를 추출하여 rawPages에 저장합니다.
    func extractPages(from url: URL) {
        let pages = PDFProcessor.extractPages(from: url)
        self.rawPages = pages
        // 초기에는 OCR 결과가 없으므로, scorePages는 rawPages 기반의 빈 결과로 구성
        var pagesData: [ScorePageData] = []
        for image in pages {
            let pageModel = ScorePageModel(s_pid: UUID(), rotation: 0, scoreAnnotations: [], scoreMemos: [], scoreChords: [])
            let pageData = ScorePageData(originalImage: image, processedImage: nil, pageModel: pageModel, chords: [])
            pagesData.append(pageData)
        }
        self.scorePages = pagesData
    }
    
    /// 선택된 rawPages에 대해 ScoreProcessor를 사용하여 전처리 및 OCR(코드 인식)을 수행합니다.
    func processScoreRecognition() {
        let group = DispatchGroup()
        var pagesData: [ScorePageData] = []
        
        for image in rawPages {
            group.enter()
            ScoreProcessor.processScore(image) { (processedImage, chords) in
                let chordIDs = chords.map { $0.s_cid }
                let pageModel = ScorePageModel(
                    s_pid: UUID(),
                    rotation: 0,
                    scoreAnnotations: [],
                    scoreMemos: [],
                    scoreChords: chordIDs
                )
                let pageData = ScorePageData(originalImage: image, processedImage: processedImage, pageModel: pageModel, chords: chords)
                pagesData.append(pageData)
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            self.scorePages = pagesData
        }
    }
}
