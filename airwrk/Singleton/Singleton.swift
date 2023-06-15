//
//  Singleton.swift
//  airwrk
//
//  Created by Md. Mehedi Hasan on 15/6/23.
//

import UIKit

class MySingleton {
    
    static let shared = MySingleton()
    
    private init() {
    }
    
    var emptyUserInfo = UserInfo(username: "", followerCount: 0, followingCount: 0, repositories: [])
    var userimage = UIImage()
    var singletonItem = ""
    var repositoryNames =  [""]
    var repositoryDescriptions =  [""]
    
    
    
}
