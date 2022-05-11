//
//  UserView.swift
//  Statsu
//
//  Created by Luke Butterick on 07/05/2022.
//

import SwiftUI

struct UserView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var userData : UserData
    
    @Binding var previousState : String
    var body: some View {
        ZStack {
            LinearGradient(colors: [blueBgGradTop, blueBgGradBottom], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            VStack(spacing: 8) {
                Spacer()
                ZStack {
                    HStack{
                        BackButton(previousState: $previousState)
                            .environmentObject(appState)
                            .frame(width: 50, height: 25, alignment: .leading)
                            .padding(.all)
                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text(userData.username)
                            .font(Font.custom("Ubuntu-Regular", size: 30))
                            .foregroundColor(.white)
                        //Spacer()
                        AsyncImage(
                            url: URL(string: String("https://assets.ppy.sh/old-flags/\(userData.country_code).png")),
                            content: { image in
                                image.resizable()
                            },
                            placeholder: {
                                Color.white
                            })
                            .frame(maxWidth: 45, maxHeight: 30)
                        Spacer()
                    }
                }
                AsyncImage(
                    url: URL(string: userData.avatar_url),
                    content: { image in
                        image.resizable()
                    },
                    placeholder: {
                        ProgressView()
                    })
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .background(
                        Circle()
                            .fill(Color.white)
                            //.shadow(color: Color.gray, radius: 2, x: 0, y: 2)
                    ).padding(.all)
                HStack(spacing: 1){
                    Text(String(userData.statistics!.level.current))
                        .font(Font.custom("Ubuntu-Medium", size: 20))
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .stroke(.yellow, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                                .padding(-7)
                        )
                }.padding(.top, 2).padding(.bottom, 7)
                HStack(spacing: 10) {
                    MainStats(userData: userData)
                }.background(Color.init(red: 0.095, green:  0.095, blue: 0.13))
                    .cornerRadius(10)
                VStack {
                    Graph(uData: userData)
                        .stroke(.yellow, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                        .frame(width: 300, height: 100)
                        .background(Color.init(red: 0.095, green:  0.095, blue: 0.13))
                        .cornerRadius(10)
                    HStack {
                        Text("Rank : \(self.getRankString(rank: userData.statistics!.global_rank ?? -1))")
                            .font(Font.custom("Ubuntu-Regular", size:15))
                            .background(Color.init(red: 0.095, green:  0.095, blue: 0.13))
                            .cornerRadius(5.0)
                            .frame(height: 15)
                            .padding(3)
                        Text("Country : \(self.getRankString(rank: userData.statistics!.country_rank ?? -1))")
                            .font(Font.custom("Ubuntu-Regular", size:15))
                            .background(Color.init(red: 0.095, green:  0.095, blue: 0.13))
                            .cornerRadius(5.0)
                            .frame(height: 15)
                            .padding(3)
                    }
                        //.padding(.all)
                }.background(
                    Color.init(red: 0.095, green:  0.095, blue: 0.13))
                    .cornerRadius(10)
                HStack(spacing: 0) {
                    Spacer()
                    Image("XH").renderingMode(.original).resizable().frame(width: 32, height: 16).padding(.all)
                    Image("X").renderingMode(.original).resizable().frame(width: 32, height: 16).padding(.all)
                    Image("SH").renderingMode(.original).resizable().frame(width: 32, height: 16).padding(.all)
                    Image("S").renderingMode(.original).resizable().frame(width: 32, height: 16).padding(.all)
                    Image("A").renderingMode(.original).resizable().frame(width: 32, height: 16).padding(.all)
                    Spacer()
                }.frame(maxHeight: 10)
                HStack(spacing: 0) {
                    Spacer()
                    Text(String(userData.statistics!.grade_counts.ssh)).frame(width: 32, height: 16).padding(.all)
                    Text(String(userData.statistics!.grade_counts.ss)).frame(width: 32, height: 16).padding(.all)
                    Text(String(userData.statistics!.grade_counts.sh)).frame(width: 32, height: 16).padding(.all)
                    Text(String(userData.statistics!.grade_counts.s)).frame(width: 32, height: 16).padding(.all)
                    Text(String(userData.statistics!.grade_counts.a)).frame(width: 32, height: 16).padding(.all)
                    Spacer()
                }.frame(maxHeight: 5).font(Font.custom("Ubuntu-Bold", size: 12))
                Text("Top Scores:")
                    .font(Font.custom("Ubuntu-Regular", size: 20))
                    .foregroundColor(.white)
                Stats(uData: userData).padding(.top, 3).padding(.bottom, 10)
                //Spacer()
                //Spacer()
            }
        }.font(Font.custom("Ubuntu-Light", size:18))
            .foregroundColor(Color.white)
    }
    
    func getRankString(rank: Int) -> String {
        if rank == -1 {
            return "-"
        } else {
            return "#\(rank)"
        }
    }
}

struct Stats : View {
    @ObservedObject var uData : UserData
    var body: some View {
        ScrollView {
            ForEach(uData.scores!, id: \.id) { score in
                HStack(spacing: 2) {
                    Image("\(score.rank)")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 32, height: 16)
                    Text(score.beatmapset.title_unicode)
                        .font(Font.custom("Ubuntu-Light", size: 12))
                    Text("by")
                        .font(Font.custom("Ubuntu-Light", size: 12))
                    Text(score.beatmapset.artist_unicode)
                        .font(Font.custom("Ubuntu-Bold", size: 12))
                    Text("[\(score.beatmap.version)]")
                        .font(Font.custom("Ubuntu-Italic", size: 12))
                    Spacer()
                    Text("\(Int(score.pp))pp")
                        .font(Font.custom("Ubuntu-Bold", size: 12))
                        .foregroundColor(highlightPink)
                        .padding(1)
                    Text("\(formatScore(accuracy: score.accuracy))%")
                        .font(Font.custom("Ubuntu-Bold", size: 12))
                        .foregroundColor(.yellow)
                }.frame(minWidth: 350, maxWidth: 350, minHeight: 20, maxHeight: 20)
                    .background(darkBg)
                    .cornerRadius(5)
            }
        }
    }
    
    func formatScore(accuracy: Float) -> String {
        let final_acc = accuracy * 100
        if final_acc == 100.0 {
            return "100.0"
        } else if final_acc >= 10.0 {
            return String(format: "%.2f", final_acc)
        } else {
            return String(format: "%.3f", final_acc)
        }
    }
}

