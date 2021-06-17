//
//  ChartVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 03/06/2021.
//

import UIKit
import Charts

class ChartVC: UIViewController {
    
    var viewModel: CardViewModel!
    var againButtonDayCount = 0
    var completeButtonDayCount = 0
    
    let popUpMessageLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.label
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.masksToBounds = true
        return label
    }()
    
    deinit {
        print("Chart VC has no retain cycle")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        bindViewModel()
        createChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        removeSubview()
        viewModel.needReloadChart = { [weak self] in
            self?.createChart()
        }
        viewModel.needShowError = { [weak self] error in
            self?.showError(error: error)
        }
        let cardParentId = UserDefaults.standard.integer(forKey: "cardParentId")
        viewModel.requestChartData(cardId: cardParentId)
    }
    
    private func bindViewModel() {
        viewModel = CardViewModel()
    }
    
    private func showError(error: ErrorMessage) {
        let alert = UIAlertController(title: "Error", message: error.rawValue, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func createChart() {
        let userName = UserDefaults.standard.string(forKey: "userName")
        if let title = UserDefaults.standard.string(forKey: "currentCardTitle") {
            // Create bar chart
            let barChart = BarChartView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.width))
            barChart.notifyDataSetChanged()
            barChart.isUserInteractionEnabled = false
            barChart.drawBarShadowEnabled = false
            barChart.drawValueAboveBarEnabled = false
            barChart.drawGridBackgroundEnabled = false
            
            // Configure the axis
            barChart.xAxis.labelPosition = .bottom
            barChart.xAxis.drawGridLinesEnabled = false
            barChart.xAxis.drawAxisLineEnabled = false
            barChart.xAxis.drawLabelsEnabled = false
            barChart.xAxis.labelFont = UIFont.systemFont(ofSize: 16)
            barChart.xAxis.labelTextColor = UIColor.label
            barChart.rightAxis.enabled = false
            barChart.leftAxis.labelFont = UIFont.systemFont(ofSize: 16)
            barChart.leftAxis.labelTextColor = UIColor.label
            barChart.leftAxis.drawAxisLineEnabled = false
            barChart.leftAxis.drawGridLinesEnabled = false
            
            // Configure the legend
            barChart.legend.font = UIFont.systemFont(ofSize: 16)
            
            // Supply data
            var entries = [BarChartDataEntry]()
            var entries2 = [BarChartDataEntry]()
            entries = []
            entries2 = []
            
            guard let buttonData = viewModel.buttonDataHits() else {return}
            let againButtonDataHits = buttonData.againDataHits
            let completeButonDataHits = buttonData.completeDataHits
            
            var dictionaryData = [Int: Int]()
            var dictionaryData2 = [Int: Int]()
            againButtonDayCount = 0
            completeButtonDayCount = 0
            for x in 1...againButtonDataHits.count {
                dictionaryData[x] = againButtonDataHits[x - 1]
                if againButtonDataHits[x - 1] != 0 {
                    againButtonDayCount += 1
                }
            }
            for x in 1...againButtonDataHits.count {
                dictionaryData2[x] = completeButonDataHits[x - 1]
                if completeButonDataHits[x - 1] != 0 {
                    completeButtonDayCount += 1
                }
            }
            for (x,y) in dictionaryData.sorted(by: <) {
                entries.append(BarChartDataEntry(x: Double(x), y: Double(y)))
            }
            for (x,y) in dictionaryData2.sorted(by: <) {
                entries2.append(BarChartDataEntry(x: Double(x), y: Double(y)))
            }
            print(entries)
            let set = BarChartDataSet(entries: entries, label: "Complete")
            set.colors = [NSUIColor(cgColor: UIColor.systemBlue.cgColor)]
            set.drawValuesEnabled = false
            
            let set2 = BarChartDataSet(entries: entries2, label: "Again")
            set2.colors = [NSUIColor(cgColor: UIColor.systemRed.cgColor)]
            set2.drawValuesEnabled = false
            let data = BarChartData(dataSet: set)
            
//            data.groupBars(fromX: 0, groupSpace: 0.3, barSpace: 0.03)
//            data.barWidth = 0.9
            
            barChart.xAxis.axisMinimum = 1
            barChart.xAxis.axisRange = 1
            barChart.xAxis.axisMaximum = 30
            
            barChart.data = data
                        
            barChart.setNeedsDisplay()
            
            view.addSubview(barChart)
            barChart.tag = 1
            barChart.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                barChart.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                barChart.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 5),
                barChart.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 5),
                barChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
            ])
            
            if againButtonDayCount != 0 ||  completeButtonDayCount != 0 {
                popUpMessageLabel.text = "\(userName ?? "") ơi, bạn đã luyện \(title) được \( againButtonDayCount) ngày tháng này rồi. \nGiữ vững tiến độ nhé!"
                view.addSubview( popUpMessageLabel)
                
                popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    popUpMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    popUpMessageLabel.widthAnchor.constraint(equalToConstant: 300),
                    popUpMessageLabel.topAnchor.constraint(equalTo: barChart.bottomAnchor, constant: 10),
                    popUpMessageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150)
                ])
                
            } else {
                popUpMessageLabel.text = "\(userName ?? "") ơi, bạn chưa luyện \(title) tháng này. \nBắt tay vào luyện ngay thôi nào!"
                view.addSubview( popUpMessageLabel)
                
                popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    popUpMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    popUpMessageLabel.widthAnchor.constraint(equalToConstant: 300),
                    popUpMessageLabel.topAnchor.constraint(equalTo: barChart.bottomAnchor, constant: 10),
                    popUpMessageLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150)
                ])
            }
        } else {
            // User chưa chọn lesson
            popUpMessageLabel.text = "\(userName ?? "") ơi, vào bài học chọn bài để hiện tiến độ nhé!"
            view.addSubview( popUpMessageLabel)
            popUpMessageLabel.tag = 1
            popUpMessageLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                popUpMessageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                popUpMessageLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                popUpMessageLabel.widthAnchor.constraint(equalToConstant: 300)
            ])
        }
    }
    
    func removeSubview() {
        if let viewToRemove =  view.viewWithTag(1)  {
            viewToRemove.removeFromSuperview()
        } else {
            print("No subview to remove!")
        }
    }
}

