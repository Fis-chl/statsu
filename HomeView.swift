//
//  HomeView.swift
//  Statsu
//
//  Created by user218002 on 3/20/22.
//

import SwiftUI

struct HomeView : View {
    @ObservedObject var avatar : AvatarImage
    @ObservedObject var userData : UserData
    @ObservedObject var searchUserData : UserData
    @ObservedObject var recentActivity : RecentActivity
    @ObservedObject var userTopPlayed : UserTopPlayed
    @EnvironmentObject var requests : RequestHandler
    @EnvironmentObject var appState : AppState
    
    @Binding var searchText : String
    @Binding var previousState : String
    @State var showUserError = false
    @State var showLoading = false
    @State var showLogout = false

    var body: some View {
        ZStack {
            //Image("beatmap_bg")
                //.resizable()
                //.scaledToFill()
                //.edgesIgnoringSafeArea(.all)
            
            LinearGradient(colors: [blueBgGradTop, blueBgGradBottom], startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack {
                ZStack {
                    HStack {
                        LogoutButton(showLogout: $showLogout)
                            .environmentObject(appState)
                            .frame(width: 55, height: 25, alignment: .leading)
                            .padding(.all)
                        Spacer()
                    }
                    ZStack {
                        HStack(spacing: 10) {
                            Spacer()
                            AsyncImage(
                                url: URL(string: avatar.avatar_url),
                                content: { image in
                                    image.resizable()
                                    //aspectRatio(contentMode: .fit)
                                },
                                placeholder: {
                                    Color.white
                                })
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .padding(.all)
                        }.padding(.all)
                        HStack {
                            Spacer()
                            Text("Welcome, ")
                                .font(Font.custom("Ubuntu-Regular", size: 18))
                                .foregroundColor(.white)
                                .padding(.leading, 1)
                            Text("\(avatar.username)")
                                .font(Font.custom("Ubuntu-Bold", size: 18))
                                .foregroundColor(.white)
                                .padding(.trailing, 1)
                            Spacer()
                        }
                    }
                }
                Button {
                    showLoading = true
                    setUserData(user: ".me", u: userData, rq: requests) { r in
                        if r ?? false {
                            previousState = "home"
                            appState.state = "self"
                        } else {
                            appState.state = "login"
                        }
                    }
                } label: {
                    Text("Profile")
                        .font(homeFont)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.linearGradient(colors: [blueButGradTop, blueButGradBottom], startPoint: .top, endPoint: .bottom))
                                .frame(minWidth: 175, minHeight: 33, maxHeight: 33)
                        )
                }.padding(.all)
                Button {
                    showLoading = true
                    previousState = "home"
                    appState.state = "search_user"
                } label: {
                    Text("Search")
                        .font(homeFont)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.linearGradient(colors: [blueButGradTop, blueButGradBottom], startPoint: .top, endPoint: .bottom))
                                .frame(minWidth: 175, minHeight: 33, maxHeight: 33)
                        )
                }.padding(.all)
                Text("Your Most Played:")
                    .font(Font.custom("Ubuntu-Regular", size: 20))
                    .foregroundColor(.white)
                    .padding(.bottom, -50)
                UserMostPlayed(mostPlayed: userTopPlayed)
                    .padding(.all)
                Text("Your Recent Activity:")
                    .font(Font.custom("Ubuntu-Regular", size: 20))
                    .foregroundColor(.white)
                UserRecent(requests: requests, userRecents: recentActivity, user: avatar)
                    .padding(.top, 3).padding(.bottom, 10)
            }
        }.overlay(loadingOverlay)
    }
                  
    @ViewBuilder var loadingOverlay : some View {
        if showLoading {
            DimProgress()
                .foregroundColor(.white)
        }
    }
}

struct UserMostPlayed : View {
    @ObservedObject var mostPlayed : UserTopPlayed
    
    @State var currentBeatmap = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body : some View {
        ScrollViewReader { scrollView in
            ScrollView(.horizontal) {
                HStack(spacing: 20) {
                    ForEach(mostPlayed.topPlayed ?? [], id: \.beatmap_id) { beatmap in
                        BeatmapImageView(beatmap: beatmap)
                            .onAppear { print(beatmap.beatmapset.covers.cover) }
                    }
                }
            }
        }
    }
}

struct BeatmapImageView : View {
    var beatmap : BeatmapSearch
    var body : some View {
        ZStack {
            AsyncImage(
                url: URL(string: beatmap.beatmapset.covers.cover),
                content: { image in
                    image.resizable()
                },
                placeholder: {
                    Color.white
                })
                .frame(width: 320, height: 89)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.all)
                .mask(Color.init(red: 0.05, green: 0.05, blue: 0.05, opacity: 0.5))
                //.mask(LinearGradient(gradient: Gradient(colors: [.black, .black, .black, .clear]), startPoint: .bottom, endPoint: .top))
            VStack {
                HStack {
                    Text(beatmap.beatmapset.title)
                        .font(Font.custom("Ubuntu-Bold", size: 22))
                        .padding(.leading, 3).padding(.bottom, 3)
                    Spacer()
                }
                HStack {
                    Text("by")
                        .font(Font.custom("Ubuntu-Light", size: 18))
                        .padding(.leading, 3).padding(.bottom, 3)
                    Text(beatmap.beatmapset.artist_unicode)
                        .font(Font.custom("Ubuntu-Bold", size: 18))
                        .padding(.bottom, 3)
                    Spacer()
                }
                HStack {
                    Text(beatmap.beatmap.version)
                        .font(Font.custom("Ubuntu-BoldItalic", size: 15))
                        .padding(.leading, 3).padding(.bottom, 3)
                    Spacer()
                    Image("playcounts")
                        .frame(width: 20, height: 20)
                        .padding(.leading, 3).padding(.bottom, 3)
                    Text(String(beatmap.count))
                        .font(Font.custom("Ubuntu-Bold", size: 15))
                        .foregroundColor(.yellow)
                        .padding(.trailing, 7).padding(.bottom, 3)
                }
                Spacer()
            }.frame(width: 300, height: 79)
                .foregroundColor(.white)
                .padding(.top, 7)
        }
    }
}

