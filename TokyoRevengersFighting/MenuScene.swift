import SpriteKit
import UIKit

final class MenuScene: SKScene {
    private var cards: [String: CGRect] = [:]

    override func didMove(to view: SKView) {
        rebuild()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        rebuild()
    }

    private func rebuild() {
        removeAllChildren()
        cards.removeAll()
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
        isUserInteractionEnabled = true

        let sky = SKSpriteNode(color: SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1), size: size)
        sky.anchorPoint = .zero
        sky.zPosition = -10
        addChild(sky)

        let ground = SKSpriteNode(color: SKColor(red: 0.16, green: 0.14, blue: 0.12, alpha: 1), size: CGSize(width: size.width, height: 140))
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.zPosition = -8
        addChild(ground)

        let top = size.height - (view?.safeAreaInsets.top ?? 50) - 24
        addLabel("ТОКИЙСКИЕ МСТИТЕЛИ", font: 22, y: top, color: .white)
        addLabel("ФАЙТИНГ", font: 14, y: top - 28, color: SKColor.white.withAlphaComponent(0.55))
        addLabel("Кем играть", font: 16, y: top - 80, color: .white)
        addLabel("Второй всегда CPU", font: 12, y: top - 102, color: SKColor.white.withAlphaComponent(0.45))

        layoutCard(Roster.takemichi, y: size.height * 0.50)
        layoutCard(Roster.mikey, y: size.height * 0.30)
        addLabel("фаза 1 - заглушки", font: 11, y: 24 + (view?.safeAreaInsets.bottom ?? 8), color: SKColor.white.withAlphaComponent(0.28))
    }

    private func addLabel(_ text: String, font: CGFloat, y: CGFloat, color: SKColor) {
        let n = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        n.text = text
        n.fontSize = font
        n.fontColor = color
        n.position = CGPoint(x: size.width / 2, y: y)
        n.zPosition = 10
        addChild(n)
    }

    private func layoutCard(_ profile: FighterProfile, y: CGFloat) {
        let w = size.width - 56
        let h: CGFloat = 118
        let rect = CGRect(x: 28, y: y - h / 2, width: w, height: h)
        cards[profile.id] = rect

        let bg = SKShapeNode(rect: rect, cornerRadius: 14)
        bg.fillColor = SKColor.white.withAlphaComponent(0.08)
        bg.strokeColor = profile.accentColor
        bg.lineWidth = 2
        bg.zPosition = 5
        addChild(bg)

        let swatch = SKShapeNode(rectOf: CGSize(width: 36, height: 64), cornerRadius: 8)
        swatch.fillColor = profile.bodyColor
        swatch.strokeColor = profile.accentColor
        swatch.lineWidth = 2
        swatch.position = CGPoint(x: rect.minX + 40, y: rect.midY)
        swatch.zPosition = 6
        addChild(swatch)

        let name = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        name.text = profile.name
        name.fontSize = 22
        name.fontColor = .white
        name.horizontalAlignmentMode = .left
        name.position = CGPoint(x: rect.minX + 72, y: rect.midY + 10)
        name.zPosition = 6
        addChild(name)

        let role = SKLabelNode(fontNamed: "HelveticaNeue")
        role.text = profile.role + "   HP \(Int(profile.maxHP))"
        role.fontSize = 13
        role.fontColor = SKColor.white.withAlphaComponent(0.6)
        role.horizontalAlignmentMode = .left
        role.position = CGPoint(x: rect.minX + 72, y: rect.midY - 16)
        role.zPosition = 6
        addChild(role)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let p = touches.first?.location(in: self) else { return }
        if let id = cards.first(where: { $0.value.contains(p) })?.key {
            let profile = id == Roster.takemichi.id ? Roster.takemichi : Roster.mikey
            let fight = GameScene(size: size, playerProfile: profile)
            fight.scaleMode = .resizeFill
            view?.presentScene(fight, transition: .fade(withDuration: 0.2))
        }
    }
}
