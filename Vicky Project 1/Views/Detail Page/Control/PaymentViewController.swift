//
//  PaymentViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/31.
//
import UIKit
import CoreData
import TPDirect

// MARK: - PaymentViewController

class PaymentViewController: UIViewController, STOrderUserInputCellDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    let header = ["結帳商品", "收件資訊", "付款詳情"]
    var boughtProducts: [CartItem] = []
    var tpdForm: TPDForm!
    var tpdCard: TPDCard!
    var tpdStatus: TPDStatus?
    var userInfoComplete = false
    var managedContext: NSManagedObjectContext! = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    var paymentMethod: String = "Cash"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        managedContext = appDelegate.persistentContainer.viewContext
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderProductCell.self), bundle: nil)
        tableView.lk_registerCellWithNib(identifier: String(describing: STOrderUserInputCell.self), bundle: nil)
        tableView.lk_registerCellWithNib(identifier: String(describing: STPaymentInfoTableViewCell.self), bundle: nil)
        
        let headerXib = UINib(nibName: String(describing: STOrderHeaderView.self), bundle: nil)
        tableView.register(headerXib, forHeaderFooterViewReuseIdentifier: String(describing: STOrderHeaderView.self))
        
        let backButton = UIButton(type: .custom)
        backButton.setImage(UIImage(named: "Back02"), for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = backBarButtonItem
    }
    
    // MARK: - Actions
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - User Data Handling
    
    func didChangeUserData(
        _ cell: STOrderUserInputCell,
        username: String,
        email: String,
        phoneNumber: String,
        address: String,
        shipTime: String
    ) {
        userInfoComplete = !username.isEmpty && !email.isEmpty && !phoneNumber.isEmpty && !address.isEmpty
        updateCheckoutButtonStatusInCell()
        
        print("Valid user data received:")
        print("Name: \(username), Email: \(email), Phone: \(phoneNumber), Address: \(address), Ship Time: \(shipTime)")
    }
    
    // MARK: - Core Data Fetching
    
    func fetchCartItems() -> [CartItem] {
        let fetchRequest: NSFetchRequest<CartItem> = CartItem.fetchRequest()
        do {
            let cartItems = try managedContext.fetch(fetchRequest)
            return cartItems
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return []
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension PaymentViewController: UITableViewDataSource, UITableViewDelegate {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 67.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: STOrderHeaderView.self)) as? STOrderHeaderView else {
            return nil
        }
        headerView.titleLabel.text = header[section]
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return ""
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let footerView = view as? UITableViewHeaderFooterView else { return }
        footerView.contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "cccccc")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return header.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? fetchCartItems().count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            guard let productCell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderProductCell.self), for: indexPath) as? STOrderProductCell else {
                return UITableViewCell()
            }
            
            let cartItems = fetchCartItems()
            if indexPath.row < cartItems.count {
                productCell.configure(with: cartItems[indexPath.row])
            }
            
            return productCell
            
        } else if indexPath.section == 1 {
            guard let inputCell = tableView.dequeueReusableCell(withIdentifier: String(describing: STOrderUserInputCell.self), for: indexPath) as? STOrderUserInputCell else {
                return UITableViewCell()
            }
            inputCell.delegate = self
            return inputCell
            
        } else {
            guard let paymentCell = tableView.dequeueReusableCell(withIdentifier: String(describing: STPaymentInfoTableViewCell.self), for: indexPath) as? STPaymentInfoTableViewCell else {
                return UITableViewCell()
            }
            paymentCell.delegate = self
            paymentCell.updateCheckoutButtonState(isEnabled: false)
            return paymentCell
        }
    }
}

// MARK: - STPaymentInfoTableViewCellDelegate

