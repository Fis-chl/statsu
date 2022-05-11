//
//  ContentView.swift
//  Statsu
//
//  Created by Luke Butterick on 17/03/2022.
//

import SwiftUI


struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var requests : RequestHandler
    
    @StateObject var uData : UserData
    @StateObject var searchUserData : UserData
    @StateObject var avatar : AvatarImage
    @StateObject var recentActivity : RecentActivity
    @StateObject var searchResults = SearchResults()
    @StateObject var userTopPlayed : UserTopPlayed
    
    @State var searchText : String
    @State var previousState : String

    var body: some View {
        return Group {
            if (appState.state == "home") {
                HomeView(avatar: avatar, userData: uData, searchUserData: searchUserData, recentActivity: recentActivity, userTopPlayed: userTopPlayed, searchText: $searchText, previousState: $previousState)
                    .environmentObject(requests)
                    .environmentObject(appState)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            } else if (appState.state == "login") {
                LoginView()
                    .environmentObject(appState)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            } else if (appState.state == "self") {
                UserView(userData: uData, previousState: $previousState)
                    .environmentObject(requests)
                    .environmentObject(appState)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            } else if (appState.state == "search_user_found") {
                UserView(userData: searchUserData, previousState: $previousState)
                    .environmentObject(requests)
                    .environmentObject(appState)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            } else if (appState.state == "search_user") {
                SearchUserView(searchUserData: searchUserData, searchResults: searchResults, previousState: $previousState)
                    .environmentObject(requests)
                    .environmentObject(appState)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.3)))
            }
        }
    }
}