struct UserRecent : View {
    @ObservedObject var requests : RequestHandler
    @ObservedObject var userRecents : RecentActivity
    @ObservedObject var user : AvatarImage
    var body : some View {
        ScrollView {
            ForEach(userRecents.activity!, id: \.id) { activity in
                if activity.type == "rank" {
                    RecentScore(userActivity: activity, user: user)
                        .frame(minWidth: 350, maxWidth: 350, minHeight: 20, maxHeight: 20)
                            .background(darkBg)
                            .cornerRadius(5)
                } else if activity.type == "achievement" {
                    RecentAch(userActivity: activity, user: user)
                        .frame(minWidth: 350, maxWidth: 350, minHeight: 20, maxHeight: 20)
                            .background(darkBg)
                            .cornerRadius(5)
                }
            }
        }
    }
}

struct RecentAch : View {
    var userActivity : UserActivity
    @ObservedObject var user : AvatarImage
    var body : some View {
        HStack (spacing: 2) {
            Spacer()
                .frame(width: 5)
            AsyncImage(
                url: URL(string: userActivity.achievement!.icon_url),
                content: { image in
                    image.resizable()
                    //aspectRatio(contentMode: .fit)
                },
                placeholder: {
                    Color.white
                })
                .frame(width: 18, height: 18)
                .clipShape(Circle())
            Spacer()
                .frame(width: 5)
            Text("\(user.username)")
                .foregroundColor(highlightPink)
                .font(Font.custom("Ubuntu-Bold", size: 12))
            Text(" unlocked the ")
                .foregroundColor(.white)
                .font(Font.custom("Ubuntu-Regular", size: 12))
            Text("'\(userActivity.achievement!.name)'")
                .foregroundColor(.white)
                .font(Font.custom("Ubuntu-Bold", size: 12))
            Text(" medal!")
                .foregroundColor(.white)
                .font(Font.custom("Ubuntu-Regular", size: 12))
            Spacer()
        }.frame(alignment: .leading)
    }
}

struct RecentScore : View {
    var userActivity : UserActivity
    @ObservedObject var user : AvatarImage
    var body : some View {
        HStack (spacing: 2) {
            Image("\(userActivity.scoreRank!)")
                .renderingMode(.original)
                .resizable()
                .frame(width: 32, height: 16)
            Text("\(user.username)")
                .foregroundColor(highlightPink)
                .font(Font.custom("Ubuntu-Bold", size: 12))
            Text(" achieved rank ")
                .foregroundColor(.white)
                .font(Font.custom("Ubuntu-Regular", size: 12))
            Text("#\(userActivity.rank!)")
                .foregroundColor(.white)
                .font(Font.custom("Ubuntu-Bold", size: 12))
            Text(" on ")
                .foregroundColor(.white)
                .font(Font.custom("Ubuntu-Regular", size: 12))
            Text("\(userActivity.beatmap!.title)")
                .foregroundColor(highlightPink)
                .font(Font.custom("Ubuntu-BoldItalic", size: 12))
            Spacer()
        }.frame(alignment: .leading)
    }
}

struct LogoutButton : View {
    @EnvironmentObject var appState : AppState
    @Binding var showLogout : Bool
    var text = "Sign Out"
    var body : some View {
        Button {
            showLogout = true
        } label: {
            HStack(spacing: 2) {
                Arrow()
                    .stroke(.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                Text(text)
                    .font(Font.custom("Ubuntu-Light", size: 10))
                    .foregroundColor(.white)
            }
        }.confirmationDialog(Text("Logout?"), isPresented: $showLogout)
            {
                Button("Yes") {
                    UserDefaults.standard.removeObject(forKey: KeyValue.access_token.rawValue)
                    UserDefaults.standard.removeObject(forKey: KeyValue.refresh_token.rawValue)
                    showLogout = false
                    appState.state = "login"
                }.font(Font.custom("Ubuntu-Regular", size: 12))
                    .background(.green)
            }
    }
}

struct SearchBar : View {
    @Binding var searchText : String
    @Binding var showUserError : Bool
    @Binding var showLoading : Bool
    
    @ObservedObject var searchUserData : UserData
    @EnvironmentObject var appState : AppState
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
                            setUserData(user: searchText, u: searchUserData, rq: requests) { r in
                                if r ?? false {
                                    appState.state = "search_user_found"
                                } else {
                                    showUserError = true
                                }
                            }
                        } else {
                            appState.state = "login"
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
                }
                    .alert("User not found!", isPresented: $showUserError) {
                        Button("OK", role: .cancel){ showLoading = false }
                    }.font(Font.custom("Ubuntu-Light", size: 15))
                    .foregroundColor(.white)
                    .aspectRatio(1, contentMode: .fit)
                Spacer()
            }
        }.cornerRadius(10)
    }
}

struct DimProgress : View {
    var body : some View {
        ZStack {
            darkBg.opacity(0.4).ignoresSafeArea()
            ProgressView()
        }
    }
}

let homeFont = Font.custom("Ubuntu-Medium", size: 30)

//struct HomeView_Previews : PreviewProvider {
//    static var previews: some View {
//        HomeView()
//    }
//}



