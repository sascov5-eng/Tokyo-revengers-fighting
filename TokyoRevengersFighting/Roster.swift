import SpriteKit

struct FighterProfile {
    let id: String
    let name: String
    let role: String
    let bodyColor: SKColor
    let accentColor: SKColor
    let hairColor: SKColor
    let maxHP: CGFloat
    let speed: CGFloat
    let punchDamage: CGFloat
    let kickDamage: CGFloat
    let specialDamage: CGFloat
    let width: CGFloat
    let height: CGFloat
}

enum Roster {
    static let takemichi = FighterProfile(
        id: "takemichi",
        name: "Такемичи",
        role: "танк",
        bodyColor: SKColor(red: 0.93, green: 0.93, blue: 0.90, alpha: 1),
        accentColor: SKColor(red: 0.20, green: 0.45, blue: 0.78, alpha: 1),
        hairColor: SKColor(red: 0.92, green: 0.55, blue: 0.22, alpha: 1),
        maxHP: 140,
        speed: 160,
        punchDamage: 7,
        kickDamage: 10,
        specialDamage: 0,
        width: 52,
        height: 108
    )

    static let mikey = FighterProfile(
        id: "mikey",
        name: "Майки",
        role: "скорость",
        bodyColor: SKColor(red: 0.10, green: 0.10, blue: 0.12, alpha: 1),
        accentColor: SKColor(red: 0.85, green: 0.78, blue: 0.20, alpha: 1),
        hairColor: SKColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1),
        maxHP: 110,
        speed: 230,
        punchDamage: 8,
        kickDamage: 14,
        specialDamage: 22,
        width: 48,
        height: 100
    )

    static let all: [FighterProfile] = [takemichi, mikey]

    static func other(than profile: FighterProfile) -> FighterProfile {
        profile.id == takemichi.id ? mikey : takemichi
    }
}
