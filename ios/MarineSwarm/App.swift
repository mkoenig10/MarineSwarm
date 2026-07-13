import UIKit
import WebKit

final class GameViewController: UIViewController {
    private var webView: WKWebView!

    // Games own the screen edges: first swipe shows the system indicator,
    // second swipe acts. Keeps mid-battle tray taps from minimizing the app.
    override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge { .all }
    override var prefersHomeIndicatorAutoHidden: Bool { true }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []

        webView = WKWebView(frame: view.bounds, configuration: cfg)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        view.addSubview(webView)

        guard let url = Bundle.main.url(forResource: "marine-swarm", withExtension: "html") else {
            fatalError("marine-swarm.html missing from bundle — check the Copy Bundle Resources phase")
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let w = UIWindow(frame: UIScreen.main.bounds)
        w.rootViewController = GameViewController()
        w.makeKeyAndVisible()
        window = w
        return true
    }
}
