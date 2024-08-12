//
//  ProfileViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/7/24.
//
import UIKit

// MARK: - ProfileViewController

class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
            layout.minimumLineSpacing = 20
            layout.minimumInteritemSpacing = 20
            collectionView.collectionViewLayout = layout
            collectionView.backgroundColor = .white
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var profileImage: UIImageView! {
        didSet {
            profileImage.layer.cornerRadius = 35
            profileImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var totalSpendLabel: UILabel! {
        didSet {
            totalSpendLabel.text = "累計消費 NT$91800"
        }
    }
    
    // MARK: - Properties
    
    let sectionTitles = ProfileInfo.shared.sections
    
    // MARK: - Lifecycle Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let userName = UserDefaults.standard.string(forKey: "UserName") {
            nameLabel.text = userName
        }
        
        if let userProfilePictureURL = UserDefaults.standard.string(forKey: "UserProfilePicture"),
           let url = URL(string: userProfilePictureURL) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("載入圖片失敗: \(error)")
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("無法將數據轉換為圖片。")
                    return
                }
                
                DispatchQueue.main.async {
                    self.profileImage.image = image
                }
            }.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = sectionTitles[section]
        return ProfileInfo.shared.getData(for: sectionType).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = sectionTitles[indexPath.section]
        let data = ProfileInfo.shared.getData(for: sectionType)[indexPath.row]
        
        if sectionType == .order {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OrderCell", for: indexPath) as! OrderCell
            cell.configure(with: data)
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ServiceCell", for: indexPath) as! ServiceCell
            cell.configure(with: data)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let profileHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderView.reuseIdentifier, for: indexPath) as? ProfileHeaderView else {
            fatalError("無法取得 ProfileHeaderView")
        }
        
        let sectionTitle = sectionTitles[indexPath.section].rawValue
        profileHeaderView.textLabel.text = sectionTitle
        
        if indexPath.section == 0 {
            profileHeaderView.seeAllButton.setTitle("查看全部 >", for: .normal)
            profileHeaderView.seeAllButton.isHidden = false
        } else {
            profileHeaderView.seeAllButton.isHidden = true
        }
        
        return profileHeaderView
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let section = ProfileInfo.shared.sections[indexPath.section]
        let padding: CGFloat = 35
        let itemsPerRow: CGFloat
        let interItemSpacing: CGFloat
        
        if section == .order {
            itemsPerRow = 5
            interItemSpacing = padding * (itemsPerRow - 1)
        } else if section == .service {
            itemsPerRow = 4
            interItemSpacing = padding * (itemsPerRow - 1)
        } else {
            return CGSize(width: 60, height: 50)
        }
        
        let availableWidth = collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right - interItemSpacing
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
