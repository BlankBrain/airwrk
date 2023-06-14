
struct User: Decodable {
    let login: String
    let followers: Int
    let following: Int
}

struct privateRepository: Decodable {
    let name: String
    let isPrivate: Bool
}

struct UserInfo {
    let username: String
    let followerCount: Int
    let followingCount: Int
    let repositories: [String]
}
