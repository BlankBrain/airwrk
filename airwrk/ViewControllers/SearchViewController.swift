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
    var repoDetail = ""
    var repoOwner = ""
    var repoURL = ""
    //    var repoName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        search.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        getGitHubRepoNames(for: "blankbrain")
        
        
        
        
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
        
        
    }
    
    @objc func dismissCustomView() {
        guard let customView = view.subviews.last else { return }
        
        // Animate the custom view to slide down to the bottom
        UIView.animate(withDuration: 0.3, animations: {
            customView.frame.origin.y = self.tableView.frame.height
        }) { _ in
            customView.removeFromSuperview()
        }
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
    
    // 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
    
    
    func getUserInfo(for username: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        let url = URL(string: "https://api.github.com/users/\(username)")!
        let token = "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" // Replace with your GitHub API token
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(nil, NSError(domain: "Invalid response", code: 0, userInfo: nil))
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
                return
            }
            
            do {
                let user = try JSONDecoder().decode(User.self, from: data)
                
                // Fetch public repositories
                self.fetchPublicRepositories(for: username) { repositories, error in
                    if let error = error {
                        completion(nil, error)
                        return
                    }
                    
                    let userInfo = UserInfo(username: user.login,
                                            followerCount: user.followers,
                                            followingCount: user.following,
                                            repositories: repositories)
                    self.emptyUserInfo = userInfo
                    
                    
                    completion(userInfo, nil)
                }
            } catch {
                completion(nil, error)
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
}
