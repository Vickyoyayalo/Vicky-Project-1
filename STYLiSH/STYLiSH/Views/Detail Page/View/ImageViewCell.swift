//
//  MenDetailHeaderView.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/27.
//
import UIKit
import Kingfisher

// MARK: - ImageViewCell

class ImageViewCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var imageView0: UIImageView!
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    // MARK: - Properties
    
    var currentPage: Int = 0
    
    // MARK: - Configuration
    
    func configure(with product: Product) {
        let imageViews = [imageView0, imageView1, imageView2, imageView3]
        
        for (index, imageView) in imageViews.enumerated() {
            if index < product.images.count, let url = URL(string: product.images[index]) {
                imageView?.kf.setImage(with: url)
            } else {
                imageView?.image = UIImage(named: "Image_Placeholder")
            }
        }
        
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        pageControl.numberOfPages = product.images.count
    }
    
    // MARK: - Helper Methods
    func setImagesAlpha(to alpha: CGFloat) {
        let imageViews = [imageView0, imageView1, imageView2, imageView3]
        for imageView in imageViews {
            imageView?.alpha = alpha
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ImageViewCell: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        pageControl.currentPage = Int(page)
    }
}
