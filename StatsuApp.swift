//
//  StatsuApp.swift
//  Statsu
//
//  Created by Luke Butterick on 17/03/2022.
//

import SwiftUI

@main
struct StatsuApp: App {
    @State var tokendata: TokenData?

    @StateObject var userData = UserData()
    @StateObject var searchUserData = UserData()
    @StateObject var avatar = AvatarImage()
    @StateObject var requests = RequestHandler()
    @StateObject var state = AppState()
    @StateObject var recentActivity = RecentActivity()
    @StateObject var userTopPlayed = UserTopPlayed()

    @State var searchText = ""

    var body: some Scene {
        WindowGroup {
            ContentView(uData: userData, searchUserData: searchUserData, avatar: avatar, recentActivity: recentActivity, userTopPlayed: userTopPlayed, searchText: searchText, previousState: "")
                .environmentObject(state)
                .environmentObject(requests)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "{path of URL?}"), allowing: Set(arrayLiteral: "*"))
                .onOpenURL() { (url) in
                    print(url)
                    let code: String = requests.getQueryStringParameter(url: url.absoluteString, param: "code")!
                    if (code != "") {
                        getTokenFromCode(code: code) { token in
                            setAvatarUrl() { r in
                                if r ?? false {
                                    setUserRecent() { res in
                                        if res ?? false {
                                            setUserMostPlayed() { re in
                                                if re ?? false {
                                                    state.state = "home"
                                                } else {
                                                    state.state = "home"
                                                }
                                            }
                                        } else {

                                        }
                                    }
                                    //state.state = "home"
                                }
                            }

                        }
                    }
                }
                .onAppear {
                    // Valid token = logged in, invalid token = requires log in
                    requests.checkTokenValidity() { result in
                        if result! {
                            setAvatarUrl() { r in
                                if r ?? false {
                                    setUserRecent() { res in
                                        if res ?? false {
                                            setUserMostPlayed() { re in
                                                if re ?? false {
                                                    state.state = "home"
                                                } else {
                                                    state.state = "home"
                                                }
                                            }
                                        } else {

                                        }
                                        //state.state = "home"
                                    }
                                    //state.state = "home"
                                }
                            }
                        } else {
                            state.state = "login"
                        }
                    }
                }
        }
    }

    func setAvatarUrl(completion: @escaping (Bool?) -> Void) {
        DispatchQueue.main.async {
            requests.getBasicData() { result in
                if let res = result {
                    self.avatar.avatar_url = res["avatar_url"] ?? ""
                    self.avatar.username = res["username"] ?? ""
                    self.avatar.id = Int(res["id"] ?? "-1") ?? -1
                    completion(true)
                }
            }
        }
    }

    func setUserRecent(completion: @escaping (Bool?) -> Void) {
        DispatchQueue.main.async {
            requests.getUserRecentActivity(id: self.avatar.id, limit: 20) { result in
                if let res = result {
                    self.recentActivity.activity = res
                    completion(true)
                }
            }
        }
    }

    func setUserMostPlayed(completion: @escaping (Bool?) -> Void) {
        DispatchQueue.main.async {
            requests.getUserMostPlayedBeatmap(id: self.avatar.id, limit: 20) { result in
                if result != nil {
                    self.userTopPlayed.topPlayed = result
                    print("hey")
                    completion(true)
                }
            }
        }
    }

    func getTokenFromCode(code: String, completion: @escaping (String?) -> Void) {
        guard let authurl = URL(string: "https://osu.ppy.sh/oauth/token") else { return }
        let body: [String: String] = ["client_id" : client_id, "client_secret" : client_secret,
                                      "code" : code, "grant_type" : "authorization_code", "redirect_uri" : "statsu://callback"]

        let finalBody = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: authurl)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { return }
            do {
                let decodedData =  try JSONDecoder().decode(TokenData.self, from: data)
                DispatchQueue.main.async {
                    self.tokendata = decodedData
                    completion(self.tokendata?.access_token)
                }
                UserDefaults.standard.set(decodedData.access_token, forKey: KeyValue.access_token.rawValue)
                UserDefaults.standard.set(decodedData.refresh_token, forKey: KeyValue.refresh_token.rawValue)
            } catch _ {
                completion("")
            }

        }.resume()
    }
}

