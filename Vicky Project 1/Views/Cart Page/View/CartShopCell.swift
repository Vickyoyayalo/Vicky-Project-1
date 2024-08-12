//
//  CartShopCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/2.
//

import UIKit
import SDWebImage

// MARK: - CartShopCell

class CartShopCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var decreaseButton: UIButton!
    @IBOutlet weak var increaseButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var addCartButton: UIButton!
    
    // MARK: - Properties
    
    var increaseQuantity: (() -> Void)?
    var decreaseQuantity: (() -> Void)?
    var removeItem: (() -> Void)?
    
    // MARK: - Actions
    
    @IBAction func increaseTapped(_ sender: UIButton) {
        increaseQuantity?()
    }
    
    @IBAction func decreaseTapped(_ sender: UIButton) {
        decreaseQuantity?()
    }
    
    @IBAction func removeTapped(_ sender: UIButton) {
        removeItem?()
    }

    // MARK: - Configuration
    
    func configure(with item: CartItem) {
        let quantity = Int(item.quantity ?? "1") ?? 1
        nameLabel.text = item.productName
        sizeLabel.text = item.size
        priceLabel.text = "NT$ \(item.price ?? "0")"
        quantityTextField.text = "\(item.quantity ?? "0")"
        quantityTextField.textAlignment = .center
        quantityTextField.contentVerticalAlignment = .center

        if let colorHex = item.color {
            colorImageView.backgroundColor = UIColor(hex: colorHex)
        } else {
            colorImageView.backgroundColor = .clear
        }

        colorImageView.layer.borderColor = UIColor.lightGray.cgColor
        colorImageView.layer.borderWidth = 0.5

        updateButtonStates(quantity: quantity, stock: item.stock)

        if let imageUrlString = item.image, let imageUrl = URL(string: imageUrlString) {
            productImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "Image_Placeholder"))
            print("Loading Image from URL: \(imageUrl)")
        } else {
            print("Invalid Image URL or no URL provided")
            productImageView.image = UIImage(named: "Image_Placeholder")
        }
    }

    // MARK: - Helpers
    
    private func updateButtonStates(quantity: Int, stock: Int32) {
        let isDecreaseEnabled = quantity > 1
        decreaseButton.isEnabled = isDecreaseEnabled
        decreaseButton.layer.borderColor = isDecreaseEnabled ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        
        let decreaseButtonImage = isDecreaseEnabled ? UIImage(named: "Subtract01") : UIImage(named: "Subtract01")?.withRenderingMode(.alwaysTemplate)
        decreaseButton.setImage(decreaseButtonImage, for: .normal)
        decreaseButton.tintColor = isDecreaseEnabled ? .black : .lightGray
        
        let isIncreaseEnabled = quantity < stock
        increaseButton.isEnabled = isIncreaseEnabled
        increaseButton.layer.borderColor = isIncreaseEnabled ? UIColor.black.cgColor : UIColor.lightGray.cgColor
        
        let increaseButtonImage = isIncreaseEnabled ? UIImage(named: "Add01") : UIImage(named: "Add01")?.withRenderingMode(.alwaysTemplate)
        increaseButton.setImage(increaseButtonImage, for: .normal)
        increaseButton.tintColor = isIncreaseEnabled ? .black : .lightGray
        
        let isActive = quantity > 0 && quantity <= stock
        quantityTextField.layer.borderColor = isActive ? UIColor.black.cgColor : UIColor.lightGray.cgColor
    }

    // MARK: - Initialization
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        quantityTextField.textAlignment = .center
        quantityTextField.layer.borderWidth = 1.0
        
        configureButton(decreaseButton)
        configureButton(increaseButton)
    }

    private func configureButton(_ button: UIButton) {
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.lightGray.cgColor
    }
}
