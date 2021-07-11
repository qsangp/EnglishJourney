//
//  LessonVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 11/07/2021.
//

import UIKit

class LessonVC: UIViewController {

    var viewModel: CardViewModel!
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "MyTableViewCell")
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = UITableViewCell.SeparatorStyle.none
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        let title = UserDefaults.standard.string(forKey: "currentParentTitle")
        navigationItem.title = title?.localizedCapitalized
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setNavigationBarHidden(false, animated: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(bindViewModel), name: NSNotification.Name(rawValue: "userCompleteCard"), object: nil)
    }

    @objc func bindViewModel() {
        let cardId = UserDefaults.standard.integer(forKey: "currentParentId")
        viewModel.requestLessons(parentId: cardId)
        viewModel.needPerformAction = { [weak self] in
            self?.tableView.reloadData()
        }
    }
}

extension LessonVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCardCategoryItems().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = viewModel.getCardCategoryItems()[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyTableViewCell") as! MyTableViewCell
        cell.viewModel = viewModel
        cell.bindData(data: data)
        cell.setupLessonCell()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 0
        } else {
            return 120
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = viewModel.getCardCategoryItems()[indexPath.row]
        viewModel.saveCurrentCardId(cardId: data.id)
        self.performSegue(withIdentifier: "showCardLessonVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showCardLessonVC" {
            if let destVC = segue.destination as? UINavigationController,
                let targetController = destVC.topViewController as? CardLessonVC {
                destVC.modalPresentationStyle = .fullScreen
                targetController.viewModel = viewModel
            }
        }
    }
}
