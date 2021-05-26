//
//  ViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greetView: UIView!
    @IBOutlet weak var greetMessage: UILabel!
    @IBOutlet weak var greetButton: UIButton!
    
    var cardViewModel: CardViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        greetView.backgroundColor = UIColor(red: 0.98, green: 0.74, blue: 0.35, alpha: 1.00)
        greetView.layer.cornerRadius = 10
        greetMessage.text = "Chúng ta sẽ học gì hôm nay?"
        greetButton.layer.cornerRadius = 10
        greetButton.backgroundColor = UIColor(red: 0.96, green: 0.48, blue: 0.19, alpha: 1.00)

        initTableView()
        cardViewModel = CardViewModel()
        cardViewModel.fetchFlashCards {
            self.tableView.reloadData()
        }
    }
    
    /// Init table view
    private func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }

}
    

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return cardViewModel.flashcard.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let card = cardViewModel.flashcard[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
            
            cell.titleLabel.text = card.title
            cell.numberLabel.text = "Number of Lesson: \(card.numOfLesson)"
            
            return cell
        }

        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 120
        }
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if cardViewModel.flashcard[indexPath.row].id == 58 {
                self.performSegue(withIdentifier: "GoToCardData", sender: self)
            }
        }
    
}


