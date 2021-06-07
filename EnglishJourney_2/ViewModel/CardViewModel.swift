//
//  CardViewModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation

class CardViewModel {
    var cardCategory = [CardCategory]()
    var flashcard = [CardModel]()
    var flashcardData = [CardData]()
    

    var userData: UserData?
    
    //MARK: -User
    func createUser(name: String, surname: String, username: String, email: String, password: String, completion: @escaping (String?) -> ()) {
        
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
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            sessionConfig.timeoutIntervalForResource = 60.0
            let session = URLSession(configuration: sessionConfig)
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    do {
                        let decodedData = try JSONDecoder().decode(CreateNewUser.self, from: data!)
                        let message = decodedData.error.message
                        print("Failed to create new user: \(message)")
                        DispatchQueue.main.async {
                            completion(message)
                        }
                    }
                    catch {
                        print("Successfully create new user")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func fetchLogIn(username: String, password: String, completion: @escaping (Swift.Error?) -> ()) {
        
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
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(UserLoginAuthentication.self, from: data!)
                    let accessToken = decodedData.result
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    
                    self.checkToken(token: accessToken) { (userData, tokenError) in
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
                catch {
                    print("Failed to login : \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    //MARK: -Token
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
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
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
    
    func checkToken(token: String, completion: @escaping (UserData?, Swift.Error?) -> ()) {
        
        let urlUserProfile = URL(string: "https://app.ielts-vuive.com/api/services/app/session/GetCurrentLoginInformations")
        
        var request = URLRequest(url: urlUserProfile!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(UserProfile.self, from: data!)
                    let user = decodedData.result.user
                    self.userData = UserData(userNameOrEmail: user.name, userEmail: user.emailAddress, id: user.id)
                    DispatchQueue.main.async {
                        completion(self.userData, nil)
                    }
                }
                catch {
                    print("Check Token Failed \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                }
            }
            
        }
        task.resume()
    }
    
//MARK: -Tải Categories của flashcard
    
    func fetchFlashCards(completion: @escaping (Swift.Error?) -> ()) {
        
        let urlString = URL(string:"https://app.ielts-vuive.com/api/services/app/flashCardCategorieService/GetAllCategories")
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(FlashCard.self, from: data!)
                    for card in decodedData.result {
                        if card.parentId == nil {
                            self.cardCategory.append(CardCategory(title: card.title, numOfLesson: card.numOfLession, id: card.id))
                        }
                    }
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
                catch {
                    print("Fetch FlashCards Failed \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
            
        }
        task.resume()
        
    }
    
//MARK: - Tải flashcard theo ParentId
    
    func fetchFlashCardsByParentId(parentId: Int, completion: @escaping (Swift.Error?) -> ()) {
        
        let urlString = URL(string:"https://app.ielts-vuive.com/api/services/app/flashCardCategorieService/GetAllCategories")
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(FlashCard.self, from: data!)
                    self.flashcard.removeAll()
                    for card in decodedData.result {
                        if card.parentId == parentId {
                            self.flashcard.append(CardModel(title: card.title, numOfLesson: card.numOfLession, id: card.id))
                        }
                    }
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
                catch {
                    print("Fetch FlashCards Failed \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
            
        }
        task.resume()
        
    }
    
    func fetchFlashCardsData(id: Int, completion: @escaping (Swift.Error?) -> ()) {
        
        let urlStringData = "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetAllLessionsByCateId?id="
        
        let stringID = String(id)
        let newUrl = "\(urlStringData)\(stringID)"
        let urlStringDataID = URL(string: newUrl)
        
        var request = URLRequest(url: urlStringDataID!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(FlashCardData.self, from: data!)
                    for card in decodedData.result {
                        self.flashcardData.append(CardData(cardName: card.title, frontCardAudio: card.audioFileName, backCardAudio: card.audioFileNameBack, frontCardText: card.textToAudio, backCardText: card.backDeck, id: card.id))
                    }
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                }
                catch {
                    print("Fetch FlashCards Data Failed \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion(error)
                    }
                }
            }
            
        }
        task.resume()
    }
    
    func writeLogButon(buttonName: String, cardId: Int, categoryId: Int, userId: Int, completion: @escaping () -> ()) {
        
        requestToken { accessToken in
            
            guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/WriteLog\(buttonName)"),
                  let payLoad = """
                    {
                      "cardDeckId": \(cardId),
                      "cardCategoryId": \(categoryId),
                      "userId": \(userId)
                    }
                    """.data(using: .utf8) else { return }
            
            var request = URLRequest(url: urlRequestUserLogIn)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = payLoad
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            sessionConfig.timeoutIntervalForResource = 60.0
            let session = URLSession(configuration: sessionConfig)
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    do {
                        let decodedData = try JSONDecoder().decode(LogButton.self, from: data!)
                        let result = decodedData.success
                        if result {
                            DispatchQueue.main.async {
                                completion()
                            }
                        } else {
                            print("Failed to log again button")
                        }
                    }
                    catch {
                        print("Failed to log again button: \(error)")
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func fetchChartData(month: Int, year: Int, cateId: Int, userId: Int, completion: @escaping (ButtonDataSet?) -> ()) {
        
        requestToken { accessToken in
            
            guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetReportDataLessionBarChart?month=\(month)&year=\(year)&cateId=\(cateId)&userId=\(userId)") else { return }
            var request = URLRequest(url: urlRequestUserLogIn)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 30.0
            sessionConfig.timeoutIntervalForResource = 60.0
            let session = URLSession(configuration: sessionConfig)
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if error == nil {
                    do {
                        let decodedData = try JSONDecoder().decode(ChartDataLog.self, from: data!)
                        let againDataHits = decodedData.result.dataSets[0].dataHits
                        let completeDataHits = decodedData.result.dataSets[1].dataHits
                        let buttonDataSet = ButtonDataSet(againDataHits: againDataHits, completeDataHits: completeDataHits)
                        
                        print("fetch chart data success")
                        DispatchQueue.main.async {
                            completion(buttonDataSet)
                        }
                    }
                    catch {
                        print("Failed to log again button: \(error)")
                    }
                }
                
            }
            task.resume()
        }
    }
    
}

