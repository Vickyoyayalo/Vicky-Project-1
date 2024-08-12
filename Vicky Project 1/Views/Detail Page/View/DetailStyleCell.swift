//
//  DetailStyleCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/29.
//

import UIKit

// MARK: - DetailStyleCell

class DetailStyleCell: UITableViewCell {

    // MARK: - Outlets
    
    @IBOutlet weak var styleContent: UILabel!
    @IBOutlet weak var styleLabel: UILabel!

    // MARK: - Configuration
    
    func configure(with label: String, content: String) {
        styleLabel.text = label
        styleContent.text = content
    }
    
    // MARK: - Selection Handling
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
