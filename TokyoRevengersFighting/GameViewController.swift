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
        skView.preferredFramesPerSecond = 60
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let skView = view as? SKView, skView.bounds.width > 1 else { return }
        if skView.scene == nil {
            let scene = MenuScene(size: skView.bounds.size)
            scene.scaleMode = .resizeFill
            skView.presentScene(scene)
        } else if skView.scene!.size != skView.bounds.size {
            skView.scene!.size = skView.bounds.size
        }
    }
}
