//
//  ProfileTableViewCell.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 03/07/2021.
//

import UIKit
import Charts

class ProfileTableViewCell: UITableViewCell {
    
    let profileImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFill
        image.layer.borderWidth = 1.0
        image.layer.masksToBounds = false
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.cornerRadius = 30
        image.clipsToBounds = true
        return image
    }()
    
    let userNameLabel: UILabel = {
        let title = UILabel()
        title.text = ""
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        title.numberOfLines = 0
        return title
    }()
    
    var viewModel: CardViewModel!
    var againButtonDayCount = 0
    var completeButtonDayCount = 0
    
    let titleLable: UILabel = {
        let title = UILabel()
        title.text = "You haven't learned this month. Start now!"
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.textColor = .systemGray
        title.textAlignment = .center
        title.layer.borderWidth = 0.5
        title.layer.masksToBounds = false
        title.layer.borderColor = UIColor.systemGray.cgColor
        title.layer.cornerRadius = 10
        title.clipsToBounds = true
        return title
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(removeSubview), name: NSNotification.Name(rawValue: "PeformAfterUpdateChart"), object: nil)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        userNameLabel.text = ""
        profileImage.image = UIImage()
        for view in contentView.subviews {
            view.removeFromSuperview()
        }
    }
    
    func setupImage() {
        let userImageURL = UserDefaults.standard.url(forKey: "userImageURL")
        if let url = userImageURL {
            profileImage.kf.setImage(with: url)
        } else {
            profileImage.image = UIImage(named: "englishjourney")
        }
        contentView.addSubview(profileImage)
        profileImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15).isActive = true
        profileImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        profileImage.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profileImage.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profileImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15).isActive = true
        
        guard let userName = UserDefaults.standard.string(forKey: "userName")
        else {return}
        self.userNameLabel.text = """
                                \(userName)
                                """
        
        contentView.addSubview(userNameLabel)
        userNameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: profileImage.trailingAnchor, constant: 15).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
    }
    
    func createChart() {
        
        // Create bar chart
        let barChart = BarChartView()
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
        
        let date = Date()
        let formatterDay = DateFormatter()
        formatterDay.dateFormat = "dd"
        
        let set = BarChartDataSet(entries: entries, label: "You have learned \(againButtonDayCount) days. Keep going <3")
        set.colors = [NSUIColor(cgColor: UIColor(red: 0.00, green: 0.73, blue: 0.75, alpha: 1.00).cgColor)]
        set.drawValuesEnabled = false
        
        let set2 = BarChartDataSet(entries: entries2, label: "Again")
        set2.colors = [NSUIColor(cgColor: UIColor.systemRed.cgColor)]
        set2.drawValuesEnabled = false
        let data = BarChartData(dataSet: set)
        
        //            data.groupBars(fromX: 0, groupSpace: 0.3, barSpace: 0.03)
        
        barChart.xAxis.axisRange = 1
        
        if let currentDate = Int(formatterDay.string(from: date)) {
            if currentDate <= 15 {
                barChart.xAxis.axisMinimum = 1
                barChart.xAxis.axisMaximum = 15
            } else if currentDate > 15  {
                barChart.xAxis.axisMinimum = 16
                barChart.xAxis.axisMaximum = 30
            }
        }
        
        barChart.data = data
        
        contentView.addSubview(barChart)
        barChart.tag = 1
        barChart.translatesAutoresizingMaskIntoConstraints = false
        
        barChart.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        barChart.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        barChart.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        barChart.bottomAnchor.constraint(equalTo: contentView.bottomAnchor,constant: -15).isActive = true
        barChart.heightAnchor.constraint(equalToConstant: contentView.frame.width).isActive = true
    }
    
    func setupNoChartView() {
        contentView.addSubview(titleLable)
        titleLable.viewWithTag(1)
        titleLable.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        titleLable.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleLable.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15).isActive = true
        titleLable.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15).isActive = true
        titleLable.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        titleLable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
        titleLable.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    @objc func removeSubview() {
        if let viewToRemove = contentView.viewWithTag(1)  {
            viewToRemove.removeFromSuperview()
        } else {
            print("No subview to remove!")
        }
    }
    
}
