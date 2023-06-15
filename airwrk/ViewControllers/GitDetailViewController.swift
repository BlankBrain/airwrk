//
//  GitDetailViewController.swift
//  airwrk
//
//  Created by Md. Mehedi Hasan on 15/6/23.
//

import UIKit

class GitDetailViewController: UIViewController {
    
    @IBOutlet weak var Name: UILabel!
    @IBOutlet weak var descripction: UILabel!
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var followerCount: UILabel!
    @IBOutlet weak var openIssueCount: UILabel!
    @IBOutlet weak var followingCount: UILabel!
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var forkCount: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        self.avatar.image = MySingleton.shared.userimage
        self.Name.text = MySingleton.shared.emptyUserInfo.username
        self.descripction.text = MySingleton.shared.repositoryDescriptions.first
        self.followerCount.text = String(MySingleton.shared.emptyUserInfo.followerCount)
        self.followingCount.text = String(MySingleton.shared.emptyUserInfo.followingCount)
        self.openIssueCount.text = String(MySingleton.shared.repositoryDescriptions.count)
        self.forkCount.text = ""
        self.repoName.text = MySingleton.shared.singletonItem
        fetchRepositoryDescription(owner: "blankbrain", repo: MySingleton.shared.singletonItem) { result in
            switch result {
            case .success(let description):
                // Handle the retrieved repository description
                print("Repository description: \(description)")
                // Do something with the description
                self.descripction.text = description
                
            case .failure(let error):
                // Handle the error case
                print("Failed to fetch repository description: \(error)")
            }
        }
        
        
    }
    
    func fetchRepositoryDescription(owner: String, repo: String, completion: @escaping (Result<String, Error>) -> Void) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)"
        
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
            completion(.failure(error))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                let error = NSError(domain: "Invalid response", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                let error = NSError(domain: "No data received", code: 0, userInfo: nil)
                completion(.failure(error))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let description = json["description"] as? String {
                    completion(.success(description))
                } else {
                    let error = NSError(domain: "No description available", code: 0, userInfo: nil)
                    completion(.failure(error))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    
    
    @IBAction func commitClicked(_ sender: Any) {
        performSegue(withIdentifier: "detailToCommit", sender: self)

    }
    
    
    
}




