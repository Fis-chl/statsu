//
//  SearchUserView.swift
//  Statsu
//
//  Created by Luke Butterick on 09/05/2022.
//

import SwiftUI

struct SearchUserView : View {
    @EnvironmentObject var requests : RequestHandler
    @EnvironmentObject var appState : AppState
    
    @ObservedObject var searchUserData : UserData
    
    
    
    @State var showLoading = false
    @State var searchText = ""
    @ObservedObject var searchResults : SearchResults
    @Binding var previousState : String
    var body : some View {
        ZStack {
            // Background
            LinearGradient(colors: [blueBgGradTop, blueBgGradBottom], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            VStack(spacing: 3) {
                ZStack {
                    HStack {
                        BackButton(previousState: $previousState)
                            .environmentObject(appState)
                            .foregroundColor(.white)
                            .frame(width: 50, height: 25, alignment: .leading)
                            .padding(.all)
                        Spacer()
                    }
                    HStack {
                        UserSearchBar(searchResults: searchResults, searchText: $searchText, showLoading: $showLoading)
                            .environmentObject(appState)
                            .environmentObject(requests)
                            .frame(minWidth: 175, maxWidth: 175, minHeight: 33, maxHeight: 33)
                            .fixedSize()
                            .padding(.all)
                    }
                }
                UserSearchResults(searchResults: searchResults, searchUserData: searchUserData, searchText: $searchText, showLoading: $showLoading, previousState: $previousState)
            }
        }.overlay(loadingOverlay)
    }
    
    @ViewBuilder var loadingOverlay : some View {
        if showLoading {
            DimProgress()
        }
    }
}

struct UserSearchBar : View {
    @ObservedObject var searchResults : SearchResults
    @Binding var searchText : String
    @Binding var showLoading : Bool
    
    @EnvironmentObject var requests : RequestHandler
    
    var body: some View {
        ZStack {
            darkBg
            HStack {
                Spacer()
                TextField(text: $searchText, prompt: Text("Search users...")) {
                    
                }.foregroundColor(.white)
                    .font(Font.custom("Ubuntu-Regular", size: 18))
                    .frame(maxWidth: 175)
                    .fixedSize()
                    .background(
                        darkBg
                    ).cornerRadius(5)
                Button {
                    showLoading = true
                    requests.checkTokenValidity() { result in
                        if result! {
                            requests.searchUsers(query: searchText) { r in
                                if r != nil {
                                    searchResults.result = r?.result
                                    showLoading = false
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .padding(.all, 5)
                        .background(
                            darkBg
                        )
                }.font(Font.custom("Ubuntu-Light", size: 15))
                .foregroundColor(.white)
                .aspectRatio(1, contentMode: .fit)
                Spacer()
            }
        }.cornerRadius(10)
    }
}

struct UserSearchResults : View {
    @ObservedObject var searchResults : SearchResults
    @ObservedObject var searchUserData : UserData
    @EnvironmentObject var appState : AppState
    @EnvironmentObject var requests : RequestHandler
    @Binding var searchText : String
    @Binding var showLoading : Bool
    @Binding var previousState : String
    var body : some View {
        ScrollView {
            ForEach(searchResults.result ?? [], id: \.id) { user in
                UserResult(searchUserData: searchUserData, username: user.username, avatar_url: user.avatar_url, country_code: user.country_code, searchText: $searchText, showLoading: $showLoading, previousState: $previousState)
                    .environmentObject(appState)
                    .environmentObject(requests)
                    .padding(.all)
            }
        }
    }
}

struct UserResult : View {
    @ObservedObject var searchUserData : UserData
    @EnvironmentObject var requests : RequestHandler
    @EnvironmentObject var appState : AppState
    var username : String
    var avatar_url : String
    var country_code : String
    @Binding var searchText : String
    @Binding var showLoading : Bool
    @Binding var previousState : String
    
    var body : some View {
        Button {
            showLoading = true
            requests.checkTokenValidity() { result in
                if result! {
                    print(username)
                    setUserData(user: username, u: searchUserData, rq: requests) { r in
                        if r ?? false {
                            previousState = "search_user"
                            appState.state = "search_user_found"
                        }
                        showLoading = false
                    }
                } else {
                    showLoading = false
                    appState.state = "login"
                }
            }
        } label: {
            HStack {
                AsyncImage(
                    url: URL(string: avatar_url),
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        Color.white
                    })
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    .padding(.all)
                Text(username)
                    .font(Font.custom("Ubuntu-Regular", size: 20))
                    .foregroundColor(.white)
                AsyncImage(
                    url: URL(string: String("https://assets.ppy.sh/old-flags/\(country_code).png")),
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        Color.white
                    })
                    .frame(maxWidth: 45, maxHeight: 30)
                Spacer()
            }.background(
                darkBg
            ).cornerRadius(10)
                .frame(height: 50)
        }
    }
}
