import UIKit
import WebKit
import SnapKit

final class MG2WebViewController: UIViewController {
    private let destination: MG2WebDestination
    private let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())

    init(destination: MG2WebDestination) {
        self.destination = destination
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = .white
        rootView.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalTo(rootView.safeAreaLayoutGuide)
        }
        view = rootView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: destination.rawValue) else { return }
        webView.load(URLRequest(url: url))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.isHidden = false
    }
}
