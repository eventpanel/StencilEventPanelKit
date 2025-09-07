//
// StencilSwiftKit
// Copyright © 2024 SwiftGen
// MIT Licence
//

import Foundation

// Official list of valid identifier characters for Kotlin
private extension CharRange {
  static func mr(_ char: Int) -> CharRange {
    char...char
  }

  static let headRanges: [CharRange] = [
    0x61...0x7a as CharRange, // a-z
    0x41...0x5a as CharRange, // A-Z
    mr(0x5f), // _
    // Note: Kotlin also allows some Unicode letters, but for simplicity and compatibility
    // we're focusing on the basic Latin alphabet and underscore
  ]

  static let tailRanges: [CharRange] = [
    0x30...0x39, // 0-9
    // Note: Kotlin allows some Unicode letters in the tail position,
    // but for simplicity we're focusing on digits
  ]
}

private extension CharacterSet {
  static let illegalIdentifierHead = setFromRanges(CharRange.headRanges)
  static let illegalIdentifierTail = setFromRanges(CharRange.headRanges + CharRange.tailRanges)

  static func setFromRanges(_ ranges: [CharRange]) -> CharacterSet {
    var result = CharacterSet()
    for range in ranges {
      guard let lower = Unicode.Scalar(range.lowerBound), let upper = Unicode.Scalar(range.upperBound) else { continue }
      result.insert(charactersIn: lower...upper)
    }
    return result
  }
}

enum KotlinIdentifier {
  static func identifier(
    from string: String,
    capitalizeComponents: Bool = true,
    replaceWithUnderscores underscores: Bool = false
  ) -> String {
    let parts = string.components(separatedBy: CharacterSet.illegalIdentifierTail.inverted)
    let replacement = underscores ? "_" : ""
    let mappedParts = !capitalizeComponents ? parts : parts.map { part in
      // Can't use capitalizedString here because it will lowercase all letters after the first
      guard let first = part.unicodeScalars.first else { return part }
      return String(first).uppercased() + String(part.unicodeScalars.dropFirst())
    }

    let result = mappedParts.joined(separator: replacement)
    return prefixWithUnderscoreIfNeeded(string: result)
  }

  static func prefixWithUnderscoreIfNeeded(string: String) -> String {
    guard let firstChar = string.unicodeScalars.first else { return "" }
    let prefix = !CharacterSet.illegalIdentifierHead.contains(firstChar) ? "_" : ""

    return prefix + string
  }
} 
