//
//  STOrderProductCell.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/7/25.
//  Copyright © 2019 WU CHIH WEI. All rights reserved.
//

import UIKit
import SDWebImage

var cartItem: CartItem?

class STOrderProductCell: UITableViewCell {

    @IBOutlet weak var productImageView: UIImageView!
    
    @IBOutlet weak var productTitleLabel: UILabel!
    
    @IBOutlet weak var colorView: UIView!
    
    @IBOutlet weak var productSizeLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var orderNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    func configure(with item: CartItem) {
//        let quantity = Int(item.quantity ?? "1") ?? 1
        productTitleLabel.text = item.productName
        productSizeLabel.text = item.size
        priceLabel.text = "NT$ \(item.price ?? "0")"
//        quantityTextField.text = "\(String(describing: item.quantity))"
        orderNumberLabel.text = "\(item.quantity ?? "0")"
        orderNumberLabel.textAlignment = .center

        if let colorHex = item.color {
            colorView.backgroundColor = UIColor(hex: colorHex)
        } else {
            colorView.backgroundColor = .clear
        }

        colorView.layer.borderColor = UIColor.lightGray.cgColor
        colorView.layer.borderWidth = 0.5


        if let imageUrlString = item.image, let imageUrl = URL(string: imageUrlString) {
            productImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "Image_Placeholder"))
            print("Loading Image from URL: \(imageUrl)")
        } else {
            print("Invalid Image URL or no URL provided")
            productImageView.image = UIImage(named: "Image_Placeholder")
        }
    }
}
