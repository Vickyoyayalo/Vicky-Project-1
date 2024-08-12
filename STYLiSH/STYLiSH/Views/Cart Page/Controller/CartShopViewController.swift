//
//  CartViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/2.
//
import CoreData
import UIKit
import StatusAlert

class CartShopViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var checkoutButton: UIButton!
    @IBOutlet weak var emptyCartLabel: UILabel! {
        didSet {
            emptyCartLabel.textColor = .lightGray
        }
    }
    
    // MARK: - Properties
    
    var cartItems: [CartItem] = []
    var fetchedResultsController: NSFetchedResultsController<CartItem>!
    var managedContext: NSManagedObjectContext {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCartItems()
        updateEmptyCartLabel()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initializeFetchedResultsController()
        loadCartItems()
        setupLogoutButton()
        updateCheckoutButtonState()
        NotificationCenter.default.addObserver(self, selector: #selector(loadCartItems), name: .cartUpdated, object: nil)
        updateCartBadge()
    }
    
    // MARK: - Actions
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.removeObject(forKey: "STYLiSHToken")
        UserDefaults.standard.removeObject(forKey: "UserName")
        UserDefaults.standard.removeObject(forKey: "UserProfilePicture")
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.synchronize()
        
        showLogoutSuccessAlert()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 0
            }
        }
    }
    
    // MARK: - Helpers
    
    func setupLogoutButton() {
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
        logoutButton.layer.borderWidth = 1
        logoutButton.backgroundColor = .clear
        logoutButton.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    func showLogoutSuccessAlert() {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Success01")
        statusAlert.title = "登出成功"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.sizesAndDistances.alertWidth = 175
        statusAlert.sizesAndDistances.minimumAlertHeight = 175
        statusAlert.appearance.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        statusAlert.appearance.tintColor = .white
        statusAlert.showInKeyWindow()
    }
    
    @objc func loadCartItems() {
        cartItems = StorageManager.shared.fetchCartItems().filter { Int($0.quantity ?? "0") ?? 0 > 0 }
        tableView.reloadData()
        updateCartBadge()
        updateEmptyCartLabel()
        updateCheckoutButtonState()
    }
    
    func updateEmptyCartLabel() {
        let isCartEmpty = cartItems.isEmpty
        emptyCartLabel.isHidden = !isCartEmpty
        tableView.isHidden = isCartEmpty
        view.layoutIfNeeded()
    }
    
    func updateCheckoutButtonState() {
        checkoutButton.isEnabled = !cartItems.isEmpty
        checkoutButton.backgroundColor = cartItems.isEmpty ?
        UIColor.hexStringToUIColor(hex: "999999") : UIColor.hexStringToUIColor(hex: "3F3A3A")
    }

    func clearCartData() {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        do {
            let cartItems = try managedContext.fetch(fetchRequest)
            for item in cartItems {
                managedContext.delete(item)
            }
            try managedContext.save()
            
            DispatchQueue.main.async {
                if let tabBarController = self.tabBarController, let cartTabBarItem = tabBarController.tabBar.items?[2] {
                    cartTabBarItem.badgeValue = nil
                }
            }
        } catch let error as NSError {
            print("Could not clear cart. \(error), \(error.userInfo)")
        }
    }
    
    func updateCartBadge() {
        let totalQuantity = fetchedResultsController.fetchedObjects?.reduce(0) { $0 + (Int($1.quantity ?? "0") ?? 0) } ?? 0
        if let tabBarController = tabBarController {
            let cartTabBarItem = tabBarController.tabBar.items?[2]
            cartTabBarItem?.badgeValue = totalQuantity > 0 ? "\(totalQuantity)" : nil
        }
    }
    
    func initializeFetchedResultsController() {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "productName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Fetch request failed: \(error)")
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CartShopViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartShopCell", for: indexPath) as! CartShopCell
        let item = fetchedResultsController.object(at: indexPath)
        cell.configure(with: item)
        
        cell.increaseQuantity = { [weak self] in
            guard let self = self else { return }
            guard let currentQuantity = Int(item.quantity ?? "0"), currentQuantity < 99 else { return }
            
            item.quantity = "\(currentQuantity + 1)"
            StorageManager.shared.saveContext()
            self.updateCartBadge()
        }

        cell.decreaseQuantity = { [weak self] in
            guard let self = self else { return }
            guard let currentQuantity = Int(item.quantity ?? "0"), currentQuantity > 1 else { return }
            
            item.quantity = "\(currentQuantity - 1)"
            StorageManager.shared.saveContext()
            self.updateCartBadge()
        }
        
        cell.removeItem = { [weak self] in
            guard let self = self else { return }
            StorageManager.shared.deleteCartItem(cartItem: item)
            self.updateCartBadge()
        }
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension CartShopViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        case .move:
            if let oldIndexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.moveRow(at: oldIndexPath, to: newIndexPath)
            }
        @unknown default:
            fatalError("Unknown case in NSFetchedResultsChangeType")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updateCartBadge()
        tableView.endUpdates()
    }
}
