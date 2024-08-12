//
//  CatalogViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/24.
//

import UIKit

class CatalogSwitchPageController: UIViewController {
    
    // MARK: - Button
    var selectedButton: UIButton?
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var underlineView: UIView!
    @IBOutlet weak var underlineCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var underlineViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var womenButton: UIButton!
    @IBOutlet weak var menButton: UIButton!
    @IBOutlet weak var accessoriesButton: UIButton!
    
    // MARK: - Pages
    
    var width: CGFloat?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet var containerViews: [UIView]!
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buttons = buttonStackView.subviews
        
        
        for (index, button) in buttons.enumerated() {
            let uibutton = button as! UIButton
            uibutton.tag = index
            uibutton.addTarget(self, action: #selector(changePage), for: .touchUpInside)
            
            if index == 0 {
                uibutton.setTitleColor(.blue, for: .normal)
                selectedButton = uibutton
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        width = view.bounds.width
    }
    
// MARK: - Change Page
    @objc func changePage(sender: UIButton) {
        
        selectedButton?.setTitleColor(.black, for: .normal)
        
        sender.setTitleColor(.blue, for: .normal)
        
        selectedButton = sender
        
        setButtonConstraint(button: sender)
        
        let targetX = CGFloat(sender.tag) * width!
        
        scrollView.setContentOffset(CGPoint(x: targetX, y: 0), animated: true)
        
        if womenButton == sender {
            womenButton.tintColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00)
            menButton.tintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
            accessoriesButton.tintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
        } else if menButton == sender {
            womenButton.tintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
            menButton.tintColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00)
            accessoriesButton.tintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
        } else {
            womenButton.tintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
            menButton.tintColor = UIColor(red: 0.53, green: 0.53, blue: 0.53, alpha: 1.00)
            accessoriesButton.tintColor = UIColor(red: 0.25, green: 0.23, blue: 0.23, alpha: 1.00)
        }
    }
//MARK: - Call the method after press the button
    func setButtonConstraint(button: UIButton){
        
        //先關閉
        underlineViewWidthConstraint.isActive = false
        underlineCenterXConstraint.isActive = false
        underlineViewTopConstraint.isActive = false
        //改值
        underlineViewWidthConstraint = underlineView.widthAnchor.constraint(equalTo: button.widthAnchor)
        underlineCenterXConstraint = underlineView.centerXAnchor.constraint(equalTo: button.centerXAnchor)
        underlineViewTopConstraint = underlineView.topAnchor.constraint(equalTo: button.bottomAnchor)
       
        underlineViewWidthConstraint.isActive = true
        underlineCenterXConstraint.isActive = true
        underlineViewTopConstraint.isActive = true
        UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.view.layoutIfNeeded()
        }.startAnimation()
    }
    
}

//MARK: - ScrollViewDelegate

extension CatalogSwitchPageController: UIScrollViewDelegate{
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        guard let width = width else { return }
        let currentPage = Int(targetContentOffset.pointee.x / width)
        let buttons = buttonStackView.subviews
        let uibutton = buttons[currentPage] as! UIButton
        
        selectedButton?.setTitleColor(.black, for: .normal)
        uibutton.setTitleColor(.blue, for: .normal)
        selectedButton = uibutton
        
        setButtonConstraint(button: uibutton)
        
    }
    
}

