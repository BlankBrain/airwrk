//
//  File.swift
//  airwrk
//
//  Created by Md. Mehedi Hasan on 15/6/23.
//

import Foundation


struct Repository: Decodable {
    let name: String
    let description: String?
    let owner: Owner
    let htmlURL: String
    let commitsURL: String
    
    private enum CodingKeys: String, CodingKey {
        case name
        case description
        case owner
        case htmlURL = "html_url"
        case commitsURL = "commits_url"
    }
}

struct Owner: Decodable {
    let login: String
}

struct Commit: Decodable {
    let sha: String
    let author: Author
    let commit: CommitInfo
}

struct Author: Decodable {
    let login: String
}

struct CommitInfo: Decodable{
    
}
struct RepoInfo {
    let name: String
    let description: String
}
