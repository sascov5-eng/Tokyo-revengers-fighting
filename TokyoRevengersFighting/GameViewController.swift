import SpriteKit
import UIKit

final class GameViewController: UIViewController {
    override var prefersStatusBarHidden: Bool { true }
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation { .portrait }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    override func loadView() {
        view = SKView(frame: UIScreen.main.bounds)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let skView = view as? SKView else { return }
        skView.ignoresSiblingOrder = true
        skView.isMultipleTouchEnabled = true
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif

        let scene = MenuScene(size: CGSize(width: 390, height: 844))
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)
    }
}
