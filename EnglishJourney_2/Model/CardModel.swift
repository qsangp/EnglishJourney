//
//  CardModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation

struct CardModel {
    let title: String
    let numOfLesson: Int
    let id: Int
}

struct CardData {
    let cardName: String
    let frontCardAudio: String
    let backCardAudio: String
    let frontCardText: String
    let backCardText: String
    let id: Int
}

struct ChartData {
    let againButtonPressedLog: Int
    let completeButtonPressedLog: Int
}

struct UserData {
    let userNameOrEmail: String
    let userEmail: String
    let id: Int
}

struct UserDataFacebook {
    let userName: String
    let userEmail: String
    let userId: String
}

struct CreateUser {
    let name: String
    let surname: String
    let username: String
    let email: String
    let password: String
}


