//
//  UISizeCell.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/30.
//
import UIKit

// MARK: - Protocols

protocol UISizeCellDelegate: AnyObject {
    func sizeCell(_ cell: UISizeCell, didSelectSize size: String)
}

// MARK: - UISizeCell

class UISizeCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var buttonXS: UIButton!
    @IBOutlet weak var buttonS: UIButton!
    @IBOutlet weak var buttonM: UIButton!
    @IBOutlet weak var buttonL: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    
    // MARK: - Properties
    
    private var selectedButton: UIButton?
    private var borderView: UIView?
    weak var delegate: UISizeCellDelegate?
    private var availableSizes: [String: Int] = [:]
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configureButton(buttonXS)
        configureButton(buttonS)
        configureButton(buttonM)
        configureButton(buttonL)
        configureButton(buttonF)
        disableAllButtons()
    }
    
    // MARK: - Configuration
    
    func configure(with availableSizes: [String: Int]) {
        self.availableSizes = availableSizes
        disableAllButtons()
        
        if availableSizes.isEmpty { return }
        
        var firstAvailableSizeButton: UIButton?
        
        if Set(availableSizes.keys) == Set(["F"]) {
            buttonF.isHidden = false
            updateButtonState(buttonF, size: "F")
            if let stock = availableSizes["F"], stock > 0 {
                firstAvailableSizeButton = buttonF
            }
        } else {
            [("XS", buttonXS), ("S", buttonS), ("M", buttonM), ("L", buttonL)].forEach { (size, button) in
                if let stock = availableSizes[size], stock > 0 {
                    updateButtonState(button, size: size)
                    if firstAvailableSizeButton == nil {
                        firstAvailableSizeButton = button
                    }
                }
            }
        }
        
        if let buttonToSelect = firstAvailableSizeButton {
            sizeButtonTapped(buttonToSelect)
        }
    }
    
    func resetSelection() {
        if let selectedButton = selectedButton {
            selectedButton.transform = .identity
            borderView?.removeFromSuperview()
        }
        selectedButton = nil
        borderView = nil
    }
    
    // MARK: - Helpers
    
    private func configureButton(_ button: UIButton) {
        button.layer.borderWidth = 0
        button.addTarget(self, action: #selector(sizeButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func updateButtonState(_ button: UIButton, size: String) {
        if let stock = availableSizes[size], stock > 0 {
            button.isEnabled = true
            button.isHidden = false
            button.setTitleColor(.lightGray, for: .normal)
            button.layer.borderColor = UIColor.black.cgColor
        } else {
            button.isEnabled = false
            button.isHidden = true
            button.setTitleColor(.lightGray, for: .normal)
            button.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @objc private func sizeButtonTapped(_ sender: UIButton) {
        if let selectedButton = selectedButton {
            selectedButton.transform = .identity
            borderView?.removeFromSuperview()
        }
        
        let borderView = UIView()
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.borderWidth = 1
        borderView.isUserInteractionEnabled = false
        contentView.addSubview(borderView)
        borderView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: sender.leadingAnchor),
            borderView.trailingAnchor.constraint(equalTo: sender.trailingAnchor),
            borderView.topAnchor.constraint(equalTo: sender.topAnchor),
            borderView.bottomAnchor.constraint(equalTo: sender.bottomAnchor)
        ])
        
        self.selectedButton = sender
        self.borderView = borderView
        
        UIView.animate(withDuration: 0.3) {
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        if let size = sender.titleLabel?.text {
            delegate?.sizeCell(self, didSelectSize: size)
        }
    }
    
    func disableAllButtons() {
        let buttons = [buttonXS, buttonS, buttonM, buttonL, buttonF]
        buttons.forEach { button in
            button?.isEnabled = false
            button?.setTitleColor(.lightGray, for: .normal)
            button?.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}
