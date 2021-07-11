//
//  CardViewModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation
import Kingfisher

class CardViewModel {
    
    // Service call API
    let service: Service!
    
    // Callback to view
    var needPerformAction: (() -> Void)?
    var needShowError: ((ErrorMessage) -> Void)?
    
    // Datasource
    private var userData: UserData?
    
    private var cardCategory: [CardCategory] = []
    private var cardItemsDescription: [Int:String] = [:]

    private var cardCategoryItems: [CardCategoryItems] = []
    private var chartData: ButtonDataSet?
    
    private var cardData: [Int: [CardData]] = [:]
    private var cardThumbnailImage: [Int:URL] = [:]
    private var numOfCompletionMonth: [Int:Int] = [:]
    
    private var cardCategoryTitle: String = ""
    private var cardCategoryId: Int = 0
    private var cardCategoryItemId: Int = 0
    
    private var cardToReview: [Int:CardCategoryItems] = [:]
    private var cardToReviewId: [Int:Date] = [:]


    init() {
        service = Service()
    } 
    
    func requestCategory() {
        service.fetchFlashCards { [weak self] results in
            guard let strongSelf = self else { return }
            
            switch results {
            case .success(let results):
                strongSelf.cardCategory = results ?? []
                for card in strongSelf.cardCategory {
                    strongSelf.requestLessons(parentId: card.id)
                    strongSelf.requestChartDataTotal()
                }
                strongSelf.needPerformAction?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func requestCardData(cardId: Int) {
        service.fetchFlashCardsData(cardId: cardId) { [weak self] results in
            guard let strongSelf = self else { return }
            
            switch results {
            case .success(let results):
                strongSelf.cardData[cardId] = results ?? []
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PeformAfterLoadingData"), object: nil)
                strongSelf.needPerformAction?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func requestChartDataTotal() {
        service.fetchChartDataTotal() { [weak self] results in
            guard let strongSelf = self else { return }
            switch results {
            case .success(let results):
                strongSelf.chartData = results
                strongSelf.needPerformAction?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func requestChartDataCell(cardId: Int) {
        service.fetchChartDataCard(cardId: cardId) { [weak self] results in
            guard let strongSelf = self else { return }
            
            switch results {
            case .success(let results):
                guard let hits = results?.againDataHits else {return}
                strongSelf.numOfCompletionMonth[cardId] = hits.reduce(0,+)
                strongSelf.needPerformAction?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func requestLessons(parentId: Int) {
        let items = cardCategory.filter({$0.id == parentId})[0].items
        cardCategoryItems = items.map({ card in
            var card = card
            requestChartDataCell(cardId: card.id)
            requestCardData(cardId: card.id)
            card.imageURL = self.cardThumbnailImage[card.id]
            return card
        })
    }
    
    func writeLogButton( _ button: ButtonName) {
        let currentCardId = getCurrentCardId()
        service.writeLogButtonHits(buttonName: button.rawValue, cardId: currentCardId) { results in
            switch results {
            case .success(let results):
                print("cardId: \(currentCardId) write log \(button.rawValue) button: \(results)")
            case .failure(let error):
                print("fail to write log button \(error.localizedDescription)")
            }
        }
    }
    
    func saveUserData(name: String, familyName: String, email: String, id: Int, avatarImage: URL) {
        self.userData = UserData(name: name, familyName: familyName, email: email, id: id, avatarImage: avatarImage)
    }
    
    func saveCurrentCategoryTitle(_ title: String) {
        self.cardCategoryTitle = title
    }
    
    func saveCurrentCategoryId(categoryId: Int) {
        self.cardCategoryId = categoryId
    }
    
    func saveCurrentCardId(cardId: Int) {
        self.cardCategoryItemId = cardId
    }
    
    func saveCardThumbnailImage(cardId: Int, url: URL) {
        self.cardThumbnailImage[cardId] = url
    }
    
    func saveCardToReview(cardId: Int, time: Date) {
        cardToReviewId[cardId] = time
    }
    
    func buttonDataHits() -> ButtonDataSet? {
        return chartData
    }
    
    func numberOfCompletionMonth(cardId: Int) -> Int {
        return numOfCompletionMonth[cardId] ?? 0
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return cardCategory.count
    }
    
    func cellForRowAt(indexPath: IndexPath) -> CardCategory {
        return cardCategory[indexPath.row]
    }
    
    func getCardCategory() -> [CardCategory] {
        cardCategory = cardCategory.map({ card in
            var card = card
            card.imageURL = cardThumbnailImage[card.id]
            return card
        })
        return cardCategory
    }
    
    func getCardCategoryItems() -> [CardCategoryItems] {
        return cardCategoryItems
    }
    
    func getCardData(cardId: Int) -> [CardData] {
        return cardData[cardId] ?? []
    }
    
    func getCurrentCardId() -> Int {
        return cardCategoryItemId
    }
    
    func getCurrentCategoryId() -> Int {
        return cardCategoryId
    }
    
    func getCurrentCategoryTitle() -> String {
        return cardCategoryTitle
    }
    
    func getCardToReview() -> [CardCategoryItems] {
        var results: [CardCategoryItems] = []
        for (id,logTime) in cardToReviewId {
            cardCategoryItems = cardCategoryItems.map({ card in
                var card = card
                if card.id == id {
                    card.logTime = logTime
                    cardToReview[id] = card
                }
                return card
            })
        }
        for (_, card) in cardToReview {
            results.append(card)
        }
        return results.sorted(by: {$0.logTime! < $1.logTime!})
    }
    
    func removeCardToReview(cardId: Int) {
        cardToReview.removeValue(forKey: cardId)
        cardToReviewId.removeValue(forKey: cardId)
    }
    
    func getCardLog(cardId: Int) -> Date? {
        return cardToReviewId[cardId]
    }
}

