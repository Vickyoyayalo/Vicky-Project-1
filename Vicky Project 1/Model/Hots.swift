//
//  Hots.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/18.
//
import UIKit
import Foundation

// MARK: - HotsResponse

struct HotsResponse: Codable {
    let data: [Hots]
}

// MARK: - Hots

struct Hots: Codable {
    let title: String
    let products: [Product]
}

// MARK: - Product

struct Product: Codable {
    let id: Int
    let category: String?
    let title: String
    let description: String
    let price: Int
    let texture: String?
    let wash: String?
    let place: String?
    let note: String?
    let story: String?
    let colors: [Color]?
    let sizes: [String]?
    let variants: [Variant]?
    let mainImage: String
    let images: [String]
    
    enum CodingKeys: String, CodingKey {
        case id, category, title, description, price, texture, wash, place, note, story, colors, sizes, variants, images
        case mainImage = "main_image"
    }
}

// MARK: - Color

struct Color: Codable {
    let code: String
    let name: String
}

// MARK: - Variant

struct Variant: Codable {
    let colorCode: String
    let size: String
    let stock: Int
    
    enum CodingKeys: String, CodingKey {
        case colorCode = "color_code"
        case size, stock
    }
}