func setUserData(user: String, u: UserData, rq: RequestHandler, completion: @escaping (Bool?) -> Void) {
    DispatchQueue.main.async {
        rq.getUserData(username: user) { uData in
            if uData != nil {
                if let avatar_url = uData?.avatar_url {
                    u.avatar_url = avatar_url
                }
                if let username = uData?.username {
                    u.username = username
                }
                if let country_code = uData?.country_code {
                    u.country_code = country_code
                }
                if let statistics = uData?.statistics {
                    u.statistics = statistics
                }
                if let rank_history = uData?.rank_history {
                    u.rank_history = rank_history
                }
                if let id = uData?.id {
                    u.id = id
                    rq.getUserScores(id: id, limit: 50) { scoreData in
                        if scoreData != nil {
                            if let score_data = scoreData {
                                u.scores = score_data
                                completion(true)
                            }
                        }
                    }
                }
            } else {
                completion(false)
            }
        }
    }
}

class UserTopPlayed : ObservableObject {
    @Published var topPlayed : [BeatmapSearch]?
}

class TokenData : Decodable {
    var access_token: String
    var expires_in: Int
    var refresh_token: String
    var token_type: String
}

class AppState : ObservableObject {
    @Published var state: String = "login"
}

class RecentActivity : ObservableObject {
    @Published var activity : [UserActivity]?
}

class UserData : ObservableObject {
    @Published var avatar_url = ""
    @Published var username = ""
    @Published var country_code = ""
    @Published var rank_history: RankHistory?
    @Published var id = 0
    @Published var statistics: Statistics?
    @Published var scores: [Score]?
}

class SearchResults : ObservableObject {
    @Published var result : [UserCompact]?
}
class AvatarImage : ObservableObject {
    @Published var avatar_url = ""
    @Published var username = ""
    @Published var id = -1
}

class RequestHandler : ObservableObject {

    func checkTokenValidity(completion: @escaping (Bool?) -> Void) {
        if self.checkTokensSet() {
            self.tryAccessToken() { result in
                if result! {
                    DispatchQueue.main.async {
                        print("Access token is valid")
                        completion(true)
                    }
                } else {
                    self.getFromRefreshToken() { _result in
                        if _result! {
                            self.tryAccessToken() { __result in
                                if __result! {
                                    DispatchQueue.main.async {
                                        print("New access token is valid!")
                                        //res = true
                                        completion(true)
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        completion(false)
                                    }
                                }
                            }
                        } else {
                            print("Refresh token invalid")
                            DispatchQueue.main.async {
                                completion(false)
                            }
                        }
                    }
                }
            }
        }
    }

