//
//  Decodables.swift
//  Statsu
//
//  Created by user218002 on 5/9/22.
//

import SwiftUI

struct BeatmapSearch : Decodable {
    
    var beatmap : Beatmap
    var beatmapset : BeatmapSetFull
    var count : Int
    var beatmap_id : Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(beatmap_id)
    }
}

struct BeatmapSetFull : Decodable {
    var covers : Covers
    var title : String
    var artist_unicode : String
    var creator : String
}

struct Covers : Decodable {
    var cover : String
}

struct UserSearch : Decodable {
    var user: UserSearchData
}

struct UserSearchData : Decodable {
    var data: [UserCompact]
}

struct UserCompact : Decodable {
    var avatar_url : String
    var country_code : String
    var username : String
    var id : Int
}

struct UserActivity : Decodable {
    var type : String
    var id : Int
    var beatmap : RecentBeatmap?
    var achievement : RecentAchievement?
    var rank : Int?
    var scoreRank : String?
    var createdAt : String
}

struct RecentBeatmap : Decodable {
    var title : String
}

struct RecentAchievement : Decodable {
    var name : String
    var icon_url : String
}

struct ProfileData : Decodable {
    var avatar_url : String
    var username : String
    var country_code : String
    var id : Int
    var rank_history : RankHistory?
    var statistics : Statistics
}

struct Statistics : Decodable {
    var grade_counts : GradeCounts
    var hit_accuracy : Float
    var level : Level
    var maximum_combo : Int
    var play_count : Int
    var play_time : Int
    var pp : Float
    var global_rank : Int?
    var ranked_score : Int
    var country_rank : Int?
}

struct RankHistory : Decodable {
    var mode : String
    var data : [Int]
}

struct GradeCounts : Decodable {
    var a : Int
    var s : Int
    var sh : Int
    var ss : Int
    var ssh : Int
}

struct Level : Decodable {
    var current : Int
    var progress : Int
}

struct Score: Decodable {
    var id : Int
    var rank: String
    var beatmap : Beatmap
    var beatmapset : BeatmapSet
    var mods: [String]
    var weight : Weight
    var accuracy : Float
    var max_combo : Int
    var pp : Float
}

struct Weight : Decodable {
    var percentage : Float
    var pp : Float
}

struct Beatmap : Decodable {
    var version : String
}

struct BeatmapSet : Decodable {
    var artist_unicode : String
    var creator : String
    var title_unicode : String
}

enum KeyValue : String {
    case access_token, refresh_token
}
