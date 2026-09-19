import SpriteKit
import UIKit

final class GameScene: SKScene {
    private let playerProfile: FighterProfile
    private var player: Fighter!
    private var enemy: Fighter!
    private var controls: TouchControls!
    private var groundY: CGFloat = 240
    private var pHP: SKLabelNode!
    private var eHP: SKLabelNode!
    private var timerLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var pBar: SKSpriteNode!
    private var eBar: SKSpriteNode!
    private var overlay: SKNode?
    private var arenaNodes: [SKNode] = []
    private var liveTouches = Set<ObjectIdentifier>()
    private var roundOver = false
    private var timeLeft: TimeInterval = 99
    private var lastUpdate: TimeInterval = 0
    private var built = false

    init(size: CGSize, playerProfile: FighterProfile) {
        self.playerProfile = playerProfile
        super.init(size: size)
    }

    required init?(coder: NSCoder) { nil }

    private var topInset: CGFloat { view?.safeAreaInsets.top ?? 50 }
    private var bottomInset: CGFloat { view?.safeAreaInsets.bottom ?? 20 }

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.07, green: 0.08, blue: 0.12, alpha: 1)
        anchorPoint = .zero
        isUserInteractionEnabled = true
        if !built {
            built = true
            buildOnce()
        }
        relayout()
        startRound()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard built else { return }
        relayout()
    }

    private func buildOnce() {
        controls = TouchControls()
        addChild(controls)
        player = Fighter(profile: playerProfile)
        enemy = Fighter(profile: Roster.other(than: playerProfile))
        addChild(player)
        addChild(enemy)
        pHP = makeLabel(align: .left)
        eHP = makeLabel(align: .right)
        timerLabel = makeLabel(align: .center)
        titleLabel = makeLabel(align: .center)
        titleLabel.fontSize = 12
        titleLabel.fontColor = SKColor.white.withAlphaComponent(0.35)
        titleLabel.text = "УЛИЦА ТОМАН"
        addChild(pHP)
        addChild(eHP)
        addChild(timerLabel)
        addChild(titleLabel)
        pBar = SKSpriteNode(color: SKColor(red: 0.25, green: 0.78, blue: 0.42, alpha: 1), size: CGSize(width: 150, height: 10))
        pBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        pBar.zPosition = 50
        addChild(pBar)
        eBar = SKSpriteNode(color: SKColor(red: 0.82, green: 0.28, blue: 0.28, alpha: 1), size: CGSize(width: 150, height: 10))
        eBar.anchorPoint = CGPoint(x: 1, y: 0.5)
        eBar.zPosition = 50
        addChild(eBar)
    }

    private func makeLabel(align: SKLabelHorizontalAlignmentMode) -> SKLabelNode {
        let n = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        n.fontSize = 14
        n.fontColor = .white
        n.horizontalAlignmentMode = align
        n.zPosition = 50
        return n
    }

    private func relayout() {
        controls.layout(in: size, bottomInset: bottomInset)
        groundY = controls.topOfControls + 28
        rebuildArena()
        let top = size.height - topInset - 22
        titleLabel.position = CGPoint(x: size.width / 2, y: top)
        pHP.position = CGPoint(x: 16, y: top - 26)
        eHP.position = CGPoint(x: size.width - 16, y: top - 26)
        timerLabel.position = CGPoint(x: size.width / 2, y: top - 26)
        pBar.position = CGPoint(x: 16, y: top - 42)
        eBar.position = CGPoint(x: size.width - 16, y: top - 42)
    }

    private func rebuildArena() {
        arenaNodes.forEach { $0.removeFromParent() }
        arenaNodes.removeAll()
        let sky = SKSpriteNode(color: SKColor(red: 0.10, green: 0.12, blue: 0.18, alpha: 1), size: size)
        sky.anchorPoint = .zero
        sky.zPosition = -10
        addChild(sky)
        let facadeH = max(220, size.height - groundY - topInset - 80)
        let building = SKSpriteNode(color: SKColor(red: 0.16, green: 0.17, blue: 0.22, alpha: 1), size: CGSize(width: size.width, height: facadeH))
        building.anchorPoint = CGPoint(x: 0, y: 0)
        building.position = CGPoint(x: 0, y: groundY)
        building.zPosition = -8
        addChild(building)
        let windowColor = SKColor(red: 0.85, green: 0.72, blue: 0.28, alpha: 0.35)
        let cols = max(5, Int(size.width / 62))
        var nodes: [SKNode] = [sky, building]
        for col in 0..<cols {
            for row in 0..<3 {
                let w = SKSpriteNode(color: windowColor, size: CGSize(width: 28, height: 36))
                w.position = CGPoint(x: 36 + CGFloat(col) * 62, y: groundY + 56 + CGFloat(row) * 58)
                w.zPosition = -7
                addChild(w)
                nodes.append(w)
            }
        }
        let ground = SKSpriteNode(color: SKColor(red: 0.18, green: 0.16, blue: 0.14, alpha: 1), size: CGSize(width: size.width, height: groundY))
        ground.anchorPoint = CGPoint(x: 0, y: 0)
        ground.zPosition = -6
        addChild(ground)
        nodes.append(ground)
        arenaNodes = nodes
    }

    private func startRound() {
        overlay?.removeFromParent()
        overlay = nil
        roundOver = false
        timeLeft = 99
        lastUpdate = 0
        liveTouches.removeAll()
        controls.keepOnly([])
        controls.isHidden = false
        player.reset(at: CGPoint(x: 90, y: groundY), faceRight: true)
        enemy.reset(at: CGPoint(x: size.width - 90, y: groundY), faceRight: false)
        refreshHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 { lastUpdate = currentTime }
        let dt = min(0.05, currentTime - lastUpdate)
        lastUpdate = currentTime
        controls.keepOnly(liveTouches)
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
        liveTouches.removeAll()
        controls.keepOnly([])
        controls.isHidden = true
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

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !roundOver else { return }
        for touch in touches {
            liveTouches.insert(ObjectIdentifier(touch))
            controls.touchBegan(touch, at: touch.location(in: self))
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !roundOver else { return }
        for touch in touches {
            controls.touchMoved(touch, at: touch.location(in: self))
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if roundOver, let p = touches.first?.location(in: self) {
            let hit = nodes(at: p).compactMap { $0.name }
            if hit.contains("rematch") { startRound() }
            else if hit.contains("menu") {
                let menu = MenuScene(size: size)
                menu.scaleMode = scaleMode
                view?.presentScene(menu, transition: .fade(withDuration: 0.2))
            }
            return
        }
        for touch in touches {
            liveTouches.remove(ObjectIdentifier(touch))
            controls.touchEnded(touch)
        }
        controls.keepOnly(liveTouches)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            liveTouches.remove(ObjectIdentifier(touch))
            controls.touchEnded(touch)
        }
        controls.keepOnly(liveTouches)
    }
}
