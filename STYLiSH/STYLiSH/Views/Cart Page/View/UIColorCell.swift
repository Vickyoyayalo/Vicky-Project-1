//
//  UIColorCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/30.
//
import UIKit

//MARK: - Protocal
protocol UIColorCellDelegate: AnyObject {
    func colorCell(_ cell: UIColorCell, didSelectColor color: UIColor, withColorCode colorCode: String)
}

class UIColorCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var colorTitleLabel: UILabel!
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    // MARK: - Properties
    
    private var selectedImageView: UIImageView?
    private var borderView: UIView?
    weak var delegate: UIColorCellDelegate?
    private var colors: [Color] = []
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureImageView(imageView0)
        configureImageView(imageView1)
        configureImageView(imageView2)
    }
    
    // MARK: - Configuration
    
    func configure(with product: Product) {
        colorTitleLabel.text = "選擇顏色"
        let imageViews = [imageView0, imageView1, imageView2]
        
        if let colors = product.colors {
            self.colors = colors
            
            for (index, color) in colors.prefix(3).enumerated() {
                if let uiColor = UIColor(hex: color.code) {
                    let imageView = imageViews[index]
                    imageView?.backgroundColor = uiColor
                    imageView?.layer.borderColor = UIColor.clear.cgColor
                    imageView?.layer.borderWidth = 0.5
                    imageView?.transform = .identity
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func configureImageView(_ imageView: UIImageView) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.layer.borderWidth = 0.5
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped(_:)))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageViewTapped(_ sender: UITapGestureRecognizer) {
        guard let tappedImageView = sender.view as? UIImageView,
              let index = [imageView0, imageView1, imageView2].firstIndex(of: tappedImageView),
              index < colors.count else { return }
        
        let selectedColor = colors[index]
        
        if let uiColor = UIColor(hex: selectedColor.code) {
            delegate?.colorCell(self, didSelectColor: uiColor, withColorCode: selectedColor.code)
        }
        
        if let selectedImageView = selectedImageView {
            selectedImageView.transform = CGAffineTransform.identity
            borderView?.removeFromSuperview()
        }
        
        let borderView = UIView()
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.borderWidth = 1
        borderView.isUserInteractionEnabled = false
        contentView.addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: tappedImageView.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: tappedImageView.trailingAnchor),
            borderView.topAnchor.constraint(equalTo: tappedImageView.topAnchor),
            borderView.bottomAnchor.constraint(equalTo: tappedImageView.bottomAnchor)
        ])
        
        self.selectedImageView = tappedImageView
        self.borderView = borderView
        
        UIView.animate(withDuration: 0.3) {
            tappedImageView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
}
