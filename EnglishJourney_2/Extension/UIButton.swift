//
//  UIButton.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 30/05/2021.
//

import Foundation
import UIKit

extension UIButton {
    func preventRepeatedPresses(inNext seconds: Double = 1) {
        self.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            self.isUserInteractionEnabled = true
        }
    }
    
    func getURL2(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
          guard
            let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
            let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
            let data = data, error == nil,
            let image = UIImage(data: data),
            httpURLResponse.url == url
            else { return }
          DispatchQueue.main.async() {
            self.setImage(image, for: .normal)
            self.imageView?.contentMode = .scaleAspectFit
            //self.image = image
          }
          }.resume()
      }

    public func downloadedFrom2(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        getURL2(url: url, contentMode: mode)

      }
}


