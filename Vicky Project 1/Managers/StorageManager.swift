//
//  StorageManager.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/2.
//
import Foundation
import CoreData
import UIKit

// MARK: - StorageManager

class StorageManager {
    static let shared = StorageManager()

    private var context: NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private init() {}

    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Cart Item Management

    func addCartItem(productName: String, price: String, quantity: Int, color: String, size: String, image: String, stock: Int) {
        let cartItem = CartItem(context: context)
        cartItem.productName = productName
        cartItem.price = price
        cartItem.quantity = String(quantity)
        cartItem.color = color
        cartItem.size = size
        cartItem.image = image
        cartItem.stock = Int32(stock)
        saveContext()

        NotificationCenter.default.post(name: .cartUpdated, object: nil)
    }

    func fetchCartItems() -> [CartItem] {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        do {
            let cartItems = try context.fetch(fetchRequest)
                    print("Fetched \(cartItems.count) items from Core Data.")
                    for item in cartItems {
                        print("Fetched item: \(item.productName ?? "N/A"), Quantity: \(item.quantity ?? "0")")
                    }
            return cartItems
        } catch {
            print("Failed to fetch Cart Items: \(error)")
            return []
        }
    }


    func deleteCartItem(cartItem: CartItem) {
        context.delete(cartItem)
           do {
               try context.save()
           } catch {
               print("Failed to delete item: \(error)")
           }
           NotificationCenter.default.post(name: .cartUpdated, object: nil)
    }
    
   
    func deleteInvalidCartItems() {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        
        do {
            let invalidItems = try context.fetch(fetchRequest)
            for item in invalidItems {
                context.delete(item)
            }
            try context.save()
            print("Deleted \(invalidItems.count) invalid items from Core Data.")
        } catch {
            print("Failed to delete invalid items: \(error)")
        }
    }
}

// MARK: - Notification Name Extension

extension Notification.Name {
    static let cartUpdated = Notification.Name("cartUpdated")
}
