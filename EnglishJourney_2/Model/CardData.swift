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

struct CardCompletion: Codable {
    let result: Complete
}

struct Complete: Codable {
    let learned: Int
}

struct LogButton: Codable {
    let result: Bool
    let success: Bool
}

//MARK: -Chart Data
struct ChartDataLog: Codable {
    let result: DataLog
}

struct DataLog: Codable {
    let labels: [String]
    let dataSets: [DataSet]
}

struct DataSet: Codable {
    let labelDataSet: String
    let dataHits: [Int]
    let labels: [String]
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

struct CreateNewUser: Codable {
    let success: Bool
    let error: Error
}

struct Error: Codable {
    let code: Int
    let message: String
}


