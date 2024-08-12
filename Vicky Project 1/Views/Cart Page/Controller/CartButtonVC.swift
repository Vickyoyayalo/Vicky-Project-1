//
//  CartButtonVC.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/30.
//
import UIKit
import IQKeyboardManagerSwift

// MARK: - Protocols

protocol CartButtonDelegate: AnyObject {
    func didTapCloseButton()
    func didEnableAddToCartButton(_ enabled: Bool)
    func didUpdateSelection(colorCode: String?, size: String?)
    func didSelectedQuantityChange(quantity: Int)
}

// MARK: - CartButtonVC

class CartButtonVC: UITableViewController, UIColorCellDelegate, UISizeCellDelegate {

    // MARK: - Properties
    var selectedQuantity: Int = 1 {
        didSet {
            delegate?.didSelectedQuantityChange(quantity: selectedQuantity)
        }
    }
    var product: Product?
    var selectedColorCode: String?
    var selectedSize: String?
    weak var delegate: CartButtonDelegate?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        disableButtonsAndSetInitialState()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.resignOnTouchOutside = true
        closedButtonTapped(UIButton())
    }

    // MARK: - Actions
    @IBAction func closedButtonTapped(_ sender: Any) {
        delegate?.didTapCloseButton()
    }

    // MARK: - Helpers
    func disableButtonsAndSetInitialState() {
        if let sizeCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UISizeCell {
            sizeCell.disableAllButtons()
        }
    }

    func enableButtonsAndChangeColors() {
        if let sizeCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UISizeCell {
            let availableSizes = getAvailableSizes(for: selectedColorCode ?? "")
            sizeCell.configure(with: availableSizes)
        }

        if let qtyCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) as? UIQtyCell {
            qtyCell.noButton.isEnabled = true
            qtyCell.noButton.layer.borderColor = UIColor.black.cgColor
            qtyCell.noButton.tintColor = .black

            qtyCell.addButton.isEnabled = true
            qtyCell.addButton.layer.borderColor = UIColor.black.cgColor
            qtyCell.addButton.tintColor = .black
        }

        tableView.reloadData()
    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIidCell", for: indexPath) as! UIidCell
            if let product = product {
                cell.configure(with: product)
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIColorCell", for: indexPath) as! UIColorCell
            if let product = product {
                cell.configure(with: product)
                cell.delegate = self
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UISizeCell", for: indexPath) as! UISizeCell
            if let selectedColorCode = selectedColorCode {
                let availableSizes = getAvailableSizes(for: selectedColorCode)
                cell.configure(with: availableSizes)
                cell.delegate = self
                cell.resetSelection()
            }
            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UIQtyCell", for: indexPath) as! UIQtyCell
            cell.onQuantityChanged = { [weak self] newQuantity in
                self?.selectedQuantity = newQuantity
            }
            
            if let selectedColorCode = selectedColorCode,
               let selectedSize = selectedSize,
               let product = product {
                
                if let variant = product.variants?.first(where: {
                    $0.colorCode == selectedColorCode && $0.size == selectedSize
                }) {
                    cell.configure(with: variant.stock)
                }
            }
            return cell

        default:
            fatalError("Unexpected indexPath")
        }
    }

    // MARK: - UIColorCellDelegate
    func colorCell(_ cell: UIColorCell, didSelectColor color: UIColor, withColorCode colorCode: String) {
        selectedColorCode = colorCode
        selectedSize = nil

        delegate?.didEnableAddToCartButton(false)
        delegate?.didUpdateSelection(colorCode: colorCode, size: nil)

        if let sizeCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)) as? UISizeCell {
            sizeCell.disableAllButtons()
        }

        tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .automatic)
    }

    // MARK: - UISizeCellDelegate
    func sizeCell(_ cell: UISizeCell, didSelectSize size: String) {
        selectedSize = size

        delegate?.didUpdateSelection(colorCode: selectedColorCode, size: size)

        tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        delegate?.didEnableAddToCartButton(true)
    }

    // MARK: - Private Methods
    private func getAvailableSizes(for colorCode: String) -> [String: Int] {
        guard let product = product, let variants = product.variants else {
            return [:]
        }

        let sizes = variants.filter { $0.colorCode == colorCode }
        return Dictionary(grouping: sizes, by: { $0.size }).compactMapValues { $0.first?.stock }
    }
}