extension PaymentViewController: STPaymentInfoTableViewCellDelegate {
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, for paymentMethod: String) {
        self.paymentMethod = paymentMethod
        updateCheckoutButtonStatusInCell()
    }
    
    func tpdFormDidUpdate(_ tpdForm: TPDForm, status: TPDStatus) {
        self.tpdForm = tpdForm
        self.tpdStatus = status
        updateCheckoutButtonStatusInCell()
    }
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    ){
        print(payment, cardNumber, dueDate, verifyCode)
    }
    
    // MARK: - Checkout Handling
    
    func updateCheckoutButtonStatusInCell() {
        if let paymentCell = tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as? STPaymentInfoTableViewCell {
            
            if userInfoComplete && paymentMethod == "Cash" {
                paymentCell.updateCheckoutButtonState(isEnabled: true)
                
            } else if userInfoComplete && paymentMethod == "Credit Card" {
                if let tpdStatus = tpdStatus, tpdStatus.isCanGetPrime() {
                    paymentCell.updateCheckoutButtonState(isEnabled: true)
                } else {
                    paymentCell.updateCheckoutButtonState(isEnabled: false)
                }
            } else {
                paymentCell.updateCheckoutButtonState(isEnabled: false)
            }
        }
    }
    
    func checkout(_ cell: STPaymentInfoTableViewCell) {
        if let tpdForm = tpdForm {
            tpdCard = TPDCard.setup(tpdForm)
            
            tpdCard.onSuccessCallback { (prime, cardInfo, cardIdentifier, additionalData) in
                print("Prime : \(prime!), cardInfo : \(cardInfo!), cardIdentifier : \(cardIdentifier!)")
                
                self.callCheckoutAPI(with: prime!) { success in
                    if success {
                        self.clearCart()
                        self.navigateToCheckoutSuccessPage()
                    } else {
                        print("Checkout failed.")
                    }
                }
                
            }.onFailureCallback { (status, message) in
                print("status : \(status), Message : \(message)")
            }.getPrime()
        } else {
            callCheckoutAPI(with: nil) { success in
                if success {
                    self.clearCart()
                    self.navigateToCheckoutSuccessPage()
                } else {
                    print("Checkout failed.")
                }
            }
        }
    }
    
    // MARK: - API Calls
    
    func callCheckoutAPI(with prime: String?, completion: @escaping (Bool) -> Void) {
        let url = URL(string: "https://your-server.com/api/checkout")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = [
            "prime": prime ?? "",
            "amount": 8530,  // 假設的訂單金額
            "currency": "TWD",
            "details": "訂單細節",
            "shipping_info": ["name": "Vicky", "phone": "0912345678"],
            "payment_method": paymentMethod
        ] as [String : Any]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Checkout API error: \(error)")
                completion(false)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Checkout API failed with response: \(String(describing: response))")
                completion(false)
                return
            }
            
            completion(true)
        }
        
        task.resume()
    }
    
    // MARK: - Cart Management
    
    func clearCart() {
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
                
                if let tabBarController = self.tabBarController,
                   let cartTabBarItem = tabBarController.tabBar.items?[2] {
                    cartTabBarItem.badgeValue = nil
                }
                
            } catch let error as NSError {
                print("Could not delete cart items. \(error), \(error.userInfo)")
            }
        }
    }
    
    // MARK: - Navigation
    
    func navigateToCheckoutSuccessPage() {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let checkoutSuccessVC = storyboard.instantiateViewController(withIdentifier: "CheckoutSuccessViewController") as? CheckoutSuccessViewController {
                checkoutSuccessVC.modalPresentationStyle = .fullScreen
                self.present(checkoutSuccessVC, animated: true, completion: nil)
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
}




  //TODO
//    
//    func callCheckoutAPI(with prime: String?, completion: @escaping (Bool) -> Void) {
//        // 这里模拟了一个 API 请求，可以将它替换为你项目中的实际网络请求逻辑
//        let url = URL(string: "https://api.appworks-school.tw/api/1.0/order/checkout")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        let body = [
//            "prime": prime ?? "",
//            "amount": 8530,  // 假设的订单金额
//            "currency": "TWD",
//            "details": "订单细节",
//            "shipping_info": ["name": "Vicky", "phone": "0912345678"],
//            "payment_method": paymentMethod
//        ] as [String : Any]
//        
//        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        // 模拟一个网络请求
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Checkout API error: \(error)")
//                completion(false)
//                return
//            }
//            
//            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
//                print("Checkout API failed with response: \(String(describing: response))")
//                completion(false)
//                return
//            }
//            
//            // 处理响应数据
//            // 根据服务器返回的响应内容确定订单是否成功
//            completion(true)
//        }
//        
//        task.resume()
//    }
