//
//  AccessoriesPageViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/26.
//
import UIKit
import Alamofire
import MJRefresh
import Kingfisher

class AccessoriesPageViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            collectionView.collectionViewLayout = layout
        }
    }
    
    // MARK: - Properties
    var marketManager = MarketManager()
    var products: [[Product]] = [] // 以二维数组存储分页数据
    var page: Int = 1
    var nextPage: Int? = 0
    var hasMoreProducts = true
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        marketManager.delegate = self
        loadData()
        
        MJRefreshConfig.default.languageCode = "en"
        collectionView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshData))
        collectionView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: {
            self.loadMoreData()
        })
    }
    
    // MARK: MJRefresh
    @objc private func refreshData() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.nextPage = 0
            self.hasMoreProducts = true
            self.products.removeAll()
            self.loadData()
            self.collectionView.mj_header?.endRefreshing()
            self.collectionView.mj_footer?.resetNoMoreData()
        }
    }
    
    func loadData() {
        if let nextPage = nextPage {
            self.marketManager.getProductListData(page: nextPage, category: "accessories")
        }
        nextPage = 1
    }
    
    func loadMoreData() {
        if let nextPage = nextPage, hasMoreProducts {
            self.marketManager.getProductListData(page: nextPage, category: "accessories")
        } else {
            self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension AccessoriesPageViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return products.flatMap { $0 }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if products.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccessoriesPageCell", for: indexPath) as! AccessoriesPageCell
            cell.productNameLabel.text = "Error"
            cell.productPriceLabel.text = "Error"
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AccessoriesPageCell", for: indexPath) as! AccessoriesPageCell
        
        let flattenedProducts = products.flatMap { $0 }
        let product = flattenedProducts[indexPath.item]
        cell.productNameLabel.text = product.title
        cell.productPriceLabel.text = "NT$\(product.price)"
        if let imageUrl = URL(string: product.mainImage) {
            cell.accessoriesImageView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "Image_Placeholder"))
        }
        
        return cell
    }
}

extension AccessoriesPageViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 70
        let itemsPerRow: CGFloat = 2
        
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - padding
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 320)
    }
}

// MARK: - MarketManagerDelegate
extension AccessoriesPageViewController: MarketManagerDelegate {
    
    func manager(_ manager: MarketManager, didGetHots hots: [Hots]) {
    }
    
    func manager(_ manager: MarketManager, didGetProducts products: [Product]) {
        if nextPage == 0 {
            self.products = [products]
        } else {
            self.products.append(products)
        }
        
        if nextPage == nil || products.count < 6 {
            self.hasMoreProducts = false
            self.collectionView.mj_footer?.endRefreshingWithNoMoreData()
        } else {
            self.collectionView.mj_footer?.endRefreshing()
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func manager(_ manager: MarketManager, didFailWith error: Error) {
        print("Failed to fetch products: \(error.localizedDescription)")
        DispatchQueue.main.async {
            self.collectionView.mj_footer?.endRefreshing()
        }
    }
}
extension AccessoriesPageViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let flattenedProducts = products.flatMap { $0 }
        let selectedProduct = flattenedProducts[indexPath.item]
        performSegue(withIdentifier: "AccessoriesDetailSegue", sender: selectedProduct)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccessoriesDetailSegue" {
            if let destinationVC = segue.destination as? DetailViewController,
               let product = sender as? Product {
                destinationVC.product = product
            }
        }
    }
}
