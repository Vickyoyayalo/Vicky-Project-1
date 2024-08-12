//
//  HomePageViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/18.
//
import UIKit
import Kingfisher
import MJRefresh

// MARK: - HomePageViewController

class HomePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MarketManagerDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // MARK: - Properties
    var hotsList: [Hots] = []
    let marketManager = MarketManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        marketManager.delegate = self
        marketManager.getMarketingHots()
        
        let header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refresh))
        tableView.mj_header = header
    }
    
    // MARK: - Refresh Action
    @objc func refresh() {
        marketManager.getMarketingHots()
    }
    
    // MARK: - MarketManagerDelegate Methods
    func manager(_ manager: MarketManager, didGetHots hots: [Hots]) {
        DispatchQueue.main.async {
            self.hotsList = hots
            self.tableView.reloadData()
            self.tableView.mj_header?.endRefreshing()
        }
    }

    func manager(_ manager: MarketManager, didGetProducts products: [Product]) {
    }
    
    func manager(_ manager: MarketManager, didFailWith error: Error) {
        print("獲取數據失敗: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return hotsList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotsList[section].products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = hotsList[indexPath.section].products[indexPath.row]
        
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! Cell1
            cell.configure(with: product)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! Cell2
            cell.configure(with: product)
            return cell
        }
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = hotsList[indexPath.section].products[indexPath.row]
        performSegue(withIdentifier: "ShowDetailSegue", sender: product)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    // MARK: - TableView Header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        
        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.textColor = .black
        headerLabel.font = UIFont.boldSystemFont(ofSize: 20)
        headerLabel.text = hotsList[section].title
        headerView.backgroundColor = .white
        
        headerView.addSubview(headerLabel)
        NSLayoutConstraint.activate([
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20)
        ])
        
        return headerView
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetailSegue" {
            if let destinationVC = segue.destination as? DetailViewController,
               let product = sender as? Product {
                destinationVC.product = product
            }
        }
    }
    
    // MARK: - UI Update
    func reloadDataOrRefreshUI() {
        print("HomePageViewController: reloadDataOrRefreshUI called")
    }
}

// MARK: - Collection Extension

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
