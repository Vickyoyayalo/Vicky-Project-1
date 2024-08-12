//
//  DetailStoryViewCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/29.
//
import UIKit

// MARK: - DetailStoryViewCell

class DetailStoryViewCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var storyLabel: UILabel! {
        didSet {
            storyLabel.numberOfLines = 0
        }
    }
    
    // MARK: - Configuration
    
    func configure(with product: Product) {
        storyLabel.text = product.story
    }
    
    // MARK: - Selection Handling
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
