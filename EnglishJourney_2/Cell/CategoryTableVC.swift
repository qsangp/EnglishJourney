////
////  CategoryTableVC.swift
////  EnglishJourney_2
////
////  Created by ielts-vuive on 14/06/2021.
////
//
//import UIKit
//import MarkdownKit
//
//protocol CategoryTableVCDelegate {
//    func callSegueFromCell(cards: [CardData])
//}
//
//class CategoryTableVC: UITableViewCell {
//    @IBOutlet weak var cell_image: UIImageView!
//    @IBOutlet weak var cell_left_label: UILabel!
//
//    @IBOutlet weak var rightButon: UIButton!
//    @IBOutlet weak var text_view: UITextView!
//    
//    var delegate: CategoryTableVCDelegate!
//    let service = Service()
//    var viewModel: CardViewModel!
//    var data: CardCategory!
//    var cardIdReview: [Int]?
//    
//    let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 14))
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        rightButon.layer.cornerRadius = 5
//        rightButon.backgroundColor = UIColor.systemBlue
//        text_view.isUserInteractionEnabled = false
//        viewModel = CardViewModel()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }
//    
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        cell_image.image = nil
//        cell_left_label.text = ""
//        text_view.text = ""
//    }
//    
//    func bindData(data: CardCategory) {
//        self.data = data
////        cell_left_label.text = "\(data.title.localizedCapitalized) - \(data.items.count - 1) lessons"
//        cell_left_label.font = UIFont.boldSystemFont(ofSize: 16)
//        cell_left_label.textColor = UIColor.systemBlue
//        
//        service.fetchFlashCardsData(cardId: data.items[0].id) { [weak self] results in
//            
//            switch results {
//            case .success(let results):
//                if let info = results?[0].description.htmlAttributedString(fontSize: 14) {
//                    
//                    self?.text_view.attributedText = self?.markdownParser.parse(info)
//                }
//                if let urlFile = results?[0].imageURL {
//                    let url = URL(string: "https://app.ielts-vuive.com\(urlFile)?v=")
//                    self?.cell_image.kf.setImage(with: url)
//                    self?.cell_image.contentMode = .scaleAspectFill
//                    self?.cell_image.layer.borderWidth = 1.0
//                    self?.cell_image.layer.masksToBounds = false
//                    self?.cell_image.layer.borderColor = UIColor.white.cgColor
//                    self?.cell_image.layer.cornerRadius = 10
//                    self?.cell_image.clipsToBounds = true
//                }
//            case .failure(_):
//                DispatchQueue.main.async {
//                    self?.text_view.text = ""
//                    self?.cell_left_label.text = ""
//                }
//            }
//        }
//    }
//    
//    @IBAction func rightButton(_ sender: UIButton) {
//        data.items.removeFirst()
//        guard let randomId = data.items.randomElement()?.id else {return}
//        service.fetchFlashCardsData(cardId: randomId) { [weak self] results in
//            switch results {
//            case .success(let results):
//                if let results = results {
//                    if self?.delegate != nil { //Just to be safe.
//                        self?.delegate.callSegueFromCell(cards: results)
//                    }
//                }
//            case .failure(let error):
//                print(error)
//            }
//        }
//    }
//}
