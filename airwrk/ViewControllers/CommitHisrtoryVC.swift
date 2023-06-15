//
//  CommitHisrtoryVC.swift
//  airwrk
//
//  Created by Md. Mehedi Hasan on 15/6/23.
//

import UIKit

class CommitHisrtoryVC: UIViewController ,UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var data:[String] = []
    var count = 0


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        fetchRepositoryCommits(owner: "blankbrain", repo: MySingleton.shared.singletonItem) { result in
            switch result {
            case .success(let commits):
                self.count = commits.count
                // Handle the retrieved commits
                for commit in commits {
                    //print("Commit ID: \(commit.author)")
                    //print("Commit Message: \(commit.commit)")
                    print("Commit ID: \(commit.sha)")
                    // Do something with each commit
                    self.data.append(commit.sha)
                    
                    
                }
                
            case .failure(let error):
                // Handle the error case
                print("Failed to fetch repository commits: \(error)")
            }
        }
        self.tableView.reloadData()

    }
    

    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = ( "Commit ID:" +  data[indexPath.row] )
       
        cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Return the desired row height for the cell at the specified indexPath
        return 50// Replace with your desired row height
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    
    func fetchRepositoryCommits(owner: String, repo: String, completion: @escaping (Result<[Commit], Error>) -> Void) {
        let urlString = "https://api.github.com/repos/\(owner)/\(repo)/commits"
        
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
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let commits = try decoder.decode([Commit].self, from: data)
                
                self.count = commits.count
                completion(.success(commits))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }


    
    
    

}
