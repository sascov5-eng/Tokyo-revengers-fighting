import SpriteKit

final class GameScene: SKScene {
    private let playerProfile: FighterProfile
    private var player: Fighter!
    private var enemy: Fighter!
    private var controls: TouchControls!
    private var groundY: CGFloat = 210
    private var pHP: SKLabelNode!
    private var eHP: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var pBar: SKSpriteNode!
    private var eBar: SKSpriteNode!
    private var overlay: SKNode?
    private var roundOver = false
    private var timeLeft: TimeInterval = 99
    private var lastUpdate: TimeInterval = 0

    init(size: CGSize, playerProfile: FighterProfile) {
        self.playerProfile = playerProfile
        super.init(size: size)
    }

    required init?(coder: NSCoder) { nil }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
        anchorPoint = .zero
        isUserInteractionEnabled = true
        drawArena()
        player = Fighter(profile: playerProfile)
        enemy = Fighter(profile: Roster.other(than: playerProfile))
        addChild(player)
        addChild(enemy)
        controls = TouchControls(sceneSize: size)
        addChild(controls)
        pHP = makeLabel(x: 16, y: size.height - 58, align: .left)
        eHP = makeLabel(x: size.width - 16, y: size.height - 58, align: .right)
        timerLabel = makeLabel(x: size.width / 2, y: size.height - 58, align: .center)
        addChild(pHP)
        addChild(eHP)
        addChild(timerLabel)
        pBar = SKSpriteNode(color: SKColor(red: 0.25, green: 0.78, blue: 0.42, alpha: 1), size: CGSize(width: 150, height: 10))
        pBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        pBar.position = CGPoint(x: 16, y: size.height - 74)
        pBar.zPosition = 50
        addChild(pBar)
        eBar = SKSpriteNode(color: SKColor(red: 0.82, green: 0.28, blue: 0.28, alpha: 1), size: CGSize(width: 150, height: 10))
        eBar.anchorPoint = CGPoint(x: 1, y: 0.5)
        eBar.position = CGPoint(x: size.width - 16, y: size.height - 74)
        eBar.zPosition = 50
        addChild(eBar)
        startRound()
    }

    private func makeLabel(x: CGFloat, y: CGFloat, align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let n = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        n.fontSize = 14
        n.fontColor = .white
        n.horizontalAlignmentMode = align
        n.position = CGPoint(x: x, y: y)
        n.zPosition = 50
        return n
    }

    private func drawArena() {
        let sky = SKSpriteNode(color: SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1), size: size)
        sky.anchorPoint = .zero
        sky.zPosition = -10
        addChild(sky)
        let building = SKSpriteNode(color: SKColor(red: 0.16, green: 0.17, blue: 0.22, alpha: 1), size: CGSize(width: size.width, height: 280))
        building.anchorPoint = CGPoint(x: 0, y: 0)
        building.position = CGPoint(x: 0, y: groundY)
        building.zPosition = -8
        addChild(building)
        let windowColor = SKColor(red: 0.85, green: 0.72, blue: 0.28, alpha: 0.35)
        for col in 0..<6 {
            for row in 0..<3 {
                let w = SKSpriteNode(color: windowColor, size: CGSize(width: 28, height: 36))
                w.position = CGPoint(x: 40 + CGFloat(col) * 62, y: groundY + 70 + CGFloat(row) * 64)
                w.zPosition = -7
                addChild(w)
            }
        }
        let ground = SKSpriteNode(color: SKColor(red: 0.18, green: 0.16, blue: 0.14, alpha: 1), size: CGSize(width: size.width, height: groundY))
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.zPosition = -6
        addChild(ground)
        let title = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        title.text = "УЛИЦА ТОМАН"
        title.fontSize = 12
        title.fontColor = SKColor.white.withAlphaComponent(0.35)
        title.position = CGPoint(x: size.width / 2, y: size.height - 36)
        title.zPosition = 40
        addChild(title)
    }

    private func startRound() {
        overlay?.removeFromParent()
        overlay = nil
        roundOver = false
        timeLeft = 99
        lastUpdate = 0
        controls.isHidden = false
        controls.isUserInteractionEnabled = true
        player.reset(at: CGPoint(x: 90, y: groundY), faceRight: true)
        enemy.reset(at: CGPoint(x: size.width - 90, y: groundY), faceRight: false)
        refreshHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        let dt = min(0.05, currentTime - lastUpdate)
        lastUpdate = currentTime
        guard !roundOver else { return }
        timeLeft = max(0, timeLeft - dt)
        player.intentMove = controls.moveX
        player.intentJump = controls.jumpPressed
        player.intentBlock = controls.holdingBlock
        player.intentPunch = controls.punchPressed
        player.intentKick = controls.kickPressed
        player.intentSpecial = controls.specialPressed
        controls.consumePresses()
        thinkCPU()
        player.update(dt: dt, groundY: groundY, minX: 0, maxX: size.width, opponent: enemy)
        enemy.update(dt: dt, groundY: groundY, minX: 0, maxX: size.width, opponent: player)
        refreshHUD()
        if player.isDown || enemy.isDown || timeLeft <= 0 {
            finishRound()
        }
    }

    private func thinkCPU() {
        let dx = player.position.x - enemy.position.x
        enemy.intentMove = 0
        enemy.intentBlock = false
        if abs(dx) > 70 {
            enemy.intentMove = dx > 0 ? 0.7 : -0.7
        } else {
            let roll = Int.random(in: 0..<100)
            if roll < 8 { enemy.intentPunch = true }
            else if roll < 14 { enemy.intentKick = true }
            else if roll < 17 { enemy.intentSpecial = true }
            else if roll < 22 { enemy.intentBlock = true }
        }
        if player.position.y > groundY + 40 && Int.random(in: 0..<100) < 4 {
            enemy.intentJump = true
        }
    }

    private func refreshHUD() {
        pHP.text = "\(player.profile.name)  \(Int(player.hp))"
        eHP.text = "\(Int(enemy.hp))  \(enemy.profile.name)"
        timerLabel.text = String(format: "%02d", Int(ceil(timeLeft)))
        pBar.xScale = max(0.02, player.hp / player.profile.maxHP)
        eBar.xScale = max(0.02, enemy.hp / enemy.profile.maxHP)
    }

    private func finishRound() {
        guard !roundOver else { return }
        roundOver = true
        controls.isHidden = true
        controls.isUserInteractionEnabled = false

        let title: String
        if player.isDown && enemy.isDown { title = "НИЧЬЯ" }
        else if player.isDown { title = "ПОРАЖЕНИЕ" }
        else if enemy.isDown { title = "ПОБЕДА" }
        else if player.hp > enemy.hp { title = "ПОБЕДА" }
        else if enemy.hp > player.hp { title = "ПОРАЖЕНИЕ" }
        else { title = "НИЧЬЯ" }

        let layer = SKNode()
        layer.zPosition = 300
        layer.name = "overlay"
        overlay = layer
        addChild(layer)

        let dim = SKSpriteNode(color: SKColor.black.withAlphaComponent(0.55), size: size)
        dim.anchorPoint = .zero
        dim.zPosition = 0
        layer.addChild(dim)

        let banner = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        banner.text = title
        banner.fontSize = 28
        banner.fontColor = .white
        banner.position = CGPoint(x: size.width / 2, y: size.height * 0.58)
        banner.zPosition = 2
        layer.addChild(banner)

        addButton(to: layer, name: "rematch", title: "Реванш", y: size.height * 0.44)
        addButton(to: layer, name: "menu", title: "В меню", y: size.height * 0.34)
    }

    private func addButton(to parent: SKNode, name: String, title: String, y: CGFloat) {
        let w: CGFloat = 220
        let h: CGFloat = 52
        let rect = CGRect(x: size.width / 2 - w / 2, y: y - h / 2, width: w, height: h)
        let node = SKShapeNode(rect: rect, cornerRadius: 12)
        node.fillColor = SKColor.white.withAlphaComponent(0.14)
        node.strokeColor = SKColor.white.withAlphaComponent(0.5)
        node.lineWidth = 1.5
        node.name = name
        node.zPosition = 2
        parent.addChild(node)
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = title
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: y)
        label.name = name
        label.zPosition = 3
        parent.addChild(label)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard roundOver, let p = touches.first?.location(in: self) else { return }
        let hit = nodes(at: p).compactMap { $0.name }
        if hit.contains("rematch") {
            startRound()
        } else if hit.contains("menu") {
            let menu = MenuScene(size: size)
            menu.scaleMode = scaleMode
            view?.presentScene(menu, transition: .fade(withDuration: 0.2))
        }
    }
}
