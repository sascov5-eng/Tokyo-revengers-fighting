import SpriteKit
import UIKit

final class TouchControls: SKNode {
    private let stickBase = SKShapeNode(circleOfRadius: 56)
    private let stickKnob = SKShapeNode(circleOfRadius: 22)
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

    override init() {
        func circle(_ r: CGFloat, fill: SKColor, text: String) -> SKShapeNode {
            let n = SKShapeNode(circleOfRadius: r)
            n.fillColor = fill
            n.strokeColor = SKColor.white.withAlphaComponent(0.4)
            n.lineWidth = 2
            n.zPosition = 100
            let l = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
            l.text = text
            l.fontSize = 15
            l.fontColor = .white
            l.verticalAlignmentMode = .center
            l.horizontalAlignmentMode = .center
            n.addChild(l)
            return n
        }
        jumpBtn = circle(30, fill: SKColor.white.withAlphaComponent(0.18), text: "UP")
        blockBtn = circle(30, fill: SKColor.white.withAlphaComponent(0.18), text: "B")
        punchBtn = circle(34, fill: SKColor(red: 0.75, green: 0.22, blue: 0.22, alpha: 0.85), text: "P")
        kickBtn = circle(34, fill: SKColor(red: 0.20, green: 0.40, blue: 0.80, alpha: 0.85), text: "K")
        specialBtn = circle(32, fill: SKColor(red: 0.85, green: 0.70, blue: 0.15, alpha: 0.85), text: "S")
        super.init()
        zPosition = 200
        isUserInteractionEnabled = false
        stickBase.fillColor = SKColor.white.withAlphaComponent(0.12)
        stickBase.strokeColor = SKColor.white.withAlphaComponent(0.35)
        stickBase.lineWidth = 2
        stickKnob.fillColor = SKColor.white.withAlphaComponent(0.42)
        stickKnob.strokeColor = .clear
        [stickBase, stickKnob, jumpBtn, blockBtn, punchBtn, kickBtn, specialBtn].forEach(addChild)
    }

    required init?(coder: NSCoder) { nil }

    func layout(in size: CGSize, bottomInset: CGFloat) {
        let pad = 18 + max(bottomInset, 8)
        stickBase.position = CGPoint(x: 78, y: pad + 56)
        stickKnob.position = stickBase.position
        let right = size.width
        punchBtn.position = CGPoint(x: right - 156, y: pad + 40)
        kickBtn.position = CGPoint(x: right - 78, y: pad + 40)
        jumpBtn.position = CGPoint(x: right - 156, y: pad + 118)
        blockBtn.position = CGPoint(x: right - 78, y: pad + 118)
        specialBtn.position = CGPoint(x: right - 36, y: pad + 188)
    }

    var topOfControls: CGFloat {
        max(stickBase.position.y + 70, specialBtn.position.y + 40)
    }

    func consumePresses() {
        jumpPressed = false
        punchPressed = false
        kickPressed = false
        specialPressed = false
    }

    func touchBegan(_ touch: UITouch, at p: CGPoint) {
        if stickTouch == nil && hypot(p.x - stickBase.position.x, p.y - stickBase.position.y) <= 72 {
            stickTouch = touch
            updateStick(p)
            return
        }
        if hit(jumpBtn, p, 42) { jumpPressed = true; buttonTouches[ObjectIdentifier(touch)] = "jump" }
        else if hit(blockBtn, p, 42) { holdingBlock = true; buttonTouches[ObjectIdentifier(touch)] = "block" }
        else if hit(punchBtn, p, 46) { punchPressed = true; buttonTouches[ObjectIdentifier(touch)] = "punch" }
        else if hit(kickBtn, p, 46) { kickPressed = true; buttonTouches[ObjectIdentifier(touch)] = "kick" }
        else if hit(specialBtn, p, 44) { specialPressed = true; buttonTouches[ObjectIdentifier(touch)] = "special" }
    }

    func touchMoved(_ touch: UITouch, at p: CGPoint) {
        if touch === stickTouch { updateStick(p) }
    }

    func touchEnded(_ touch: UITouch) {
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

    private func updateStick(_ p: CGPoint) {
        var dx = p.x - stickBase.position.x
        let maxR: CGFloat = 46
        dx = max(-maxR, min(maxR, dx))
        stickKnob.position = CGPoint(x: stickBase.position.x + dx, y: stickBase.position.y)
        moveX = dx / maxR
    }
}
