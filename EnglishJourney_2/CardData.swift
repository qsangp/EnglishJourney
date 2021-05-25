//
//  CardData.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation

import Foundation

// MARK: - FlashCard
struct FlashCard: Codable {
    let result: [Result]
    
}

// MARK: - Result
struct Result: Codable {
    let title: String
    let parentId: Int?
    let numOfLession: Int
    let id: Int

}
