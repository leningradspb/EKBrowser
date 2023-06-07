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
    private let historyButton = UIButton()
    private let webView = WKWebView()
    
    // used for auto request in textFieldDidEndEditing
    private var pendingRequestWorkItem: DispatchWorkItem?
    private let pendingValueForAutoRequest: Int = 2
    private let baseUrl = "https://www."
    private let searchTextFieldPlaceholder = "Enter URL address"
    private let historyButtonTitle = "History"
    
    // Possible use init() if use DI, but for test project viewDidLoad also good.
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubviews([searchTextField, historyButton, webView])
        searchTextField.delegate = self
        searchTextField.placeholder = searchTextFieldPlaceholder
        searchTextField.text = baseUrl
        searchTextField.layer.borderColor = UIColor.darkGray.cgColor
        searchTextField.layer.borderWidth = UIConstants.borderWidth
        searchTextField.layer.cornerRadius = UIConstants.cornerRadius
        searchTextField.addTarget(self, action: #selector(searchTextFieldEditingChanged), for: .editingChanged)
        
        searchTextField.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.top.rawValue)
            $0.leading.equalToSuperview().offset(Layout.leading.rawValue)
            $0.height.equalTo(Layout.textFieldHeigh.rawValue)
        }
        
        historyButton.setTitle(historyButtonTitle, for: .normal)
        historyButton.setTitle(historyButtonTitle, for: .selected)
        historyButton.setTitleColor(.black, for: .selected)
        historyButton.setTitleColor(.black, for: .normal)
        
        historyButton.addTarget(self, action: #selector(showNavigationActionsHistoryViewController), for: .touchUpInside)
        historyButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(Layout.top.rawValue)
            $0.leading.equalTo(searchTextField.snp.trailing).offset(Layout.leading.rawValue)
            $0.trailing.equalToSuperview().offset(Layout.trailing.rawValue)
            $0.width.equalTo(Layout.historyButtonWidth.rawValue)
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
    
    private func requestBy(URL: URL) {
        let request = URLRequest(url: URL)
        // MARK: - Here we have a warning in the console "[Security] This method should not be called on the main thread as it may lead to UI unresponsiveness." but webView.load can be called only in the main thread. IMHO its just Xcode 14 bug.
        self.webView.load(request)
    }
    
    /// Check is request needed
    @objc private func searchTextFieldEditingChanged() {
        pendingRequestWorkItem?.cancel()
        
        let requestWorkItem = DispatchWorkItem { [weak self] in
            // TODO in real project: handle else
            guard let self = self, let searchText = self.searchTextField.text else { return }
            
            if !searchText.trimmingCharacters(in: .whitespaces).isEmpty, let url = URL(string: searchText) {
                self.requestBy(URL: url)
            }
            self.hideKeyboard()
        }
        
        pendingRequestWorkItem = requestWorkItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(pendingValueForAutoRequest), execute: requestWorkItem)
    }
    
    @objc private func showNavigationActionsHistoryViewController() {
        
    }
}

extension EKBrowserViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // todo: handle case in real project
        guard let searchText = textField.text else { return true }
        
        if !searchText.trimmingCharacters(in: .whitespaces).isEmpty, let url = URL(string: searchText) {
            self.requestBy(URL: url)
        }
        hideKeyboard()
        return true
    }
}

extension EKBrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        print(url.absoluteString)
        if var savedLinks = UserDefaults.standard.array(forKey: UserDefaultsKeys.links) as? [URL] {
            savedLinks.append(url)
            UserDefaults.standard.set(savedLinks, forKey: UserDefaultsKeys.links)
        } else {
            UserDefaults.standard.set([url], forKey: UserDefaultsKeys.links)
        }
        
        
        decisionHandler(.allow)
    }
}

// Also possible use struct
enum Layout: Int {
    case top, leading = 8
    case bottom, trailing = -8
    case textFieldHeigh = 60
    case historyButtonWidth = 80
}

// Also possible use enum
struct UIConstants {
    static let cornerRadius: CGFloat = 8
    static let borderWidth: CGFloat = 1
}

struct UserDefaultsKeys {
    static let links: String = links
}
