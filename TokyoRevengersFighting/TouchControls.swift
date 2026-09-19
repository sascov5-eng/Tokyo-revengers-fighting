import SpriteKit

final class TouchControls: SKNode {
    private let stickBase: SKShapeNode
    private let stickKnob: SKShapeNode
    private let jumpBtn: SKShapeNode
    private let blockBtn: SKShapeNode
    private let punchBtn: SKShapeNode
    private let kickBtn: SKShapeNode
    private let specialBtn: SKShapeNode
    private var stickTouch: UITouch?
    private var buttonTouches: [ObjectIdentifier: String] = [:]
    private(set) var moveX: CGFloat = 0
    private(set) var holdingBlock = false
    var jumpPressed = false
    var punchPressed = false
    var kickPressed = false
    var specialPressed = false

    init(sceneSize: CGSize) {
        func circle(_ r: CGFloat, fill: SKColor, text: String) -> SKShapeNode {
            let n = SKShapeNode(circleOfRadius: r)
            n.fillColor = fill
            n.strokeColor = SKColor.white.withAlphaComponent(0.35)
            n.lineWidth = 2
            n.zPosition = 100
            let l = SKLabelNode(fontNamed: "Menlo-Bold")
            l.text = text
            l.fontSize = 14
            l.fontColor = .white
            l.verticalAlignmentMode = .center
            l.horizontalAlignmentMode = .center
            n.addChild(l)
            return n
        }
        stickBase = SKShapeNode(circleOfRadius: 56)
        stickBase.fillColor = SKColor.white.withAlphaComponent(0.10)
        stickBase.strokeColor = SKColor.white.withAlphaComponent(0.28)
        stickBase.lineWidth = 2
        stickBase.position = CGPoint(x: 78, y: 86)
        stickKnob = SKShapeNode(circleOfRadius: 22)
        stickKnob.fillColor = SKColor.white.withAlphaComponent(0.38)
        stickKnob.strokeColor = .clear
        stickKnob.position = stickBase.position
        jumpBtn = circle(28, fill: SKColor.white.withAlphaComponent(0.16), text: "UP")
        blockBtn = circle(28, fill: SKColor.white.withAlphaComponent(0.16), text: "B")
        punchBtn = circle(32, fill: SKColor(red: 0.75, green: 0.22, blue: 0.22, alpha: 0.7), text: "P")
        kickBtn = circle(32, fill: SKColor(red: 0.20, green: 0.40, blue: 0.80, alpha: 0.7), text: "K")
        specialBtn = circle(30, fill: SKColor(red: 0.85, green: 0.70, blue: 0.15, alpha: 0.75), text: "S")
        super.init()
        zPosition = 200
        isUserInteractionEnabled = true
        let right = sceneSize.width
        jumpBtn.position = CGPoint(x: right - 168, y: 150)
        blockBtn.position = CGPoint(x: right - 92, y: 150)
        punchBtn.position = CGPoint(x: right - 168, y: 72)
        kickBtn.position = CGPoint(x: right - 92, y: 72)
        specialBtn.position = CGPoint(x: right - 48, y: 210)
        [stickBase, stickKnob, jumpBtn, blockBtn, punchBtn, kickBtn, specialBtn].forEach(addChild)
    }

    required init?(coder: NSCoder) { nil }

    func consumePresses() {
        jumpPressed = false
        punchPressed = false
        kickPressed = false
        specialPressed = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { handleDown(touch) }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch === stickTouch { updateStick(touch) }
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { handleUp(touch) }
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { handleUp(touch) }
    }

    private func handleDown(_ touch: UITouch) {
        let p = touch.location(in: self)
        if stickTouch == nil && p.x < 170 && p.y < 180 {
            stickTouch = touch
            updateStick(touch)
            return
        }
        if hit(jumpBtn, p, 34) { jumpPressed = true; buttonTouches[ObjectIdentifier(touch)] = "jump" }
        else if hit(blockBtn, p, 34) { holdingBlock = true; buttonTouches[ObjectIdentifier(touch)] = "block" }
        else if hit(punchBtn, p, 38) { punchPressed = true; buttonTouches[ObjectIdentifier(touch)] = "punch" }
        else if hit(kickBtn, p, 38) { kickPressed = true; buttonTouches[ObjectIdentifier(touch)] = "kick" }
        else if hit(specialBtn, p, 36) { specialPressed = true; buttonTouches[ObjectIdentifier(touch)] = "special" }
    }

    private func handleUp(_ touch: UITouch) {
        if touch === stickTouch {
            stickTouch = nil
            moveX = 0
            stickKnob.position = stickBase.position
        }
        if let kind = buttonTouches.removeValue(forKey: ObjectIdentifier(touch)), kind == "block" {
            holdingBlock = buttonTouches.values.contains("block")
        }
    }

    private func hit(_ node: SKNode, _ p: CGPoint, _ radius: CGFloat) -> Bool {
        hypot(p.x - node.position.x, p.y - node.position.y) <= radius
    }

    private func updateStick(_ touch: UITouch) {
        let p = touch.location(in: self)
        var dx = p.x - stickBase.position.x
        let maxR: CGFloat = 42
        dx = max(-maxR, min(maxR, dx))
        stickKnob.position = CGPoint(x: stickBase.position.x + dx, y: stickBase.position.y)
        moveX = dx / maxR
    }
}
