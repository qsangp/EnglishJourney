//
//  ChartVC.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 03/06/2021.
//

import UIKit
import Charts
import NVActivityIndicatorView

class ChartVC: UIViewController {
    
    var cardViewModel: CardViewModel!
    
    let activityIndicator: NVActivityIndicatorView = {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballPulse, color: UIColor(red: 0.58, green: 0.84, blue: 0.83, alpha: 1.00), padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        return loading
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        cardViewModel = CardViewModel()
        setUpAnimation()
        createChart()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setUpAnimation() {
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.widthAnchor.constraint(equalToConstant: 40),
            activityIndicator.heightAnchor.constraint(equalToConstant: 40)
        ])
        activityIndicator.stopAnimating()
    }
    
    private func createChart() {
        activityIndicator.startAnimating()
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
        barChart.rightAxis.enabled = false
        barChart.leftAxis.labelFont = UIFont.systemFont(ofSize: 16)
        barChart.leftAxis.drawAxisLineEnabled = false
        barChart.leftAxis.drawGridLinesEnabled = false
        
        // Configure the legend
        barChart.legend.font = UIFont(name: "Verdana", size: 16.0)!
        
        // Supply data
        var entries = [BarChartDataEntry]()
        var entries2 = [BarChartDataEntry]()
        entries = []
        entries2 = []
        
        let date = Date()
        let formatterMonth = DateFormatter()
        formatterMonth.dateFormat = "MM"
        let formatterYear = DateFormatter()
        formatterYear.dateFormat = "yyyy"
        let currentMonth = Int(formatterMonth.string(from: date))
        let currentYear = Int(formatterYear.string(from: date))
        let userId = UserDefaults.standard.integer(forKey: "userId")
        print("userid: \(userId)")
        if let month = currentMonth, let year = currentYear {
            print(month)
            print(year)
            self.cardViewModel.fetchChartData(month: month, year: year, cateId: 186, userId: userId) { buttonData in
                
                if let againButtonDataHits = buttonData?.againDataHits,
                   let completeButonDataHits = buttonData?.completeDataHits {
                    var dictionaryData = [Int: Int]()
                    var dictionaryData2 = [Int: Int]()
                    
                    for x in 1...againButtonDataHits.count {
                        dictionaryData[x] = againButtonDataHits[x - 1]
                    }
                    for x in 1...againButtonDataHits.count {
                        dictionaryData2[x] = completeButonDataHits[x - 1]
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
                    let data = BarChartData(dataSets: [set2, set])
                    
                    data.groupBars(fromX: 0, groupSpace: 0.3, barSpace: 0.03)
                    data.barWidth = 0.9
                    
                    barChart.xAxis.axisMinimum = 1
                    barChart.xAxis.axisRange = 1
                    barChart.xAxis.axisMaximum = 30
                    
                    barChart.data = data
                    
                    set.notifyDataSetChanged()
                    set2.notifyDataSetChanged()
                    data.notifyDataChanged()
                    barChart.notifyDataSetChanged()
                    
                    self.view.addSubview(barChart)
                    barChart.center = self.view.center
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
}

