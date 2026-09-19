import SpriteKit

enum FighterState: String {
    case idle, walk, punch, kick, special, block, hit, ko
}

final class Fighter: SKNode {
    let profile: FighterProfile
    private(set) var hp: CGFloat
    private(set) var state: FighterState = .idle
    var facingRight = true
    var onGround = true

    private var velocity = CGVector.zero
    private var stateTime: TimeInterval = 0
    private var hitstun: TimeInterval = 0
    private var attackLock: TimeInterval = 0
    private var invuln: TimeInterval = 0
    private var specialCooldown: TimeInterval = 0
    private var punchCool: TimeInterval = 0
    private var kickCool: TimeInterval = 0

    private let body: SKShapeNode
    private let head: SKShapeNode
    private let hair: SKShapeNode
    private let label: SKLabelNode

    var intentMove: CGFloat = 0
    var intentJump = false
    var intentBlock = false
    var intentPunch = false
    var intentKick = false
    var intentSpecial = false

    var hitbox: CGRect {
        CGRect(x: position.x - profile.width / 2, y: position.y, width: profile.width, height: profile.height)
    }

    var isAttacking: Bool {
        state == .punch || state == .kick || state == .special
    }

    var isBlocking: Bool { state == .block }
    var isDown: Bool { state == .ko }
    var isInvulnerable: Bool { invuln > 0 }

    init(profile: FighterProfile) {
        self.profile = profile
        self.hp = profile.maxHP
        body = SKShapeNode(rectOf: CGSize(width: profile.width, height: profile.height * 0.62), cornerRadius: 8)
        body.fillColor = profile.bodyColor
        body.strokeColor = profile.accentColor
        body.lineWidth = 2
        body.position = CGPoint(x: 0, y: profile.height * 0.38)
        head = SKShapeNode(circleOfRadius: 16)
        head.fillColor = SKColor(red: 0.96, green: 0.84, blue: 0.72, alpha: 1)
        head.strokeColor = .clear
        head.position = CGPoint(x: 0, y: profile.height * 0.78)
        hair = SKShapeNode(rectOf: CGSize(width: 34, height: 16), cornerRadius: 6)
        hair.fillColor = profile.hairColor
        hair.strokeColor = .clear
        hair.position = CGPoint(x: 0, y: profile.height * 0.88)
        label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = profile.name
        label.fontSize = 11
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: profile.height + 16)
        super.init()
        addChild(body)
        addChild(head)
        addChild(hair)
        addChild(label)
    }

    required init?(coder: NSCoder) { nil }

    func reset(at point: CGPoint, faceRight: Bool) {
        position = point
        facingRight = faceRight
        hp = profile.maxHP
        velocity = .zero
        state = .idle
        stateTime = 0
        hitstun = 0
        attackLock = 0
        invuln = 0
        specialCooldown = 0
        alpha = 1
        xScale = faceRight ? 1 : -1
        label.xScale = faceRight ? 1 : -1
    }

    func takeHit(damage: CGFloat, fromRight: Bool) {
        guard state != .ko else { return }
        if isInvulnerable { return }
        if isBlocking {
            hp = max(0, hp - damage * 0.25)
            velocity.dx = fromRight ? -80 : 80
            return
        }
        hp = max(0, hp - damage)
        state = hp <= 0 ? .ko : .hit
        stateTime = 0
        hitstun = hp <= 0 ? 0 : 0.28
        velocity.dx = fromRight ? -220 : 220
        velocity.dy = hp <= 0 ? 220 : 80
        onGround = false
        if state == .ko { alpha = 0.7 }
    }

    func update(dt: TimeInterval, groundY: CGFloat, minX: CGFloat, maxX: CGFloat, opponent: Fighter?) {
        specialCooldown = max(0, specialCooldown - dt)
        punchCool = max(0, punchCool - dt)
        kickCool = max(0, kickCool - dt)
        invuln = max(0, invuln - dt)
        attackLock = max(0, attackLock - dt)
        stateTime += dt
        if invuln > 0 {
            alpha = 0.45 + 0.35 * CGFloat(sin(stateTime * 24))
        } else if state != .ko {
            alpha = 1
        }
        if state == .ko {
            applyPhysics(dt: dt, groundY: groundY, minX: minX, maxX: maxX)
            return
        }
        if state == .hit {
            hitstun -= dt
            applyPhysics(dt: dt, groundY: groundY, minX: minX, maxX: maxX)
            if hitstun <= 0 && onGround { enter(.idle) }
            return
        }
        if attackLock <= 0 {
            if intentSpecial && specialCooldown <= 0 {
                performSpecial()
            } else if intentPunch && punchCool <= 0 {
                enter(.punch)
                punchCool = 0.35
                attackLock = 0.28
            } else if intentKick && kickCool <= 0 {
                enter(.kick)
                kickCool = 0.42
                attackLock = 0.34
            } else if intentBlock {
                enter(.block)
                intentMove = 0
            } else if abs(intentMove) > 0.2 {
                enter(.walk)
            } else if state != .idle {
                enter(.idle)
            }
        }
        if intentJump && onGround && state != .block {
            velocity.dy = 420
            onGround = false
        }
        let spd = profile.speed * (state == .block ? 0.25 : 1)
        if attackLock <= 0 && state != .block {
            velocity.dx = intentMove * spd
        } else if state == .block {
            velocity.dx = 0
        }
        if velocity.dx > 12 { facingRight = true }
        if velocity.dx < -12 { facingRight = false }
        xScale = facingRight ? 1 : -1
        label.xScale = facingRight ? 1 : -1
        applyPhysics(dt: dt, groundY: groundY, minX: minX, maxX: maxX)
        resolveAttacks(against: opponent)
        clearOneShots()
    }

    private func performSpecial() {
        specialCooldown = 2.2
        enter(.special)
        attackLock = 0.45
        if profile.id == "takemichi" {
            invuln = 0.55
            velocity.dx = facingRight ? -280 : 280
            hp = min(profile.maxHP, hp + 8)
        } else {
            velocity.dx = facingRight ? 340 : -340
        }
    }

    private func resolveAttacks(against opponent: Fighter?) {
        guard let foe = opponent, !foe.isDown, isAttacking else { return }
        let reach: CGFloat = state == .special ? 70 : 54
        let dir: CGFloat = facingRight ? 1 : -1
        let box = CGRect(x: position.x + dir * 10, y: position.y + 20, width: dir * reach, height: 50).standardized
        guard box.intersects(foe.hitbox) else { return }
        if stateTime < 0.06 || stateTime > 0.22 { return }
        if abs(stateTime - 0.12) > 0.03 { return }
        let dmg: CGFloat
        switch state {
        case .punch: dmg = profile.punchDamage
        case .kick: dmg = profile.kickDamage
        case .special: dmg = profile.id == "takemichi" ? 0 : profile.specialDamage
        default: dmg = 0
        }
        if dmg > 0 { foe.takeHit(damage: dmg, fromRight: facingRight) }
    }

    private func applyPhysics(dt: TimeInterval, groundY: CGFloat, minX: CGFloat, maxX: CGFloat) {
        velocity.dy -= 1400 * dt
        position.x += velocity.dx * dt
        position.y += velocity.dy * dt
        if position.y <= groundY {
            position.y = groundY
            velocity.dy = 0
            onGround = true
        }
        position.x = min(max(position.x, minX + profile.width / 2), maxX - profile.width / 2)
    }

    private func enter(_ next: FighterState) {
        if state != next {
            state = next
            stateTime = 0
        }
    }

    private func clearOneShots() {
        intentJump = false
        intentPunch = false
        intentKick = false
        intentSpecial = false
    }
}
