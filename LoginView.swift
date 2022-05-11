//
//  LoginView.swift
//  Statsu
//
//  Created by user218002 on 3/20/22.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appState: AppState
    var body: some View {
        ZStack {
//            Image("profile_bg")
//                .resizable()
//                .scaledToFill()
//                .edgesIgnoringSafeArea(.all)
            LinearGradient(colors: [pinkBgGradTop, pinkBgGradBottom], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack (spacing: 20) {
                Image("logo")
                    .renderingMode(.original)
                    .resizable()
                    .frame(width: 200, height: 200)
                Spacer()
                    .frame(height: 150)
                Button {
                    let url = URL(string: "https://osu.ppy.sh/oauth/authorize?client_id=\(client_id)&redirect_uri=statsu://callback&response_type=code&scope=public")
                    if verifyUrl(urlString: url?.absoluteString) {
                        UIApplication.shared.open(url!)
                    } else {
                        appState.state = "home"
                    }
                } label: {
                    Text("Login")
                        .font(homeFont)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                                .fill(.linearGradient(colors: [pinkButGradTop, pinkButGradBot], startPoint: .top, endPoint: .bottom))
                                .frame(minWidth: 175, minHeight: 33, maxHeight: 33)
                        )
//                    Image("login")
//                        .renderingMode(.original)
//                        .frame(width: 175, height: 47)
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

func verifyUrl (urlString: String?) -> Bool {
    if let urlString = urlString {
        if let url = NSURL(string: urlString) {
            return UIApplication.shared.canOpenURL(url as URL)
        }
    }
    return false
}