    func tryAccessToken(completion: @escaping (Bool?) -> Void) {
        //var response_code = -1
        let optRequest = self.createGetRequest(apiUrl: "https://osu.ppy.sh/api/v2/me")
        if let request = optRequest {
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error == nil, let response = response as? HTTPURLResponse {
                    let response_code = response.statusCode
                    if response_code == 200 {
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }.resume()
        }
    }

    func getFromRefreshToken(completion: @escaping (Bool?) -> Void) {
        //var response_code = -1
        let ref_tok = UserDefaults.standard.string(forKey: KeyValue.refresh_token.rawValue)
        if let refresh_token = ref_tok {
            let body = ["client_id" : client_id, "client_secret" : client_secret, "callback_uri" : "statsu://callback", "grant_type" : "refresh_token", "refresh_token" : refresh_token]
            let header = ["Content-Type" : "appication/json", "Accept" : "application/json"]
            let optRequest = self.createRequest(apiUrl: "https://osu.ppy.sh/oauth/token", method: "POST", header: header, body: body)
            if let request = optRequest {
                URLSession.shared.dataTask(with: request) { (data, response, error) in
                    if error == nil {
                        do {
                            guard let data = data else { return }
                            let decodedData =  try JSONDecoder().decode(TokenData.self, from: data)
                            UserDefaults.standard.set(decodedData.access_token, forKey: KeyValue.access_token.rawValue)
                            UserDefaults.standard.set(decodedData.refresh_token, forKey: KeyValue.refresh_token.rawValue)
                            completion(true)
                        } catch _ {
                            completion(false)
                        }
                    }
                }.resume()
            }
        }
    }

    func updateTokens(appState: AppState, completion: @escaping (Bool?) -> Void) {
        getFromRefreshToken() { result in
            if result ?? false {
                completion(true)
            } else {
                appState.state = "login"
                completion(false)
            }
        }
    }

    func checkTokensSet() -> Bool {
        let access_token = UserDefaults.standard.string(forKey: KeyValue.access_token.rawValue)
        let refresh_token = UserDefaults.standard.string(forKey: KeyValue.refresh_token.rawValue)
        if access_token != nil {
            if refresh_token != nil {
                    // Both tokens present
                print("tokens present")
                return true
            }
            print("access token present")
        }
        print("no tokens found")
        return false
    }

    func createRequest(apiUrl: String, method: String, header : [String : String], body: [String : String]) -> URLRequest? {
        guard let url = URL(string: apiUrl) else { return nil }
        var request = URLRequest(url: url)
        if method == "GET" {
            request.httpMethod = "GET"
        } else if method == "POST" {
            request.httpMethod = "POST"
        } else {
            return nil
        }
        if !header.isEmpty {
            for key in header.keys {
                request.setValue(header[key], forHTTPHeaderField: key)
            }
        }
        if !body.isEmpty {
            let finalBody = try! JSONSerialization.data(withJSONObject: body)
            request.httpBody = finalBody
        }
        return request
    }

    func createGetRequest(apiUrl: String) -> URLRequest? {
        let tok = UserDefaults.standard.string(forKey: KeyValue.access_token.rawValue)
        if let token = tok {
            let header = ["Authorization" : "Bearer \(token)"]
            return createRequest(apiUrl: apiUrl, method: "GET", header: header, body: [:])
        } else {
            return nil
        }
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }

    func getBasicData(completion: @escaping ([String:String]?) -> Void) {
        guard let url = URL(string: "https://osu.ppy.sh/api/v2/me") else {
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let tok = UserDefaults.standard.string(forKey: KeyValue.access_token.rawValue)
        if let token = tok {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                do {
                    let decodedData = try JSONDecoder().decode(ProfileData.self, from: data)
                    DispatchQueue.main.async {
                        let final = ["avatar_url" : String(decodedData.avatar_url), "username" : String(decodedData.username), "id" : String(decodedData.id)] as [String : String]
                        completion(final)
                    }
                } catch let error {
                    print(error)
                }
            }.resume()
        }
    }

    func getUserData(username : String, completion: @escaping (UserData?) -> Void) {
        var urlString = "https://osu.ppy.sh/api/v2/"
        if username == ".me" {
            urlString += "me"
        } else {
            let norm = normaliseUsername(username: username)
            urlString = urlString + "users/" + norm + "?key=username"
        }
        let optRequest = createGetRequest(apiUrl: urlString)
        checkTokenValidity() { result in
            if result ?? false {
                if let request = optRequest {
                    Task {
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            guard let data = data else { return }
                            do {
                                let decodedData = try JSONDecoder().decode(ProfileData.self, from: data)
                                DispatchQueue.main.async {
                                    let avatar_url = decodedData.avatar_url
                                    let username = decodedData.username
                                    let country_code = decodedData.country_code
                                    let statistics = decodedData.statistics
                                    let rank_history = decodedData.rank_history
                                    let id = decodedData.id
                                    let uData = UserData()
                                    uData.avatar_url = avatar_url
                                    uData.username = username
                                    uData.country_code = country_code
                                    uData.statistics = statistics
                                    uData.rank_history = rank_history
                                    uData.id = id
                                    completion(uData)
                                }
                            } catch let error {
                                print(error)
                                completion(nil)
                            }
                        }.resume()
                    }
                }
            } else {
                completion(nil)
            }
        }
    }

