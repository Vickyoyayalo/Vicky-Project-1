//
//  UIQtyCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/30.
//

import UIKit
import IQKeyboardManagerSwift

// MARK: - Protocols

protocol UIQtyCellDelegate: AnyObject {
    func didStartEditingQuantity()
}

// MARK: - UIQtyCell

class UIQtyCell: UITableViewCell, UITextFieldDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var qtyLabel: UILabel!
    @IBOutlet weak var noButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var stockNumText: UITextField!
    @IBOutlet weak var stockqtyLabel: UILabel!
    
    // MARK: - Properties
    
    var onQuantityChanged: ((Int) -> Void)?
    weak var delegate: UIQtyCellDelegate?
    var stock: Int = 0
    var quantity: Int = 1 {
        didSet {
            stockNumText.text = "\(quantity)"
            stockqtyLabel.text = "庫存數量：\(stock)"
            updateButtonStates()
            delegate?.didStartEditingQuantity()
            onQuantityChanged?(quantity)
        }
    }
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        qtyLabel.text = "選擇數量"
        stockqtyLabel.textAlignment = .left
        
        stockNumText.addTarget(self, action: #selector(textFieldDidBeginEditing(_:)), for: .editingDidBegin)
        
        configureButton(noButton)
        configureButton(addButton)
        
        disableButtons()
        
        noButton.addTarget(self, action: #selector(decreaseQuantity), for: .touchUpInside)
        addButton.addTarget(self, action: #selector(increaseQuantity), for: .touchUpInside)
        
        noButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        noButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        addButton.addTarget(self, action: #selector(buttonTouchDown(_:)), for: .touchDown)
        addButton.addTarget(self, action: #selector(buttonTouchUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Configuration
    
    func configure(with stock: Int) {
        self.stock = stock
        quantity = stock > 0 ? 1 : 0
        updateButtonStates()
    }
    
    private func configureButton(_ button: UIButton) {
        button.layer.borderColor = UIColor(red: 63/255, green: 58/255, blue: 58/255, alpha: 1.0).cgColor
        button.layer.borderWidth = 1
        button.setTitleColor(.black, for: .normal)
    }
    
    func configureTextField(_ textField: UITextField, isActive: Bool = false) {
        textField.layer.borderWidth = 1
        textField.textAlignment = .center
        textField.textColor = .black
        textField.keyboardType = .numberPad
        textField.borderStyle = .none
        textField.delegate = self
        
        textField.layer.borderColor = isActive ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        textField.alpha = isActive ? 1.0 : 0.3
    }
    
    // MARK: - UITextFieldDelegate
    
    @objc internal func textFieldDidBeginEditing(_ textField: UITextField) {
           delegate?.didStartEditingQuantity()
       }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text, let number = Int(text) {
            if number > stock {
                textField.text = "\(stock)"
            } else if number < 1 {
                textField.text = "1"
            }
        } else {
            textField.text = "1"
        }
        quantity = Int(textField.text!) ?? 1
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        if let prospectiveNumber = Int(prospectiveText), prospectiveNumber > 0 {
            return prospectiveNumber <= stock
        }
        
        return prospectiveText.isEmpty
    }
    
    // MARK: - Helpers
    
    private func disableButtons() {
        let buttons = [noButton, addButton]
        buttons.forEach { button in
            button?.isEnabled = false
            button?.setTitleColor(.lightGray, for: .normal)
            button?.layer.borderColor = UIColor.lightGray.cgColor
            
            let buttonImage = UIImage(named: button == noButton ? "Subtract01" : "Add01")?.withRenderingMode(.alwaysTemplate)
            button?.setImage(buttonImage, for: .normal)
            button?.tintColor = .lightGray
        }
        
        configureTextField(stockNumText, isActive: false)
    }
    
    private func updateButtonStates() {
        noButton.isEnabled = quantity > 1
        noButton.layer.borderColor = noButton.isEnabled ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        let noButtonImage = noButton.isEnabled ? UIImage(named: "Subtract01") : UIImage(named: "Subtract01")?.withRenderingMode(.alwaysTemplate)
        noButton.setImage(noButtonImage, for: .normal)
        noButton.tintColor = noButton.isEnabled ? .black : .lightGray
        
        addButton.isEnabled = quantity < stock
        addButton.layer.borderColor = addButton.isEnabled ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        let addButtonImage = addButton.isEnabled ? UIImage(named: "Add01") : UIImage(named: "Add01")?.withRenderingMode(.alwaysTemplate)
        addButton.setImage(addButtonImage, for: .normal)
        addButton.tintColor = addButton.isEnabled ? .black : .lightGray
        
        stockNumText.layer.borderColor = quantity > 0 && quantity <= stock ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        stockNumText.alpha = quantity > 0 && quantity <= stock ? 1.0 : 0.3
    }
    
    @objc private func decreaseQuantity() {
        if quantity > 1 {
            quantity -= 1
        }
    }
    
    @objc private func increaseQuantity() {
        if quantity < stock {
            quantity += 1
        }
    }
    
    @objc private func buttonTouchDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func buttonTouchUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.1) {
            sender.transform = CGAffineTransform.identity
        }
    }
}
