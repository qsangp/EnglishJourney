//
//  CardViewModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation

class CardViewModel {
    var flashcard = [CardModel]()
    var flashcardData = [CardData]()
    
    var userData: UserData?
    var userDataFacebook: UserDataFacebook?
    var errorMessage: String? 
    
    func createUser(name: String, surname: String, username: String, email: String, password: String, completion: @escaping () -> ()) {

        requestToken { accessToken in

        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/user/CreateOrUpdateUser"),
              let payLoad = """
                {
                  "user": {
                    "name": "\(name)",
                    "surname": "\(surname)",
                    "userName": "\(name + surname)",
                    "emailAddress": "\(email)",
                    "password": "\(password)",
                    "isActive": true,
                  },
                  "assignedRoleNames": [
                    "ExternalUser"
                  ],
                  "sendActivationEmail": false,
                  "setRandomPassword": false
                }
                """.data(using: .utf8) else
        { return }

        var request = URLRequest(url: urlRequestUserLogIn)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.httpBody = payLoad
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(CreateNewUser.self, from: data!)
                    let message = decodedData.error.message
                    self.errorMessage = message
                    print("Failed to create new user: \(message)")
                }
                catch {
                    print(error.localizedDescription)
                    print("Successfully create new user")
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
            
        }
        task.resume()
        }
    }
    
    func fetchLogIn(username: String, password: String, completion: @escaping () -> ()) {
        
        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/Account"),
              let payLoad = """
                {
                "usernameOrEmailAddress": "\(username)",
                "password": "\(password)"
                }
                """.data(using: .utf8) else 
        { return }

        var request = URLRequest(url: urlRequestUserLogIn)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = payLoad
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(UserLoginAuthentication.self, from: data!)
                    let accessToken = decodedData.result
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")

                    self.checkToken(token: accessToken) { userData in
                        completion()
                    }
                }
                catch {
                    let err = error.localizedDescription
                    self.errorMessage = err
                    print(err)
                    
                }
            }
            
        }
        task.resume()
    }
    
    func requestToken(completion: @escaping (String) -> ()) {
        
        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/Account"),
              let payLoad = """
                {
                "usernameOrEmailAddress": "admin",
                "password": "admin123"
                }
                """.data(using: .utf8) else
        { return }

        var request = URLRequest(url: urlRequestUserLogIn)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = payLoad
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(UserLoginAuthentication.self, from: data!)
                    let accessToken = decodedData.result
                    DispatchQueue.main.async {
                        completion(accessToken)
                    }
                }
                catch {
                    print("Request Token Failed \(error.localizedDescription)")
                }
            }
            
        }
        task.resume()
    }
    
    func checkToken(token: String, completion: @escaping (UserData?) -> ()) {
        
        let urlUserProfile = URL(string: "https://app.ielts-vuive.com/api/services/app/session/GetCurrentLoginInformations")
        
        var request = URLRequest(url: urlUserProfile!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(UserProfile.self, from: data!)
                    let user = decodedData.result.user
                    self.userData = UserData(userNameOrEmail: user.name, userEmail: user.emailAddress, id: user.id)
                    DispatchQueue.main.async {
                        completion(self.userData)
                    }
                }
                catch {
                    print("Check Token Failed \(error.localizedDescription)")
                }
            }
            
        }
        task.resume()
    }
    
    func fetchFlashCards(completion: @escaping () -> ()) {
        
        let urlString = URL(string:"https://app.ielts-vuive.com/api/services/app/flashCardCategorieService/GetAllCategories")
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(FlashCard.self, from: data!)
                    for card in decodedData.result {
                        if card.parentId == 186 {
                            self.flashcard.append(CardModel(title: card.title, numOfLesson: card.numOfLession, id: card.id))
                        }
                    }
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                catch {
                    print("Fetch FlashCards Failed \(error.localizedDescription)")
                }
            }
            
        }
        task.resume()
        
    }
    
    func fetchFlashCardsData(id: Int, completion: @escaping () -> ()) {
        
        let urlStringData = "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetAllLessionsByCateId?id="
        
        let stringID = String(id)
        let newUrl = "\(urlStringData)\(stringID)"
        let urlStringDataID = URL(string: newUrl)
        
        var request = URLRequest(url: urlStringDataID!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(FlashCardData.self, from: data!)
                    for card in decodedData.result {
                        self.flashcardData.append(CardData(cardName: card.title, frontCardAudio: card.audioFileName, backCardAudio: card.audioFileNameBack, frontCardText: card.textToAudio, backCardText: card.backDeck, id: card.id))
                    }
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                catch {
                    print("Fetch FlashCards Data Failed \(error.localizedDescription)")
                }
            }
            
        }
        task.resume()
        
    }
    
}

