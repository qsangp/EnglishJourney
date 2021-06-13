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
    let parentName: String
    let name, displayName: String
    let isGrantedByDefault: Bool
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
struct CardCateItems {
    let parentId: Int?
    let id: Int
    let title: String
    let isGrantedByDefault: Bool
    var items: [CardLessonItems]
}

struct CardLessonItems {
    let parentId: Int
    let id: Int
    let title: String
    var numOfLession: Int

}

struct CardItems {
    let title: String
    let audioFrontName, audioBackName: String
    let frontText, backText: String
    let id: Int
}

struct DashboardItems {
    let total, new, toReview, learned: Int
}

