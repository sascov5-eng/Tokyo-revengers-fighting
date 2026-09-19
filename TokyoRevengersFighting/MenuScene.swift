import SpriteKit

final class MenuScene: SKScene {
    private var cards: [String: CGRect] = [:]

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
        removeAllChildren()
        cards.removeAll()

        let sky = SKSpriteNode(color: SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1), size: size)
        sky.anchorPoint = .zero
        sky.zPosition = -10
        addChild(sky)

        let ground = SKSpriteNode(color: SKColor(red: 0.16, green: 0.14, blue: 0.12, alpha: 1), size: CGSize(width: size.width, height: 160))
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.zPosition = -8
        addChild(ground)

        addLabel("ТОКИЙСКИЕ МСТИТЕЛИ", size: 22, y: self.size.height - 86, color: .white)
        addLabel("ФАЙТИНГ", size: 14, y: self.size.height - 112, color: SKColor.white.withAlphaComponent(0.55))
        addLabel("Кем играть", size: 16, y: self.size.height - 168, color: .white)
        addLabel("Второй всегда CPU", size: 12, y: self.size.height - 190, color: SKColor.white.withAlphaComponent(0.45))

        layoutCard(Roster.takemichi, y: size.height * 0.52)
        layoutCard(Roster.mikey, y: size.height * 0.30)

        addLabel("фаза 1 - заглушки", size: 11, y: 48, color: SKColor.white.withAlphaComponent(0.28))
    }

    private func addLabel(_ text: String, size: CGFloat, y: CGFloat, color: SKColor) {
        let n = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        n.text = text
        n.fontSize = size
        n.fontColor = color
        n.position = CGPoint(x: self.size.width / 2, y: y)
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
            fight.scaleMode = scaleMode
            view?.presentScene(fight, transition: .fade(withDuration: 0.2))
        }
    }
}
