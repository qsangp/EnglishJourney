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
    
    private var instructionImages: [Instruction]
    
    init() {
        service = Service()
        
        instructionImages = []
        
        instructionImages.append(Instruction(name: "Chọn danh mục muốn học", image: "HD_1"))
        instructionImages.append(Instruction(name: "Quá trình học của bạn sẽ được app ghi nhận, càng siêng năng bạn sẽ càng được thưởng nhiều sao.", image: "HD_2"))
        instructionImages.append(Instruction(name: "Khi chọn một topic, bài học sẽ tự động phát câu hỏi.", image: "HD_3"))
        instructionImages.append(Instruction(name: "Các bạn sẽ mở Sample ra, bấm nút play để nghe phần mẫu và đọc lại, sau khi đọc xong bấm Again (câu được bấm Again sẽ được lưu lại để chúng ta thực hành trả lời).", image: "HD_4"))
        instructionImages.append(Instruction(name: "Sang câu tiếp theo và chúng ta lại nghe câu hỏi → mở sample nghe và luyện đọc theo → bấm Again.", image: "HD_5"))
        instructionImages.append(Instruction(name: "Sau khi hết 1 lượt, câu hỏi đầu tiên sẽ quay lại → chúng ta sẽ nghe câu hỏi và thực hành trả lời (các bạn có thể bấm thu âm lại phần trả lời để so sánh với bài mẫu). \nNếu trả lời thành công → bấm Done \nNếu không thành công → mở sample luyện đọc lại → bấm Again.", image: "HD_6"))
        instructionImages.append(Instruction(name: "Lặp lại các bước luyện tập, sau khi hoàn thành các bạn sẽ nhận một chiếc cup vàng :D", image: "HD_7"))
        instructionImages.append(Instruction(name: "Các bạn có thể thử thách trả lời random câu hỏi bằng cách bấm nút random ở màn hình chọn bài.", image: "HD_8"))
        instructionImages.append(Instruction(name: "Phần hướng dẫn đến đây là hết rồi, chúc các bạn luyện tập vui vẻ :D", image: "HD_1"))

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
                    if hits[currentDay - 1] == 0 && hits.reduce(0,+) < 5 {
                        strongSelf.cardIdLearned.append(cardId)
                    }
                }
                strongSelf.needReloadTableView?()
            case .failure(let error):
                strongSelf.needShowError?(error)
            }
        }
    }
    
    func getInstruction() -> [Instruction] {
        return instructionImages
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

