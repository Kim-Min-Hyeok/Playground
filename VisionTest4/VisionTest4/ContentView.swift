// ContentView.swift
import SwiftUI

struct ContentView: View {
    @State private var showingFilePicker = false
    @State private var showingPhotoPicker = false
    @State private var pdfURL: URL?
    @State private var rawPages: [UIImage] = []      
    @State private var scorePages: [ScorePageData] = []
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScoreView(scorePages: scorePages.isEmpty ? rawPages.map {
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
    
    private func buttonAreaHeight(in geometry: GeometryProxy) -> CGFloat {
        return 80
    }
    
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
    
    func extractPages(from url: URL) {
        let pages = PDFProcessor.extractPages(from: url)
        self.rawPages = pages
        var pagesData: [ScorePageData] = []
        for image in pages {
            let pageModel = ScorePageModel(s_pid: UUID(), rotation: 0, scoreAnnotations: [], scoreMemos: [], scoreChords: [])
            let pageData = ScorePageData(originalImage: image, processedImage: nil, pageModel: pageModel, chords: [])
            pagesData.append(pageData)
        }
        self.scorePages = pagesData
    }
    
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
