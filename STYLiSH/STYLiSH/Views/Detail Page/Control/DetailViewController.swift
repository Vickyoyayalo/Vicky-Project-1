//
//  DetailViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/31.
//
import UIKit
import CoreData
import Kingfisher
import StatusAlert

// MARK: - DetailViewController

class DetailViewController: UIViewController, MarketManagerDelegate, CartButtonDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var addtoCartButton: UIButton!
    @IBOutlet var containerView: UIView!
    
    // MARK: - Properties
    
    private var isContainerViewVisible = false
    var cartItems: [CartItem] = []
    var selectedColorCode: String?
    var selectedQuantity: Int = 1
    var selectedSize: String?
    var product: Product?
    var cartButtonVC: CartButtonVC?
    var images: [String] = []
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        
        if let product = product {
            print("Product received: \(product.title)")
        } else {
            print("No product received.")
        }
        
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back01"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        containerView.isHidden = true
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 20
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Button Actions
    
    @IBAction func addtoCartButtonTapped(_ sender: UIButton) {
        if isContainerViewVisible {
            if let product = product, let color = selectedColorCode, let size = selectedSize {
                let price = "\(product.price)"
                let image = product.mainImage
                
                if let variant = product.variants?.first(where: { $0.colorCode == color && $0.size == size }) {
                    let stock = variant.stock
                    
                    if selectedQuantity > 0 && selectedQuantity <= stock {
                    
                        StorageManager.shared.addCartItem(
                            productName: product.title,
                            price: price,
                            quantity: selectedQuantity,
                            color: color,
                            size: size,
                            image: image,
                            stock: Int(Int32(stock))
                        )
                        
                        if let savedItems = StorageManager.shared.fetchCartItems().first(where: { $0.productName == product.title }) {
                            print("Item saved: \(savedItems.productName ?? "")")
                        } else {
                            print("Failed to save item.")
                        }
                        
                        NotificationCenter.default.post(name: .cartUpdated, object: nil)
                        
                        completeAddToCartAction()
                    } else {
                        print("Selected quantity is not valid or exceeds stock")
                    }
                } else {
                    print("Variant not found for selected color and size")
                }
            } else {
                print("Size or Color not selected")
            }
        } else {
            showProductDetailView()
        }
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - MarketManagerDelegate
    
       func manager(_ manager: MarketManager, didGetHots hots: [Hots]) {
           DispatchQueue.main.async {
               self.tableView.reloadData()
           }
       }
       
       func manager(_ manager: MarketManager, didGetProducts products: [Product]) {
           if let product = products.first {
               self.product = product
               DispatchQueue.main.async {
                   self.tableView.reloadData()
               }
           }
       }
       
       func manager(_ manager: MarketManager, didFailWith error: Error) {
           print("Failed to get data: \(error.localizedDescription)")
       }
    
    // MARK: - Cart Handling
    
    private func addToCart() {
        if let product = product, let color = selectedColorCode, let size = selectedSize {
            let price = "\(product.price)"
            let image = product.mainImage
            
            if let variant = product.variants?.first(where: { $0.colorCode == color && $0.size == size }) {
                let stock = variant.stock
                
                if selectedQuantity > 0 && selectedQuantity <= stock {
                    StorageManager.shared.addCartItem(
                        productName: product.title,
                        price: price,
                        quantity: selectedQuantity,
                        color: color,
                        size: size,
                        image: image,
                        stock: Int(Int32(stock))
                    )
                    
                    NotificationCenter.default.post(name: .cartUpdated, object: nil)
                    completeAddToCartAction()
                } else {
                    print("Selected quantity is not valid or exceeds stock")
                }
            } else {
                print("Variant not found for selected color and size")
            }
        } else {
            print("Size or Color not selected")
        }
    }
    
    func didSelectedQuantityChange(quantity: Int) {
        self.selectedQuantity = quantity
    }
    
    func didUpdateSelection(colorCode: String?, size: String?) {
        self.selectedColorCode = colorCode
        self.selectedSize = size
        
        let canEnableAddToCart = (colorCode != nil && size != nil && !(size?.isEmpty ?? true))
        didEnableAddToCartButton(canEnableAddToCart)
    }
    
    func didEnableAddToCartButton(_ isEnabled: Bool) {
        addtoCartButton.isEnabled = isEnabled
        addtoCartButton.backgroundColor = isEnabled ? UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0) : .lightGray
    }
    
    // MARK: - UI Updates
    
    private func showProductDetailView() {
        addtoCartButton.isEnabled = false
        addtoCartButton.backgroundColor = UIColor.lightGray
        darkenImageView()
        containerView.isHidden = false
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
        isContainerViewVisible = true
    }
    
    private func completeAddToCartAction() {
        addtoCartButton.isEnabled = true
        addtoCartButton.backgroundColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0)
        addtoCartButton.setTitleColor(.white, for: .normal)
        lightenImageView()
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
        }) { _ in
            self.containerView.isHidden = true
        }
        
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Success01")
        statusAlert.title = "加入購物車"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.sizesAndDistances.alertWidth = 175
        statusAlert.sizesAndDistances.minimumAlertHeight = 175
        statusAlert.appearance.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        statusAlert.appearance.tintColor = .white
        statusAlert.showInKeyWindow()
        
        isContainerViewVisible = false
    }
    
    private func darkenImageView() {
        guard let imageView = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageViewCell else {
            return
        }
        let darkOverlay = UIView(frame: imageView.bounds)
        darkOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        darkOverlay.isUserInteractionEnabled = false
        darkOverlay.tag = 100
        imageView.addSubview(darkOverlay)
    }
    
    private func lightenImageView() {
        guard let imageView = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageViewCell else {
            return
        }
        if let darkOverlay = imageView.viewWithTag(100) {
            darkOverlay.removeFromSuperview()
        }
    }
    
    // MARK: - Cell Configuration
    
    private func configureDetailStyleCell(for indexPath: IndexPath, with product: Product) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailStyleCell.self), for: indexPath) as! DetailStyleCell
        
        switch indexPath.row {
        case 4:
            let sizesText = product.sizes?.joined(separator: " - ") ?? "無資料"
            cell.configure(with: "尺寸   |  ", content: sizesText)
        case 5:
            let stock = product.variants?.reduce(0) { $0 + $1.stock } ?? 0
            cell.configure(with: "庫存   |  ", content: String(stock))
        case 6:
            cell.configure(with: "材質   |  ", content: product.texture ?? "無資料")
        case 7:
            cell.configure(with: "洗滌   |  ", content: product.wash ?? "無資料")
        case 8:
            cell.configure(with: "產地   |  ", content: product.place ?? "無資料")
        case 9:
            cell.configure(with: "備註   |  ", content: product.note ?? "無資料")
        default:
            fatalError("Unexpected indexPath.row for DetailStyleCell")
        }
        
        return cell
    }
    
    private func configureCell(for indexPath: IndexPath) -> UITableViewCell {
        guard let product = product else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageViewCell", for: indexPath) as! ImageViewCell
            cell.configure(with: product)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailTitleViewCell.self), for: indexPath) as! DetailTitleViewCell
            cell.configure(with: product)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailStoryViewCell.self), for: indexPath) as! DetailStoryViewCell
            cell.configure(with: product)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: DetailColorCell.self), for: indexPath) as! DetailColorCell
            cell.configure(with: product)
            return cell
        case 4...9:
            return configureDetailStyleCell(for: indexPath, with: product)
        default:
            fatalError("Failed to instantiate the table view cell for detail view controller")
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddButtonSegue" {
            if let destinationVC = segue.destination as? CartButtonVC {
                destinationVC.product = product
                destinationVC.delegate = self
            }
        }
    }
    
    func didTapCloseButton() {
        addtoCartButton.isEnabled = true
        addtoCartButton.backgroundColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0)
        addtoCartButton.setTitleColor(.white, for: .normal)
        
        lightenImageView()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
        }) { _ in
            self.containerView.isHidden = true
        }
        
        isContainerViewVisible = false
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension DetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return configureCell(for: indexPath)
    }
}

// MARK: - UIScrollViewDelegate

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? ImageViewCell {
            cell.pageControl.currentPage = Int(page)
        }
    }
}
