//
//  OrderCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/24.
//
import UIKit
class OrderCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with data: CellData) {
        titleLabel.text = data.title
        imageView.image = UIImage(named: data.imageName)
    }
}
