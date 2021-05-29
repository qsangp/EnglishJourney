//
//  ViewController.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 25/05/2021.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var hiUser: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var greetView: UIView!
    @IBOutlet weak var greetMessage: UILabel!
    @IBOutlet weak var greetButton: UIButton!
    
    var cardViewModel: CardViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light

        initTableView()
        updataUI()
    }
    
    func updataUI() {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        greetView.layer.cornerRadius = 20
        greetMessage.text = "Chúng ta sẽ học gì hôm nay?"
        greetButton.layer.cornerRadius = 10
        
        cardViewModel = CardViewModel()
        cardViewModel.fetchFlashCards {
            self.tableView.reloadData()
        }
        if let accessToken = UserDefaults.standard.string(forKey: "accessToken") {
        cardViewModel.checkToken(token: accessToken) { userData in
            self.hiUser.text = "Chào \(userData?.userNameOrEmail ?? "bạn")"
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool){
           tableView.reloadData()
       }
    
    /// Init table view
    private func initTableView() {
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func profileButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "GoToProfile", sender: self)
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
            let selectedID = cardViewModel.flashcard[indexPath.row].id
            self.cardViewModel.flashcardData = [CardData]()
            self.cardViewModel.fetchFlashCardsData(id: selectedID) {
                let vc = self.storyboard?.instantiateViewController(identifier: "CardLesson") as! CardLessonVC
                vc.cardLesson = self.cardViewModel.flashcardData
                vc.temporaryCardLesson = self.cardViewModel.flashcardData
                self.present(vc, animated: true)
            }
            
        }
    
}


