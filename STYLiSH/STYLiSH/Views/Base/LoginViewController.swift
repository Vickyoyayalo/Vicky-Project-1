//
//  LoginViewController.swift
//  STYLiSH
//
//  Created by Vickyhereiam on 2024/8/8.
//

import UIKit
import FBSDKLoginKit
import StatusAlert

// MARK: - LoginViewController

class LoginViewController: UIViewController {

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
    }
    
    // MARK: - Actions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { result, error in
            if let error = error {
                print("Facebook 登入失敗: \(error)")
                return
            }
            
            guard let result = result, !result.isCancelled else {
                print("Facebook 登入被取消")
                return
            }
            
            // 獲取 Facebook access_token
            if let accessToken = AccessToken.current?.tokenString {
                print("Facebook Access Token: \(accessToken)")
                
                // 將 access_token 存儲在 UserDefaults 中
                UserDefaults.standard.set(accessToken, forKey: "access_token")
                
                // 調用使用者登入 API
                self.signInWithFacebook(accessToken: accessToken)
            }
        }
    }

    // MARK: - Sign In
    
    func signInWithFacebook(accessToken: String) {
        let url = URL(string: "https://api.appworks-school.tw/api/1.0/user/signin")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "provider": "facebook",
            "access_token": accessToken
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("API 請求失敗: \(error)")
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("無效的回應")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let token = data["access_token"] as? String {
                    print("收到 STYLiSH Token: \(token)")
                    
                    self.saveTokenAndFetchProfile(token: token)
                    
                    DispatchQueue.main.async {
                        self.showLoginSuccessAlert()
                        
                        self.dismiss(animated: true) {
                            if let tabBarController = self.presentingViewController as? TabbarController {
                                tabBarController.selectedIndex = 2
                            }
                        }
                    }
                }
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    print("錯誤: \(errorMessage)")
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "登入失敗", message: errorMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "重試", style: .default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        task.resume()
    }

    // MARK: - Save Token and Fetch Profile
    
    func saveTokenAndFetchProfile(token: String) {
        UserDefaults.standard.set(token, forKey: "STYLiSHToken")
        fetchUserProfile(token: token)
    }
    
    func fetchUserProfile(token: String) {
        let url = URL(string: "https://api.appworks-school.tw/api/1.0/user/profile")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("個人資料 API 請求失敗: \(error)")
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                print("無效的回應")
                return
            }
            
            if httpResponse.statusCode == 200 {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let userData = json["data"] as? [String: Any] {
                    print("使用者資料: \(userData)")
                    
                    UserDefaults.standard.set(userData["name"], forKey: "UserName")
                    UserDefaults.standard.set(userData["picture"], forKey: "UserProfilePicture")
                    UserDefaults.standard.synchronize()
                }
            } else {
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let errorMessage = json["error"] as? String {
                    print("錯誤: \(errorMessage)")
                    
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "登入失敗", message: errorMessage, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "重試", style: .default, handler: { _ in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    // MARK: - Alerts
    
    func showLoginSuccessAlert() {
        let statusAlert = StatusAlert()
        statusAlert.image = UIImage(named: "Success01")
        statusAlert.title = "登入成功"
        statusAlert.canBePickedOrDismissed = true
        statusAlert.sizesAndDistances.alertWidth = 175
        statusAlert.sizesAndDistances.minimumAlertHeight = 175
        statusAlert.appearance.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        statusAlert.appearance.tintColor = .white
        statusAlert.showInKeyWindow()
    }

    // MARK: - Close Action
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