struct BackButton : View {
    @EnvironmentObject var appState : AppState
    @Binding var previousState : String
    var text = "Back"
    var body : some View {
        Button {
            appState.state = previousState
            previousState = "home"
        } label: {
            HStack(spacing: 2) {
                Arrow()
                    .stroke(.white, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                Text(text)
                    .font(Font.custom("Ubuntu-Light", size: 10))
            }
        }
    }
}
                      
struct Arrow : Shape {
    func path(in rect: CGRect) -> Path {
        let height = Int(rect.size.height)
        let width = Int(rect.size.width)
        var path = Path()
        
        path.move(to: CGPoint(x: (width / 10), y: ((4 * height) / 5)))
        path.addLine(to: CGPoint(x: ((width * 6) / 10), y: (4 * height / 5)))
        path.addCurve(to: CGPoint(x: (width * 6) / 10, y: height / 5), control1: CGPoint(x: (width * 9) / 10, y: height * 4 / 5), control2: CGPoint(x: (width * 9) / 10, y: height / 5))
        path.addLine(to: CGPoint(x: width / 10, y: height / 5))
        path.addLine(to: CGPoint(x: width * 3 / 10, y: height / 10))
        path.move(to: CGPoint(x: width / 10, y: height / 5))
        path.addLine(to: CGPoint(x: width * 3 / 10, y: height * 3 / 10))
        return path
    }
}

struct MainStats : View {
    @ObservedObject var userData : UserData
    var body: some View {
        Text("Accuracy :")
            .font(Font.custom("Ubuntu-Regular", size: 15))
        Text("\(String(format: "%.2f", userData.statistics!.hit_accuracy))%")
            .font(Font.custom("Ubuntu-Bold", size: 15))
            .foregroundColor(.yellow)
        Text("pp : ")
            .font(Font.custom("Ubuntu-Regular", size: 15))
        Text(String(Int(userData.statistics!.pp)))
            .font(Font.custom("Ubuntu-Bold", size: 15))
            .foregroundColor(highlightPink)
    }
}

struct Graph : Shape {
    @ObservedObject var uData : UserData
    func path(in rect: CGRect) -> Path {
        let height = Int(rect.size.height)
        let width = Int(rect.size.width)
        if uData.rank_history == nil {
            return Path()
        }
        let maxValue = uData.rank_history!.data.max()!
        var minValue = uData.rank_history!.data.min()!
        if maxValue == minValue {
            minValue = minValue - 1
        }
        var yScaling = Float(height) / Float((maxValue - minValue))
        let xScaling = Float(width) / Float(uData.rank_history!.data.count)
        if yScaling == Float(rect.size.height) {
            yScaling = yScaling / 2
        }
        var path = Path()
        let yInit = Int(yScaling * Float(uData.rank_history!.data[uData.rank_history!.data.startIndex] - minValue))
        path.move(to: CGPoint(x: 0, y: yInit))
        var counter = 1
        if (uData.statistics!.global_rank ?? -1) != -1 {
            for rank in uData.rank_history!.data {
                let x = Int(Float(counter) * xScaling)
                let y = Int(Float(rank - minValue) * yScaling)
                path.addLine(to: CGPoint(x: x, y: y))
                counter = counter + 1
            }
        }
        return path
    }
}

//struct UserView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserView()
//    }
//}

let highlightPink = Color.init(red: 1.0, green: (102/255), blue: (173/255))
let highlightDPink = Color.init(red: 0.8, green: (81/255), blue: (138/255))

let darkBg = Color.init(red: 0.095, green:  0.095, blue: 0.13)


