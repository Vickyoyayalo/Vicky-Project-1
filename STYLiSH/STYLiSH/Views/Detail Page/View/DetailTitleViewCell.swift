//
//  DetailStoryViewCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/29.
//
import UIKit

// MARK: - DetailTitleViewCell

class DetailTitleViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var titleLabel: UILabel! {
        didSet {
            titleLabel.text = titleLabel.text?.uppercased()
            titleLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var serieLabel: UILabel! {
        didSet {
            serieLabel.numberOfLines = 0
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel! {
        didSet {
            priceLabel.text = priceLabel.text?.uppercased()
            priceLabel.numberOfLines = 0
        }
    }

    // MARK: - Configuration
    
    func configure(with product: Product) {
        titleLabel.text = product.title
        serieLabel.text = String(product.id)
        priceLabel.text = "NT$ \(product.price)"
    }
    
    // MARK: - Selection Handling
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
