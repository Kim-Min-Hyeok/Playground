import Foundation

/// ChordFilter는 문자열이 코드(Chord) 형식에 맞는지 판별하는 기능을 제공합니다.
public struct ChordFilter {
    /// 텍스트가 코드(Chord) 형식에 맞는지 정규표현식을 통해 판별합니다.
    /// - Parameter text: 인식된 텍스트 문자열.
    /// - Returns: 코드 형식이면 true, 아니면 false.
    public static func isChord(_ text: String) -> Bool {
        // 공백 제거 및 대문자 변환 (코드 표기는 대문자 사용이 일반적)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        // 예시 정규표현식: A~G로 시작, 선택적으로 # 또는 B (플랫), 그리고 선택적 코드 표기법(maj, min, dim, aug, sus, add 등) 및 숫자, 또는 슬래시(/) 형태
        let pattern = #"^[A-G](#|B)?((M(AJ)?)|(MIN)|(DIM)|(AUG)|(SUS)|(ADD))?[0-9]*(/[A-G](#|B)?)?$"#
        
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        
        let range = NSRange(location: 0, length: trimmed.utf16.count)
        let match = regex.firstMatch(in: trimmed, options: [], range: range)
        return match != nil
    }
}
