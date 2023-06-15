//
//  SearchViewController.swift
//  airwrk
//
//  Created by Md. Mehedi Hasan on 15/6/23.
//

import UIKit

class SearchViewController: BaseVC, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var search: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var emptyUserInfo = UserInfo(username: "", followerCount: 0, followingCount: 0, repositories: [])
    var filteredData: [String] = []
    var data = [""]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        getGitHubRepoNames(for: "blankbrain")
        fetchGitHubUserAvatar(username: "blankbrain") { avatarImage in
            if let image = avatarImage {
                print("Avatar image received")
                MySingleton.shared.userimage = avatarImage!
            } else {
                print("Failed to fetch avatar image")
            }
        }
        fetchGitHubUserInfo(username: "blankbrain") { result in
            switch result {
            case .success(let userInfo):
                MySingleton.shared.emptyUserInfo = userInfo
                print("User info received: \(userInfo)")
                
            case .failure(let error):
                print("Failed to fetch user info: \(error)")
            }
        }
        
        
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredData = searchText.isEmpty ? data : data.filter { $0.localizedCaseInsensitiveContains(searchText) }
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredData[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get the selected item from your data source
        let selectedItem = data[indexPath.row]
        MySingleton.shared.singletonItem = selectedItem
        performSegue(withIdentifier: "SearchToDetail", sender: self)
        
    }
    
    
    //MARK: functions
    
    func getGitHubRepoNames(for username: String) {
        guard let url = URL(string: "https://api.github.com/users/\(username)/repos") else {
            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let repositories = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                let repositoryNames = repositories?.compactMap { $0["name"] as? String }
                self.data = repositoryNames ?? []
                print("Repository Names: \(repositoryNames ?? [])")
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }
    
    
    
    
    func fetchGitHubUserInfo(username: String, completion: @escaping (Result<UserInfo, Error>) -> Void) {
        let urlString = "https://api.github.com/users/\(username)"
        
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
                let user = try JSONDecoder().decode(User.self, from: data)
                let userInfo = UserInfo(username: user.login,
                                        followerCount: user.followers,
                                        followingCount: user.following, repositories: [""])
                
                completion(.success(userInfo))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    
    func fetchPublicRepositories(for username: String, completion: @escaping ([String], Error?) -> Void) {
        let url = URL(string: "https://api.github.com/users/\(username)/repos")!
        let token = "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" // Replace with your GitHub API token
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion([], error)
                return
            }
            
        }
    }
    
    
    func fetchGitHubUserAvatar(username: String, completion: @escaping (UIImage?) -> Void) {
        let urlString = "https://api.github.com/users/\(username)"
        
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let avatarURLString = json["avatar_url"] as? String,
                   let avatarURL = URL(string: avatarURLString),
                   let imageData = try? Data(contentsOf: avatarURL),
                   let avatarImage = UIImage(data: imageData) {
                    completion(avatarImage)
                    MySingleton.shared.userimage = avatarImage
                } else {
                    completion(nil)
                }
            } catch {
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    
    
    
}
