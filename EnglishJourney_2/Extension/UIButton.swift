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

extension UIView {

/**
 Simply zooming in of a view: set view scale to 0 and zoom to Identity on 'duration' time interval.

 - parameter duration: animation duration
 */
func zoomIn(duration: TimeInterval = 0.2) {
    self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
    UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
        self.transform = .identity
        }) { (animationCompleted: Bool) -> Void in
    }
}

/**
 Simply zooming out of a view: set view scale to Identity and zoom out to 0 on 'duration' time interval.

 - parameter duration: animation duration
 */
func zoomOut(duration : TimeInterval = 0.2) {
    self.transform = .identity
    UIView.animate(withDuration: duration, delay: 0.0, options: [.curveLinear], animations: { () -> Void in
        self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        }) { (animationCompleted: Bool) -> Void in
    }
}

/**
 Zoom in any view with specified offset magnification.

 - parameter duration:     animation duration.
 - parameter easingOffset: easing offset.
 */
func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
    let easeScale = 1.0 + easingOffset
    let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
    let scalingDuration = duration - easingDuration
    UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
        self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = .identity
                }, completion: { (completed: Bool) -> Void in
            })
    })
}

/**
 Zoom out any view with specified offset magnification.

 - parameter duration:     animation duration.
 - parameter easingOffset: easing offset.
 */
func zoomOutWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
    let easeScale = 1.0 + easingOffset
    let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
    let scalingDuration = duration - easingDuration
    UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
        self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
                }, completion: { (completed: Bool) -> Void in
            })
    })
}

}
