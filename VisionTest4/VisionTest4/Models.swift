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
    var path: String
    var type: ContentType
    var parentContents: UUID?
    var createdAt: Date
    var modifiedAt: Date
    var lastAccessedAt: Date
    var deletedAt: Date?
    var isTrash: Bool
    var originalParentId: UUID?
    var syncStatus: Bool
    var scoreDetails: [UUID]?
}

struct ScoreDetailModel: Identifiable {
    var id: UUID { s_did }
    let s_did: UUID
    var key: String
    var t_key: String
    var scorePages: [UUID]
}

// ScorePage (페이지별 데이터)
struct ScorePageModel: Identifiable {
    var id: UUID { s_pid }
    let s_pid: UUID
    var rotation: Int
    var scoreAnnotations: [UUID]
    var scoreMemos: [UUID]
    var scoreChords: [UUID]
}

// ScoreChord (인식된 코드들)
struct ScoreChordModel: Identifiable {
    var id: UUID { s_cid }
    let s_cid: UUID
    var chord: String
    var x: Double
    var y: Double
    var width: Double
    var height: Double
}

struct ScorePageData: Identifiable {
    var id: UUID { pageModel.s_pid }
    var originalImage: UIImage
    var processedImage: UIImage?
    var pageModel: ScorePageModel
    var chords: [ScoreChordModel]         
}
