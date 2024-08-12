//
//  MarketManager.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/30.
//
import Foundation
import Alamofire
import SDWebImage


// MARK: - Protocols

protocol MarketManagerDelegate {
    func manager(_ manager: MarketManager, didGetHots hots: [Hots])
    func manager(_ manager: MarketManager, didGetProducts products: [Product])
    func manager(_ manager: MarketManager, didFailWith error: Error)
}

// MARK: - MarketManager

class MarketManager {
    var delegate: MarketManagerDelegate?
    private let baseURL = "https://api.appworks-school.tw/api/1.0"
    
    func getMarketingHots() {
        let urlString = "\(baseURL)/marketing/hots"
        
        guard let url = URL(string: urlString) else { return }
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                self.delegate?.manager(self, didFailWith: error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                let response = try decoder.decode(HotsResponse.self, from: data)
                let hots = response.data
                self.delegate?.manager(self, didGetHots: hots)
            } catch {
                self.delegate?.manager(self, didFailWith: error)
            }
        }
        
        task.resume()
    }
    
    func getProductListData(page: Int, category: String) {
        let urlString = "\(baseURL)/products/\(category)?paging=\(page)"
        
        AF.request(urlString).responseData { [weak self] (response: DataResponse<Data, AFError>) in
            guard let self = self else { return }
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let productList = try decoder.decode(ProductListDataModel.self, from: data)
                    
                  
                    for product in productList.data {
                        if let imageUrl = URL(string: product.mainImage) {
                            SDWebImageDownloader.shared.downloadImage(with: imageUrl, options: [], progress: nil) { (image, data, error, finished) in
                                if let error = error {
                                    print("Failed to download image: \(error)")
                                } else {
                                    print("Image downloaded successfully for URL: \(imageUrl)")
                                }
                            }
                        }
                    }
                    
                    self.delegate?.manager(self, didGetProducts: productList.data)
                } catch {
                    self.delegate?.manager(self, didFailWith: error)
                }
            case .failure(let error):
                self.delegate?.manager(self, didFailWith: error)
            }
        }
    }
}

// MARK: - ProductListDataModel

struct ProductListDataModel: Codable {
    let data: [Product]
    let next_page: Int?
}
