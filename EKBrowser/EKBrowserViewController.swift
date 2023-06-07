//
//  ViewController.swift
//  EKBrowser
//
//  Created by Eduard Kanevskii on 07.06.2023.
//

import UIKit
// I prefer programatically UI. IMHO SnapKit is the best library for programatically layout.
import SnapKit
import WebKit

// final - used for Direct dispatch
final class EKBrowserViewController: UIViewController {
    // private for encapsulation
    private let searchTextField = UITextField()
    private let webView = WKWebView()
    
    // used for auto request in textFieldDidEndEditing
    private var pendingRequestWorkItem: DispatchWorkItem?
    private let pendingValueForAutoRequest: Int = 2
    
    // Possible use init() if use DI, but for test project viewDidLoad also good.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews([searchTextField, webView])
        searchTextField.delegate = self
        searchTextField.placeholder = "Enter URL address"
        searchTextField.layer.borderColor = UIColor.darkGray.cgColor
        searchTextField.layer.borderWidth = UIConstants.borderWidth
        searchTextField.layer.cornerRadius = UIConstants.cornerRadius
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.top.rawValue)
            $0.leading.equalToSuperview().offset(Layout.leading.rawValue)
            $0.trailing.equalToSuperview().offset(Layout.trailing.rawValue)
            $0.height.equalTo(Layout.textFieldHeigh.rawValue)
        }
        
        webView.navigationDelegate = self
        webView.snp.makeConstraints {
            $0.top.equalTo(searchTextField.snp.bottom)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension EKBrowserViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // make request
        hideKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
//            if searchText.removeWhitespace().isEmpty {
//                self.stations.removeAll()
//            } else {
//                self.search(searchText)
//            }
            self.hideKeyboard()
        }
        
        pendingRequestWorkItem = requestWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(pendingValueForAutoRequest), execute: requestWorkItem)
    }
}

extension EKBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        print(url.absoluteString)
        
        decisionHandler(.allow)
    }
}

// Also possible use struct
enum Layout: Int {
    case top, leading = 8
    case bottom, trailing = -8
    case textFieldHeigh = 60
}

// Also possible use enum
struct UIConstants {
    static let cornerRadius: CGFloat = 8
    static let borderWidth: CGFloat = 1
}
