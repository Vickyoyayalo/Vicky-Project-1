//
//  UIidCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/30.
//

import UIKit

// MARK: - UIidCell

class UIidCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.text = titleLabel.text?.uppercased()
            titleLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet var priceLabel: UILabel! {
        didSet {
            priceLabel.text = priceLabel.text?.uppercased()
            priceLabel.numberOfLines = 0
        }
    }
    
    // MARK: - Configuration
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        priceLabel.text = "NT$ \(product.price)"
    }
    
    // MARK: - Selection Handling
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
