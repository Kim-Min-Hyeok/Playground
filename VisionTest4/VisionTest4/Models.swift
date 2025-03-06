// Models.swift
import Foundation
import CoreGraphics
import UIKit

// Content(파일 + 폴더)
enum ContentType: Int16 {
    case score = 0
    case songList = 1
    case folder = 2
}

struct ContentModel: Identifiable {
    var id: UUID { cid }
    let cid: UUID
    var name: String
    var path: String           // 실제 경로 (FileManager)
    var type: ContentType
    var parentContents: UUID?  // 상위 폴더의 cid
    var createdAt: Date
    var modifiedAt: Date
    var lastAccessedAt: Date
    var deletedAt: Date?
    var isTrash: Bool
    var originalParentId: UUID? // 복구 폴더
    var syncStatus: Bool        // 서버 동기화 여부
    var scoreDetails: [UUID]?   // ScoreDetailModel의 s_did 배열 (없을 수도 있음)
}

// ScoreDetail (score 항목에 대한 세부 정보)
struct ScoreDetailModel: Identifiable {
    var id: UUID { s_did }
    let s_did: UUID
    var key: String      // 원래 키
    var t_key: String    // 변환될 키
    var scorePages: [UUID]  // ScorePageModel의 s_pid 배열
}

// ScorePage (페이지별 데이터)
struct ScorePageModel: Identifiable {
    var id: UUID { s_pid }
    let s_pid: UUID
    var rotation: Int            // 예: 0, 4 (회전 각도 관련)
    var scoreAnnotations: [UUID] // 주석 식별자 배열
    var scoreMemos: [UUID]       // 메모 식별자 배열
    var scoreChords: [UUID]      // ScoreChordModel의 s_cid 배열
}

// ScoreChord (인식된 코드들)
struct ScoreChordModel: Identifiable {
    var id: UUID { s_cid }
    let s_cid: UUID
    var chord: String
    var x: Double      // 정규화된 좌표 (0~1)
    var y: Double
    var width: Double
    var height: Double
}

// PDF 페이지 이미지와 페이지 모델, 그리고 해당 페이지에 인식된 ScoreChordModel을 함께 관리하기 위한 헬퍼 모델
struct ScorePageData: Identifiable {
    var id: UUID { pageModel.s_pid }
    var originalImage: UIImage              // 선택한 원본 페이지 이미지
    var processedImage: UIImage?            // 전처리(OpenCV) 결과 이미지
    var pageModel: ScorePageModel
    var chords: [ScoreChordModel]           // OCR 결과 (전처리된 이미지 기준)
}
