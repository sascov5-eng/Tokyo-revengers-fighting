import SpriteKit

final class GameScene: SKScene {
    private var player: Fighter!
    private var enemy: Fighter!
    private var controls: TouchControls!
    private var groundY: CGFloat = 210
    private var pHP: SKLabelNode!
    private var eHP: SKLabelNode!
    private var pBar: SKSpriteNode!
    private var eBar: SKSpriteNode!
    private var banner: SKLabelNode!
    private var roundOver = false

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
        anchorPoint = .zero
        drawArena()
        player = Fighter(profile: Roster.takemichi)
        enemy = Fighter(profile: Roster.mikey)
        addChild(player)
        addChild(enemy)
        controls = TouchControls(sceneSize: size)
        addChild(controls)
        pHP = makeLabel(x: 16, y: size.height - 58, align: .left)
        eHP = makeLabel(x: size.width - 16, y: size.height - 58, align: .right)
        addChild(pHP)
        addChild(eHP)
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
        banner = SKLabelNode(fontNamed: "Menlo-Bold")
        banner.fontSize = 18
        banner.fontColor = .white
        banner.position = CGPoint(x: size.width / 2, y: size.height * 0.55)
        banner.zPosition = 80
        addChild(banner)
        startRound()
    }

    private func makeLabel(x: CGFloat, y: CGFloat, align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let n = SKLabelNode(fontNamed: "Menlo-Bold")
        n.fontSize = 13
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
        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "TOMAN STREET"
        title.fontSize = 12
        title.fontColor = SKColor.white.withAlphaComponent(0.35)
        title.position = CGPoint(x: size.width / 2, y: size.height - 36)
        title.zPosition = 40
        addChild(title)
    }

    private func startRound() {
        roundOver = false
        banner.text = ""
        player.reset(at: CGPoint(x: 90, y: groundY), faceRight: true)
        enemy.reset(at: CGPoint(x: size.width - 90, y: groundY), faceRight: false)
    }

    override func update(_ currentTime: TimeInterval) {
        let dt: TimeInterval = 1.0 / 60.0
        guard !roundOver else { return }
        player.intentMove = controls.moveX
        player.intentJump = controls.jumpPressed
        player.intentBlock = controls.holdingBlock
        player.intentPunch = controls.punchPressed
        player.intentKick = controls.kickPressed
        player.intentSpecial = controls.specialPressed
        controls.consumePresses()
        thinkCPU(dt: dt)
        player.update(dt: dt, groundY: groundY, minX: 0, maxX: size.width, opponent: enemy)
        enemy.update(dt: dt, groundY: groundY, minX: 0, maxX: size.width, opponent: player)
        refreshHUD()
        if player.isDown || enemy.isDown {
            roundOver = true
            banner.text = player.isDown ? "MIKEY WINS  \u00b7  tap" : "TAKEMICHI WINS  \u00b7  tap"
        }
    }

    private func thinkCPU(dt: TimeInterval) {
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
        pBar.xScale = max(0.02, player.hp / player.profile.maxHP)
        eBar.xScale = max(0.02, enemy.hp / enemy.profile.maxHP)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if roundOver { startRound() }
    }
}
