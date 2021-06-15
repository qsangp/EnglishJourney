//
//  CardViewModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation

class CardViewModel {
    
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
    private var numOfCompletionMonth: [Int:Int] = [:]
    private var numOfCompletionToday: [Int:Int] = [:]
    
    private var cardIdLearned: [Int] = []
    private var userLearnedToday = false

    
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
                guard let hits = results?.againDataHits else {return}
                strongSelf.numOfCompletionMonth[cardId] = hits.reduce(0,+)
                
                let date = Date()
                let formatterDay = DateFormatter()
                formatterDay.dateFormat = "dd"
                
                if let currentDay = Int(formatterDay.string(from: date)) {
                    strongSelf.numOfCompletionToday[cardId] = hits[currentDay - 1]
                    if hits[currentDay - 1] == 0 {
                        strongSelf.cardIdLearned.append(cardId)
                    }
                }
                strongSelf.needReloadTableView?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func getCardIdLearned() -> [Int] {
        cardIdLearned = cardIdLearned.uniqued()
        return cardIdLearned
    }
    
    func userHasLearnedToday() -> Bool {
        if !cardIdLearned.isEmpty {
            userLearnedToday = true
            cardIdLearned = cardIdLearned.uniqued()
        } 
        return userLearnedToday
    }
    
    func buttonDataHits() -> ButtonDataSet? {
        return chartData
    }
    
    func numberOfCompletionMonth(cardId: Int) -> Int {
        return numOfCompletionMonth[cardId] ?? 0
    }
    
    func numberOfCompletionToday(cardId: Int) -> Int {
        return numOfCompletionToday[cardId] ?? 0 
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
}

