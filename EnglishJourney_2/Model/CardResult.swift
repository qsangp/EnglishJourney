//
//  CardResult.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 11/06/2021.
//

import Foundation

// MARK: - API
struct CardCates: Codable {
    let result: [CardCate]
}

struct CardCate: Codable {
    let title: String
    let parentId: Int?
    let numOfLession: Int
    let id: Int
}

struct CardLessons: Codable {
    let result: [CardLesson]
    let success: Bool
    let error: String
}

struct CardLesson: Codable {
    let title: String
    let audioFileName, audioFileNameBack: String
    let textToAudio, backDeck: String
    let id: Int
}

struct Dashboard: Codable {
    let result: DashboardResult
}

struct DashboardResult: Codable {
    let total, new, toReview, learned: Int
}

//MARK: Model
struct UserData {
    let name: String
    let familyName: String
    let email: String
    let id: Int
    var avatarImage: URL?
}

struct CardCategory {
    let title: String
    let parentID: Int
    let numOfLession: Int
    let id: Int
    var items: [CardCategoryItems]
    var imageURL: URL?
}

struct CardCategoryItems {
    let title: String
    let parentID: Int
    let numOfLession: Int
    let id: Int
    var items: [CardData]
    var imageURL: URL?
    var logTime: Date?
    var introduction: String?
}

struct CardData {
    let title: String
    let textToAudio, textToAudioBack: String
    let audioFrontName, audioBackName: String
    let frontText, backText: String
    let id: Int
    let description: String
    let imageURL: String
}

struct DashboardItems {
    let total, new, toReview, learned: Int
}