    func normaliseUsername(username: String) -> String{
        var norm = ""
        for s in username {
            if s == " " {
                norm += "%20"
            } else if s == "[" {
                norm += "%5B"
            } else if s == "]" {
                norm += "%5D"
            } else {
                norm += String(s)
            }
        }
        print(norm)
        return norm
    }

    func getUserScores(id: Int, limit: Int, completion: @escaping ([Score]?) -> Void) {
        let urlString = "https://osu.ppy.sh/api/v2/users/\(id)/scores/best?limit=\(limit)"
        let optRequest = createGetRequest(apiUrl: urlString)
        if let request = optRequest {
            Task {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else { return }
                    do {
                        let decodedData = try JSONDecoder().decode([Score].self, from: data)
                        DispatchQueue.main.async {
                            completion(decodedData)
                        }
                    } catch let error {
                        print(error)
                        completion(nil)
                    }
                }.resume()
            }
        }
    }

    func getUserRecentActivity(id: Int, limit: Int, completion: @escaping ([UserActivity]?) -> Void) {
        let urlString = "https://osu.ppy.sh/api/v2/users/\(id)/recent_activity?limit=\(limit)"
        let optRequest = createGetRequest(apiUrl: urlString)
        print(urlString)
        if let request = optRequest {
            print("fine")
            Task {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else { return }
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                    do {
                        let decodedData = try JSONDecoder().decode([UserActivity].self, from: data)
                        DispatchQueue.main.async {
                            completion(decodedData)
                        }
                    } catch let error {
                        print(error)
                        completion(nil)
                    }
                }.resume()
            }
        }
    }

    func searchUsers(query: String, completion: @escaping (SearchResults?) -> Void) {
        let normquery = normaliseUsername(username: query)
        let urlString = "https://osu.ppy.sh/api/v2/search?mode=user&query=\(normquery)"
        let optRequest = createGetRequest(apiUrl: urlString)
        if let request = optRequest {
            Task {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else { return }
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                    do {
                        let decodedData = try JSONDecoder().decode(UserSearch.self, from: data)
                        DispatchQueue.main.async {
                            let result = SearchResults()
                            result.result = decodedData.user.data
                            completion(result)
                        }
                    } catch let error {
                        print(error)
                        completion(nil)
                    }
                }.resume()
            }
        }
    }

    func getUserMostPlayedBeatmap(id: Int, limit: Int, completion: @escaping ([BeatmapSearch]?) -> Void) {
        let urlString = "https://osu.ppy.sh/api/v2/users/\(id)/beatmapsets/most_played?limit=\(limit)"
        let optRequest = createGetRequest(apiUrl: urlString)
        if let request = optRequest {
            print("link ok")
            Task {
                URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data else { return }
                    if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
                       let jsonData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted) {
                        print(String(decoding: jsonData, as: UTF8.self))
                    } else {
                        print("json data malformed")
                    }
                    do {
                        let decodedData = try JSONDecoder().decode([BeatmapSearch].self, from: data)
                        DispatchQueue.main.async {
                            completion(decodedData)
                        }
                    } catch let error {
                        print(error)
                        completion(nil)
                    }
                }.resume()
            }
        }
    }
}

// Userdefaults
let userDefaults = UserDefaults.standard
var access_token = userDefaults.string(forKey: KeyValue.access_token.rawValue)
var refresh_token = userDefaults.string(forKey: KeyValue.refresh_token.rawValue)

// Constants
let client_id = "client_id"
let client_secret = "client_secret"
let pinkBgGradTop = Color.init(red: (63/255), green: (17/255), blue: (37/255))
let pinkBgGradBottom = Color.init(red: (35/255), green: (26/255), blue: (29/255))
let pinkButGradTop = Color.init(red: (87/255), green: (23/255), blue: (56/255))
let pinkButGradBot = Color.init(red: (94/255), green: (70/255), blue: (78/255))


let blueBgGradTop = Color.init(red: (27/255), green: (62/255), blue: (83/255))
let blueBgGradBottom = Color.init(red: (31/255), green: (41/255), blue: (46/255))
let blueButGradTop = Color.init(red: (42/255), green: (91/255), blue: (120/255))
let blueButGradBottom = Color.init(red: (53/255), green: (69/255), blue: (78/255))
