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
        getRepositoryDetailsAndCommits(for: "blankbrain", repository: selectedItem)
        // Create a custom view to display the details
        let customView = UIView(frame: CGRect(x: 0, y: tableView.frame.height, width: tableView.frame.width, height: 200))
        customView.backgroundColor = .white
        
        // Create four labels for displaying information
        let label1 = UILabel(frame: CGRect(x: 0, y: 0, width: customView.frame.width, height: 50))
        label1.text = "Label 1"
        label1.textAlignment = .center
        
        let label2 = UILabel(frame: CGRect(x: 0, y: 50, width: customView.frame.width, height: 50))
        label2.text = "Label 2"
        label2.textAlignment = .center
        
        let label3 = UILabel(frame: CGRect(x: 0, y: 100, width: customView.frame.width, height: 50))
        label3.text = "Label 3"
        label3.textAlignment = .center
        
        let label4 = UILabel(frame: CGRect(x: 0, y: 150, width: customView.frame.width, height: 50))
        label4.text = "Label 4"
        label4.textAlignment = .center
        
        // Add the labels to the custom view
        customView.addSubview(label1)
        customView.addSubview(label2)
        customView.addSubview(label3)
        customView.addSubview(label4)
        
        // Add the custom view to the main view
        view.addSubview(customView)
        view.backgroundColor = .systemTeal
        
        // Animate the custom view to slide up from the bottom
        UIView.animate(withDuration: 0.3) {
            customView.frame.origin.y = tableView.frame.height - customView.frame.height
        }
        
        // Add swipe gesture recognizer to dismiss the custom view
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissCustomView))
        swipeDownGesture.direction = .down
        customView.addGestureRecognizer(swipeDownGesture)
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

    func getRepositoryDetailsAndCommits(for owner: String, repository: String) {
        let url = URL(string: "https://api.github.com/repos/\(owner)/\(repository)")!
        let token = "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" // Replace with your GitHub API token
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                let repository = try JSONDecoder().decode(Repository.self, from: data)
                print("Repository Details:")
                print("Name: \(repository.name)")
                print("Description: \(repository.description ?? "N/A")")
                print("Owner: \(repository.owner.login)")
                print("URL: \(repository.htmlURL)")
                
                 
                self.repoDetail = repository.name
                self.self.repoOwner = repository.description ?? "N/A"
                self.repoURL = repository.htmlURL
                self.tableView.reloadData()
                
                // Fetch commit history
                self.fetchCommitHistory(for: repository)
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }

    func fetchCommitHistory(for repository: Repository) {
        let url = URL(string: repository.commitsURL.replacingOccurrences(of: "{/sha}", with: ""))!
        let token = "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" // Replace with your GitHub API token
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
                let commits = try JSONDecoder().decode([Commit].self, from: data)
                print("Commit History:")
                for commit in commits {
                    print("SHA: \(commit.sha)")
                    print("Author: \(commit.author.login)")
                    print("Message: \(commit.commit)")
                    print("----")
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
        
        task.resume()
    }

   
}
