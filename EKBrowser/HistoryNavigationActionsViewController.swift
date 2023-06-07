//
//  HistoryNavigationActionsViewController.swift
//  EKBrowser
//
//  Created by Eduard Kanevskii on 08.06.2023.
//

import UIKit

final class HistoryNavigationActionsViewController: UIViewController {
    private let tableView = UITableView()
    // TODO: handle in production
    private let historyItems: [String] = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.links)?.reversed() ?? []
    
    // also we can use delegate
    var urlTapped: ((String)->())?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        print(historyItems.count)
        historyItems.forEach {
            print($0)
        }
    
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.top.rawValue)
            $0.leading.equalToSuperview().offset(Layout.leading.rawValue)
            $0.trailing.equalToSuperview().offset(Layout.trailing.rawValue)
            $0.bottom.equalToSuperview().offset(Layout.bottom.rawValue)
        }
        // in production custom cell
    }

}

extension HistoryNavigationActionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        historyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        // MARK: - not safety. handle in production array count > cells count
        cell.textLabel?.text = historyItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = historyItems[indexPath.row]
        urlTapped?(url)
        self.dismiss(animated: true)
    }
}
