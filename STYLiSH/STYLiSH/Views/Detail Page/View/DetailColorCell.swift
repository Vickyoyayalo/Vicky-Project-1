//
//  DetailColorCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/29.
//
import UIKit

// MARK: - DetailColorCell

class DetailColorCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorView2: UIView!
    @IBOutlet weak var colorView3: UIView!
    @IBOutlet weak var colorView4: UIView!
    
    // MARK: - Configuration
    
    func configure(with product: Product) {
        colorLabel.text = "顏色   |  "
        
        let colorViews = [colorView2, colorView3, colorView4]
        
        if let colors = product.colors {
            for (index, color) in colors.prefix(3).enumerated() {
                if let uiColor = UIColor(hex: color.code) {
                    colorViews[index]?.backgroundColor = uiColor
                    colorViews[index]?.layer.borderColor = UIColor.black.cgColor
                    colorViews[index]?.layer.borderWidth = 0.5
                }
            }
        }
    }
}
