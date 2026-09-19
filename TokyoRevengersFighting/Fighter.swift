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
    var specialReady: Bool { specialCooldown <= 0 }

    private var velocity = CGVector.zero
    private var stateTime: TimeInterval = 0
    private var hitstun: TimeInterval = 0
    private var attackLock: TimeInterval = 0
    private var invuln: TimeInterval = 0
    private var specialCooldown: TimeInterval = 0
    private var punchCool: TimeInterval = 0
    private var kickCool: TimeInterval = 0
    private var struckThisMove = false

    private let sprite: SKSpriteNode
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
        sprite = SKSpriteNode(texture: SpriteBank.texture("\(profile.id)_idle"))
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0)
        sprite.size = CGSize(width: profile.width * 1.85, height: profile.height * 1.45)
        sprite.position = .zero
        sprite.zPosition = 2
        label = SKLabelNode(fontNamed: "HelveticaNeue-Bold")
        label.text = profile.name
        label.fontSize = 11
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.position = CGPoint(x: 0, y: profile.height + 18)
        super.init()
        addChild(sprite)
        addChild(label)
        applyPose()
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
        punchCool = 0
        kickCool = 0
        struckThisMove = false
        alpha = 1
        xScale = faceRight ? 1 : -1
        label.xScale = faceRight ? 1 : -1
        applyPose()
    }

    func takeHit(damage: CGFloat, fromRight: Bool) {
        guard state != .ko else { return }
        if isInvulnerable { return }
        if isBlocking {
            hp = max(0, hp - damage * profile.blockMul)
            velocity.dx = fromRight ? -60 : 60
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
        applyPose()
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
                struckThisMove = false
                punchCool = profile.punchLock + 0.08
                attackLock = profile.punchLock
            } else if intentKick && kickCool <= 0 {
                enter(.kick)
                struckThisMove = false
                kickCool = profile.kickLock + 0.10
                attackLock = profile.kickLock
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
            velocity.dy = profile.jumpVelocity
            onGround = false
        }
        let spd = profile.speed * (state == .block ? 0.20 : 1)
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
        specialCooldown = profile.specialCooldown
        enter(.special)
        struckThisMove = false
        attackLock = profile.specialLock
        switch profile.specialKind {
        case .timeLeap:
            invuln = 0.70
            velocity.dx = facingRight ? -300 : 300
            hp = min(profile.maxHP, hp + 14)
        case .invincibleKick:
            velocity.dx = facingRight ? 420 : -420
        }
    }

    private func resolveAttacks(against opponent: Fighter?) {
        guard let foe = opponent, !foe.isDown, isAttacking, !struckThisMove else { return }
        let reach: CGFloat
        switch state {
        case .punch: reach = profile.punchReach
        case .kick: reach = profile.kickReach
        case .special: reach = profile.specialReach
        default: return
        }
        guard reach > 0 else { return }
        guard stateTime >= 0.06 && stateTime <= min(0.28, attackLock + 0.12) else { return }
        let dir: CGFloat = facingRight ? 1 : -1
        let box = CGRect(x: position.x + dir * 8, y: position.y + 16, width: dir * reach, height: 56).standardized
        guard box.intersects(foe.hitbox) else { return }
        let dmg: CGFloat
        switch state {
        case .punch: dmg = profile.punchDamage
        case .kick: dmg = profile.kickDamage
        case .special: dmg = profile.specialDamage
        default: dmg = 0
        }
        guard dmg > 0 else { return }
        struckThisMove = true
        foe.takeHit(damage: dmg, fromRight: facingRight)
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
            applyPose()
        }
    }

    private func applyPose() {
        let suffix: String
        switch state {
        case .punch: suffix = "punch"
        case .kick: suffix = "kick"
        case .block: suffix = "block"
        case .special: suffix = "special"
        case .hit, .ko: suffix = "block"
        default: suffix = "idle"
        }
        if let t = SpriteBank.texture("\(profile.id)_\(suffix)") {
            sprite.texture = t
        }
    }

    private func clearOneShots() {
        intentJump = false
        intentPunch = false
        intentKick = false
        intentSpecial = false
    }
}
