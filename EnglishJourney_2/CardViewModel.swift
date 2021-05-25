//
//  CardViewModel.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import Foundation


class CardViewModel {
    var flashcard = [CardModel]()
    
    let urlString = URL(string:"https://app.ielts-vuive.com/api/services/app/flashCardCategorieService/GetAllCategories")
    
    func fetchFlashCards(completion: @escaping () -> ()) {
        
        var request = URLRequest(url: urlString!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession(configuration: .default)
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error == nil {
                do {
                    let decodedData = try JSONDecoder().decode(FlashCard.self, from: data!)
                    for card in decodedData.result {
                        if card.parentId == 186 {
                            self.flashcard.append(CardModel(title: card.title, numOfLesson: card.numOfLession))
                        }
                    }
                    DispatchQueue.main.async {
                        completion()
                    }
                }
                catch {
                    print(error)
                }
            }
            
        }
        task.resume()
        
    }
    
}
