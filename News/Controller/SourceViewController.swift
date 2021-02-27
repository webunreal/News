//
//  SourceViewController.swift
//  News
//
//  Created by Nikolai Ivanov on 14.02.2021.
//

import UIKit
import WebKit

class SourceViewController: UIViewController {
    @IBOutlet private weak var webView: WKWebView!
    public var urlToSource: String = ""
    
    override func viewDidLoad() {
        
        if let url = URL(string: urlToSource) {
            webView.load(URLRequest(url: url))
        }
        super.viewDidLoad()
    }
    
}
