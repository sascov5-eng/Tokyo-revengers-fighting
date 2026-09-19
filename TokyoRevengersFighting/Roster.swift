import SpriteKit

enum SpecialKind {
    case timeLeap
    case invincibleKick
}

struct FighterProfile {
    let id: String
    let name: String
    let role: String
    let specialName: String
    let specialKind: SpecialKind
    let bodyColor: SKColor
    let accentColor: SKColor
    let hairColor: SKColor
    let maxHP: CGFloat
    let speed: CGFloat
    let jumpVelocity: CGFloat
    let punchDamage: CGFloat
    let kickDamage: CGFloat
    let specialDamage: CGFloat
    let punchReach: CGFloat
    let kickReach: CGFloat
    let specialReach: CGFloat
    let punchLock: TimeInterval
    let kickLock: TimeInterval
    let specialLock: TimeInterval
    let specialCooldown: TimeInterval
    let blockMul: CGFloat
    let width: CGFloat
    let height: CGFloat
}

enum Roster {
    static let takemichi = FighterProfile(
        id: "takemichi",
        name: "Такемичи",
        role: "танк",
        specialName: "Time Leap",
        specialKind: .timeLeap,
        bodyColor: SKColor(red: 0.93, green: 0.93, blue: 0.90, alpha: 1),
        accentColor: SKColor(red: 0.20, green: 0.45, blue: 0.78, alpha: 1),
        hairColor: SKColor(red: 0.95, green: 0.78, blue: 0.28, alpha: 1),
        maxHP: 150,
        speed: 145,
        jumpVelocity: 400,
        punchDamage: 8,
        kickDamage: 11,
        specialDamage: 0,
        punchReach: 50,
        kickReach: 58,
        specialReach: 0,
        punchLock: 0.32,
        kickLock: 0.40,
        specialLock: 0.50,
        specialCooldown: 4.0,
        blockMul: 0.18,
        width: 54,
        height: 110
    )

    static let mikey = FighterProfile(
        id: "mikey",
        name: "Майки",
        role: "скорость",
        specialName: "Кик Майки",
        specialKind: .invincibleKick,
        bodyColor: SKColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1),
        accentColor: SKColor(red: 0.85, green: 0.78, blue: 0.20, alpha: 1),
        hairColor: SKColor(red: 0.97, green: 0.88, blue: 0.42, alpha: 1),
        maxHP: 100,
        speed: 255,
        jumpVelocity: 460,
        punchDamage: 7,
        kickDamage: 16,
        specialDamage: 26,
        punchReach: 48,
        kickReach: 64,
        specialReach: 92,
        punchLock: 0.24,
        kickLock: 0.30,
        specialLock: 0.38,
        specialCooldown: 2.4,
        blockMul: 0.30,
        width: 46,
        height: 98
    )

    static let all: [FighterProfile] = [takemichi, mikey]

    static func other(than profile: FighterProfile) -> FighterProfile {
        profile.id == takemichi.id ? mikey : takemichi
    }
}
