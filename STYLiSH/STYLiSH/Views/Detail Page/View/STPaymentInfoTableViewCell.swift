//
//  STPaymentInfoTableViewCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/26.
//  Copyright © 2019 WU CHIH WEI. All rights reserved.
//

import UIKit
import TPDirect

private enum PaymentMethod: String {
    
    case creditCard = "信用卡付款"
    
    case cash = "貨到付款"
}

protocol STPaymentInfoTableViewCellDelegate: AnyObject {
    
    func didChangePaymentMethod(_ cell: STPaymentInfoTableViewCell, for paymentMethod: String)
    
    func didChangeUserData(
        _ cell: STPaymentInfoTableViewCell,
        payment: String,
        cardNumber: String,
        dueDate: String,
        verifyCode: String
    )
    
    func tpdFormDidUpdate(_ tpdForm: TPDForm, status: TPDStatus)
    
    func checkout(_ cell:STPaymentInfoTableViewCell)
}


class STPaymentInfoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var paymentTextField: UITextField! {
        
        didSet {
            
            
            let shipPicker = UIPickerView()
            
            shipPicker.dataSource = self
            
            shipPicker.delegate = self
            
            paymentTextField.inputView = shipPicker
            
            let button = UIButton(type: .custom)
            
            button.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            
            button.setBackgroundImage(
                UIImage.asset(.Icons_24px_DropDown),
                for: .normal
            )
            
            button.isUserInteractionEnabled = false
            
            paymentTextField.rightView = button
            
            paymentTextField.rightViewMode = .always
            
            paymentTextField.delegate = self
            
            paymentTextField.text = PaymentMethod.cash.rawValue
        }
    }
    
    @IBOutlet weak var cardNumberTextField: UITextField! {
        
        didSet {
            
            cardNumberTextField.delegate = self
        }
    }
    
    @IBOutlet weak var dueDateTextField: UITextField! {
        
        didSet {
            
            dueDateTextField.delegate = self
        }
    }
    
    @IBOutlet weak var verifyCodeTextField: UITextField! {
        
        didSet {
            
            verifyCodeTextField.delegate = self
        }
    }
    
    @IBOutlet weak var productPriceLabel: UILabel!
    
    @IBOutlet weak var shipPriceLabel: UILabel!
    
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var productAmountLabel: UILabel!
    
    @IBOutlet weak var topDistanceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var creditView: UIView! {
        
        didSet {
            
            creditView.isHidden = true
            let tpdFormView = UIView()
            tpdFormView.backgroundColor = .white
            tpdFormView.translatesAutoresizingMaskIntoConstraints = false
            creditView.addSubview(tpdFormView)
            NSLayoutConstraint.activate([
                tpdFormView.topAnchor.constraint(equalTo: creditView.topAnchor, constant: 40),
                tpdFormView.bottomAnchor.constraint(equalTo: creditView.bottomAnchor, constant: -10),
                tpdFormView.centerXAnchor.constraint(equalTo: creditView.centerXAnchor),
                tpdFormView.widthAnchor.constraint(equalToConstant: 330)
            ])
            
            tpdForm = TPDForm.setup(withContainer: tpdFormView)
            
            tpdForm.onFormUpdated { (status) in
                
                self.delegate?.tpdFormDidUpdate(self.tpdForm, status: status)
            }
        }
    }
    
    @IBOutlet weak var checkoutButton: UIButton!
    {
        didSet {
            checkoutButton.isEnabled = false
        }
    }
    
    private let paymentMethod: [PaymentMethod] = [.cash, .creditCard]
    
    weak var delegate: STPaymentInfoTableViewCellDelegate?
    
    var tpdForm: TPDForm!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
    func layoutCellWith(
        productPrice: Int,
        shipPrice: Int,
        productCount: Int
    ) {
        
        productPriceLabel.text = "NT$ \(productPrice)"
        
        shipPriceLabel.text = "NT$ \(shipPrice)"
        
        totalPriceLabel.text = "NT$ \(shipPrice + productPrice)"
        
        productAmountLabel.text = "總計 (\(productCount)樣商品)"
    }
    
    
    @IBAction func checkout() {
        
        delegate?.checkout(self)
    
    }
    
    
    func updateCheckoutButtonState(isEnabled: Bool) {
            checkoutButton.isEnabled = isEnabled
            checkoutButton.backgroundColor = isEnabled ? UIColor.hexStringToUIColor(hex: "3F3A3A") : UIColor.hexStringToUIColor(hex: "999999")
    }
}
extension STPaymentInfoTableViewCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(
        _ pickerView: UIPickerView,
        numberOfRowsInComponent component: Int
    ) -> Int
    {
        return 2
    }
    
    func pickerView(
        _ pickerView: UIPickerView,
        titleForRow row: Int,
        forComponent component: Int
    ) -> String?
    {
        
        return paymentMethod[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        paymentTextField.text = paymentMethod[row].rawValue
    }
    
    private func manipulateHeight(_ distance: CGFloat) {
        
        topDistanceConstraint.constant = distance
        
    }
}

extension STPaymentInfoTableViewCell: UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
//        if textField != paymentTextField {
//            
//            passData()
//            
//            return
//        }
        
        guard
            let text = textField.text,
            let payment = PaymentMethod(rawValue: text) else
        {
            
//            passData()
            
            return
        }
        
        switch payment {
            
        case .cash:
            
            manipulateHeight(44)
            
            creditView.isHidden = true
            
            delegate?.didChangePaymentMethod(self, for: "Cash")
            
            
        case .creditCard:
            
            manipulateHeight(228)
            
            creditView.isHidden = false
            
            delegate?.didChangePaymentMethod(self, for: "Credit Card")
            
        }
        
//        passData()
    }
    
//    private func passData() {
//        
//        guard
//            let cardNumber = cardNumberTextField.text,
//            let dueDate = dueDateTextField.text,
//            let verifyCode = verifyCodeTextField.text,
//            let paymentMethod = paymentTextField.text else
//        {
//            return
//        }
//        
//        delegate?.didChangeUserData(
//            self,
//            payment: paymentMethod,
//            cardNumber: cardNumber,
//            dueDate: dueDate,
//            verifyCode: verifyCode
//        )
//    }
}
