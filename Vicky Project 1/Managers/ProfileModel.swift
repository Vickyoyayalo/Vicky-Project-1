//
//  ProfileModel.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/25.
//
import UIKit

// MARK: - CellData

struct CellData {
    let imageName: String
    let title: String
}

// MARK: - ProfileInfo Model

class ProfileInfo {
    
    enum Headers: String, CaseIterable {
        case order = "我的訂單"
        case service = "更多服務"
    }
    
    // MARK: - Singleton Instance
    
    static let shared = ProfileInfo()
    
    let sections = Headers.allCases
    var data: [Headers: [CellData]]
    
    // MARK: - Initialization
    
    private init() {
        data = [:]
        initializeData()
    }
    
    // MARK: - Data Initialization
    
    private func initializeData() {
        data[.order] = [
            CellData(imageName: "AwaitingPayment", title: "待付款"),
            CellData(imageName: "AwaitingShipment", title: "待出貨"),
            CellData(imageName: "Shipped", title: "待簽收"),
            CellData(imageName: "AwaitingReview", title: "待評價"),
            CellData(imageName: "Exchange", title: "退換貨")
        ]
        
        data[.service] = [
            CellData(imageName: "Starred", title: "收藏"),
            CellData(imageName: "Notification", title: "貨到通知"),
            CellData(imageName: "Refunded", title: "帳戶退款"),
            CellData(imageName: "Address", title: "地址"),
            CellData(imageName: "CustomerService", title: "客服訊息"),
            CellData(imageName: "SystemFeedback", title: "系統回饋"),
            CellData(imageName: "RegisterCellphone", title: "手機綁定"),
            CellData(imageName: "Settings", title: "設定")
        ]
    }
    
    // MARK: - Data Access
    
    func getData(for type: Headers) -> [CellData] {
        return data[type] ?? []
    }
}
