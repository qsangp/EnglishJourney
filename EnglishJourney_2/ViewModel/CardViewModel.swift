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
    
    // Service call API
    let service: Service!
    // Callback to view
    var needReloadTableView: (() -> Void)?
    var needReloadChart: (() -> Void)?
    var needShowError: ((ErrorMessage) -> Void)?

    // Datasource
    private var cardCateItems: [CardCateItems] = []
    private var cardData: [CardItems] = []
    private var chartData: ButtonDataSet?
    private var numOfLesson: [Int:Int] = [:]
    private var numOfCompletion: [Int:Int] = [:]
    
    init() {
        service = Service()
    } 
    
    func requestCard() {
        service.fetchFlashCards { [weak self] results in
            guard let strongSelf = self else { return }

            switch results {
            case .success(let results):
                strongSelf.cardCateItems = results ?? []
                strongSelf.needReloadTableView?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func requestChartData(cardId: Int) {
        service.fetchChartData(cardId: cardId) { [weak self] results in
            guard let strongSelf = self else { return }

            switch results {
            case .success(let results):
                strongSelf.chartData = results
                strongSelf.needReloadChart?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func requestChartDataCell(cardId: Int) {
        service.fetchChartData(cardId: cardId) { [weak self] results in
            guard let strongSelf = self else { return }

            switch results {
            case .success(let results):
                strongSelf.numOfCompletion[cardId] = results?.againDataHits.reduce(0,+) ?? 0 / strongSelf.numberOfLesson(cardId: cardId)
                strongSelf.needReloadTableView?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }

    
    func getDashboard(cardId: Int) {
        service.getInfoDashBoard(cardId: cardId) { [weak self] results in
            guard let strongSelf = self else { return }

            switch results {
            case .success(let results):
                guard let results = results else {return}
                strongSelf.numOfLesson[cardId] = results.total
                strongSelf.needReloadTableView?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func buttonDataHits() -> ButtonDataSet? {
        return chartData
    }
    
    func numberOfCompletion(cardId: Int) -> Int {
        return numOfCompletion[cardId] ?? 0
    }
    
    func numberOfLesson(cardId: Int) -> Int {
        return numOfLesson[cardId] ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return cardCateItems.count
    }
    
    func numberOfRowsInSectionLessons(parentId: Int, section: Int) -> Int {
        let items = cardCateItems.filter({$0.id == parentId})[0].items
        return items.count
    }

    func cellForRowAt(indexPath: IndexPath) -> CardCateItems {
        return cardCateItems[indexPath.row]
    }
    
    func cellForRowAtLessons(parentId: Int, indexPath: IndexPath) -> CardLessonItems {
        let items = cardCateItems.filter({$0.id == parentId})[0].items
        return items[indexPath.row]
    }
    
    
    //MARK: -User
    func createUser(name: String, surname: String, username: String, email: String, password: String, completion: @escaping (String?) -> ()) {
        
        requestToken { accessToken in
            
            guard let urlRequestUserLogIn = URL(string: "https://app.ielts-vuive.com/api/services/app/user/CreateOrUpdateUser"),
                  let payLoad = """
                {
                  "user": {
                    "name": "\(name)",
                    "surname": "\(surname)",
                    "userName": "\(name)",
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
                    self.userData = UserData(userName: user.name, userEmail: user.emailAddress, id: user.id)
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
                            self.cardCategory = self.cardCategory.sorted {$0.title < $1.title}
                            DispatchQueue.main.async {
                                completion(nil)
                            }
                        }
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
                    let date = Date()
                    let formatterMonth = DateFormatter()
                    formatterMonth.dateFormat = "MM"
                    let formatterYear = DateFormatter()
                    formatterYear.dateFormat = "yyyy"
                    let currentMonth = Int(formatterMonth.string(from: date))
                    let currentYear = Int(formatterYear.string(from: date))
                    let userId = UserDefaults.standard.integer(forKey: "userId")
                    for card in decodedData.result {
                        if card.parentId == parentId {
                            if let month = currentMonth, let year = currentYear {
                                self.fetchChartData(month: month, year: year, cateId: card.id, userId: userId) { buttonData in
                                    if let sumOfHits = buttonData?.againDataHits.reduce(0, +) {
                                        let numOfCompletion = sumOfHits / card.numOfLession
                                        self.flashcard.append(CardModel(title: card.title, numOfLesson: card.numOfLession, numOfCompletion: numOfCompletion, id: card.id))
                                        self.flashcard = self.flashcard.sorted {$0.title < $1.title}
                                        DispatchQueue.main.async {
                                            completion(nil)
                                        }
                                    }
                                }
                            }
                        }
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
    
    func fetchFlashCardsData(cateId: Int, userId: Int, completion: @escaping (Swift.Error?) -> ()) {
        
        let urlStringData = "https://app.ielts-vuive.com/api/services/app/flashCardLessionService/GetAllLessionsByCateId?id="
        
        let stringId = String(cateId)
        let userId = String(userId)
        let newUrl = "\(urlStringData)\(stringId)&userId=\(userId)"
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
                        
                        print("fetch chart data success: \(completeDataHits)")
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

