import RIBs
import Main
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        rootRouter = Builder(dependency: ApplicationComponent()).build()
        rootRouter?.launchFromWindow(window)
        self.window = window
        return true
    }

    private var rootRouter: LaunchRouting?
}
