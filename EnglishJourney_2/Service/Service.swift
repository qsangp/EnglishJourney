//
//  Service.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 11/06/2021.
//

import Foundation

class Service {
    
    static let shared = Service()
    
    func fetchFlashCards(completion: @escaping (Swift.Result<[CardCategory]?, ErrorMessage>) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {return}
        let urlString = URL(string:"https://app.ielts-vuive.com/api/services/app/flashCardCategorieService/GetAllCategoriesGranted")
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("fetch flashcard response: \(response!)")
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(CardCates.self, from: data!)
                var cardCategory = [CardCategory]()
                var cardLessons = [CardCategoryItems]()
                
                for card in decodedData.result {
                    let parentId = card.parentId
                    let id = card.id
                    
                    if let parentId = parentId {
                        cardLessons.append(CardCategoryItems(title: card.title, parentID: parentId, numOfLession: card.numOfLession, id: id, items: [CardData](), imageURL: nil, logTime: nil, introduction: ""))
                    } else {
                        cardCategory.append(CardCategory(title: card.title, parentID: 0, numOfLession: card.numOfLession, id: card.id, items: [CardCategoryItems](), imageURL: nil))
                    }
                }
                                
                cardCategory = cardCategory.map({ card in
                    var card = card
                    let lesson = cardLessons.filter({$0.parentID == card.id})
                    card.items = lesson
                    return card
                })
                
                DispatchQueue.main.async {
                    completion(.success(cardCategory))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    
    func fetchFlashCardsData(cardId: Int, completion: @escaping (Swift.Result<[CardData]?, ErrorMessage>) -> Void) {
        
        let userId = UserDefaults.standard.integer(forKey: "userId")

        let urlStringData = "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetAllLessionsByCateId?id="
        
        let stringId = String(cardId)
        let userIdString = String(userId)
        let newUrl = "\(urlStringData)\(stringId)&userId=\(userIdString)"
        let urlStringDataID = URL(string: newUrl)
        
        var request = URLRequest(url: urlStringDataID!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("fetch flashcard data response: \(response!)")
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(FlashCardData.self, from: data!)
                var cardItems = [CardData]()
                for card in decodedData.result {
                    cardItems.append(CardData(title: card.title, textToAudio: card.textToAudio ?? "", textToAudioBack: card.textToAudioBack ?? "", audioFrontName: card.audioFileName ?? "", audioBackName: card.audioFileNameBack ?? "", frontText: card.prontDeck ?? "", backText: card.backDeck ?? "", id: card.id, description: card.description ?? "", imageURL: card.imageUrl ?? ""))
                }
                DispatchQueue.main.async {
                    completion(.success(cardItems))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    func fetchChartData(cardId: Int, completion: @escaping (Swift.Result<ButtonDataSet?, ErrorMessage>) -> Void) {
        
        let date = Date()
        let formatterMonth = DateFormatter()
        formatterMonth.dateFormat = "MM"
        let formatterYear = DateFormatter()
        formatterYear.dateFormat = "yyyy"
        
        guard let token = UserDefaults.standard.string(forKey: "accessToken"),
              let currentMonth = Int(formatterMonth.string(from: date)),
              let currentYear = Int(formatterYear.string(from: date)) else {return}
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetReportDataLessionBarChart?month=\(currentMonth)&year=\(currentYear)&cateId=\(cardId)&userId=\(userId)") else { return }
        var request = URLRequest(url: urlRequestUserLogIn)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("fetch data hits response: \(response!)")
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(ChartDataLog.self, from: data!)
                let againDataHits = decodedData.result.dataSets[0].dataHits
                let completeDataHits = decodedData.result.dataSets[1].dataHits
                let buttonDataSet = ButtonDataSet(againDataHits: againDataHits, completeDataHits: completeDataHits)
                
                DispatchQueue.main.async {
                    completion(.success(buttonDataSet))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    func writeLogButtonHits(buttonName: String, cardId: Int, completion: @escaping (Swift.Result<Bool, ErrorMessage>) -> Void) {
        
        guard let token = UserDefaults.standard.string(forKey: "accessToken") else {return}
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/WriteLog\(buttonName)"),
              let payLoad = """
                    {
                      "cardCategoryId": \(cardId),
                      "userId": \(userId)
                    }
                    """.data(using: .utf8) else { return }
        
        var request = URLRequest(url: urlRequestUserLogIn)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = payLoad
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 30.0
        sessionConfig.timeoutIntervalForResource = 60.0
        let session = URLSession(configuration: sessionConfig)
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("write log button response: \(response!)")
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(LogButton.self, from: data!)
                let success = decodedData.success
                completion(.success(success))
            }
            catch {
                completion(.failure(.invalidData))
            }
        }.resume()
    }
    
    func getInfoDashBoard(cardId: Int, completion: @escaping (Swift.Result<DashboardItems?, ErrorMessage>) -> Void) {
        
        let userId = UserDefaults.standard.integer(forKey: "userId")
        
        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetInfoDashboard"),
              
              let payLoad = """
                {
                  "cardCategoryId": \(cardId),
                  "userId": \(userId)
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
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("fetch info dashboard response: \(response!)")
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(Dashboard.self, from: data!)
                let results = decodedData.result
                let dashboard = DashboardItems(total: results.total, new: results.new, toReview: results.toReview, learned: results.total)
                DispatchQueue.main.async {
                    completion(.success(dashboard))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    func fetchLogin(email: String, password: String, completion: @escaping (Swift.Result<String, ErrorMessage>) -> Void) {
        
        guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/Account"),
              
              let payLoad = """
                {
                "usernameOrEmailAddress": "\(email)",
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
        
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                print("fetch login: \(response!)")
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(UserLoginAuthentication.self, from: data!)
                let accessToken = decodedData.result
                UserDefaults.standard.setValue(accessToken, forKey: "accessToken")
                DispatchQueue.main.async {
                    completion(.success(accessToken))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
    
    func createUser(name: String, email: String, completion: @escaping (String?) -> ()) {
        
        fetchLogin(email: "admin", password: "s@ng7nQ-ij", completion: { results in
            switch results {
            case .success(let accessToken):
                
                guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/user/CreateOrUpdateUser"),
                      let payLoad = """
                {
                  "user": {
                    "name": "\(name)",
                    "surname": "\(name)",
                    "userName": "\(email)",
                    "emailAddress": "\(email)",
                    "password": "s@ng7nQ-ij",
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
                session.dataTask(with: request) { (data, response, error) in
                    
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
                    
                }.resume()
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    func checkToken(token: String, completion: @escaping (Swift.Result<UserData, ErrorMessage>) -> Void) {
        
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
        session.dataTask(with: request) { (data, response, error) in
            
            if let _ = error {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  response.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decodedData = try JSONDecoder().decode(UserProfile.self, from: data!)
                let user = decodedData.result.user
                let userData = UserData(name: user.name, familyName: user.surname, email: user.emailAddress, id: user.id, avatarImage: nil)
                UserDefaults.standard.setValue(user.id, forKey: "userId")
                DispatchQueue.main.async {
                    completion(.success(userData))
                }
            }
            catch {
                DispatchQueue.main.async {
                    completion(.failure(.invalidData))
                }
            }
        }.resume()
    }
}
