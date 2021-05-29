//
//  CardData.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation

// MARK: - FlashCard
struct FlashCard: Codable {
    let result: [Category]
    
}

// MARK: - Result
struct Category: Codable {
    let title: String
    let parentId: Int?
    let numOfLession: Int
    let id: Int
}

// MARK: - FlashCardData

struct FlashCardData: Codable {
    let result: [Data]
}

struct Data: Codable {
    let title: String
    let audioFileName, audioFileNameBack: String
    let textToAudio, backDeck: String
    let id: Int
}

// MARK: - User Login

struct UserLoginAuthentication: Codable {
    let result: String
}

struct UserProfile: Codable {
    let result: Result
}

struct Result: Codable {
    let user: User
}

// MARK: - User
struct User: Codable {
    let name, surname, userName, emailAddress: String
    let id: Int
}



