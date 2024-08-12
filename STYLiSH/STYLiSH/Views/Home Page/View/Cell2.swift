//
//  Cell2.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/17.
//
import UIKit
import Kingfisher

// MARK: - Cell2

class Cell2: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var styleLabel: UILabel!
    @IBOutlet weak var fibreLabel: UILabel!
    @IBOutlet weak var typeImage: UIImageView!
    @IBOutlet weak var typeImage1: UIImageView!
    @IBOutlet weak var typeImage2: UIImageView!
    @IBOutlet weak var typeImage3: UIImageView!
    
    // MARK: - Configuration
    func configure(with product: Product) {
        nameLabel.text = product.title
        styleLabel.text = product.description
        fibreLabel.text = product.texture
        
        let imageViews = [typeImage, typeImage1, typeImage2, typeImage3]
        
        for (index, imageView) in imageViews.enumerated() {
            if index < product.images.count, let url = URL(string: product.images[index]) {
                imageView?.kf.setImage(with: url)
            } else {
                imageView?.image = UIImage(named: "Image_Placeholder")
            }
        }
    }
}
