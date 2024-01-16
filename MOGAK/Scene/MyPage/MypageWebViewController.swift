//
//  MypageWebViewController.swift
//  MOGAK
//
//  Created by 김라영 on 2023/11/30.
//

import Foundation
import WebKit
import SnapKit

class MypageWebViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var url: WebUrl = .perm
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.frame = CGRect(x: 0, y: 30, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        webView.uiDelegate = self
        view = UIView()
        view.addSubview(webView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.standardAppearance = navBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openWebPage()
    }
    
    func openWebPage() {
        guard let url = URL(string: self.url.rawValue) else { return }
        let request = URLRequest(url: url)
        
        webView.load(request)
    }
    

    
    
    
}
