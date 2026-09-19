import SpriteKit
import UIKit

enum SpriteBank {
    private static var cache: [String: SKTexture] = [:]

    static func texture(_ key: String) -> SKTexture? {
        if let t = cache[key] { return t }
        let b64 = SpriteDataA.blobs[key] ?? SpriteDataB.blobs[key]
        guard let raw = b64,
              let data = Data(base64Encoded: raw, options: .ignoreUnknownCharacters),
              let img = UIImage(data: data),
              let cg = img.cgImage else { return nil }
        let t = SKTexture(cgImage: cg)
        t.filteringMode = .nearest
        cache[key] = t
        return t
    }
}
