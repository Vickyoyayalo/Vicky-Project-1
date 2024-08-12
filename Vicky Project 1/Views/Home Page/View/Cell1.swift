//
//  Cell1.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/17.
//
import UIKit
import Kingfisher

import UIKit
import Kingfisher

// MARK: - Cell1

class Cell1: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var fibreLabel: UILabel!
    
    // MARK: - Configuration
    
    func configure(with product: Product) {
        nameLabel.text = product.title
        styleLabel.text = product.description
        fibreLabel.text = product.texture
        
        if let url = URL(string: product.mainImage) {
            typeImageView.kf.setImage(with: url)
        }
    }
}
