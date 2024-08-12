//
//  CheckoutSuccessViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/8.
//

import UIKit
import CoreData

// MARK: - CheckoutSuccessViewController

class CheckoutSuccessViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction func backToHome(_ sender: UIButton) {
        self.dismiss(animated: true) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let tabBarController = window.rootViewController as? UITabBarController {
                
                tabBarController.selectedIndex = 0
                
                if let homePageVC = tabBarController.viewControllers?[0] as? HomePageViewController {
                    homePageVC.reloadDataOrRefreshUI()
                }
                
                if let cartVC = tabBarController.viewControllers?[2] as? CartShopViewController {
                    cartVC.loadCartItems()
                    cartVC.tableView.reloadData()
                }
            }
            self.clearCart()
        }
    }
    
    // MARK: - Helper Methods
    
    private func clearCart() {
        DispatchQueue.main.async {
            let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
            
            do {
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let cartItems = try context.fetch(fetchRequest)
                
                for item in cartItems {
                    context.delete(item)
                }
                
                try context.save()
                print("Cart cleared successfully.")
                
            } catch let error as NSError {
                print("Could not delete cart items. \(error), \(error.userInfo)")
            }
        }
    }
}
