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
                guard let hits = results?.againDataHits.reduce(0,+) else {return}
                strongSelf.numOfCompletion[cardId] = hits
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

