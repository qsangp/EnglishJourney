//
//  Array.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 15/06/2021.
//

import Foundation

extension Array where Element: Hashable {
    func uniqued() -> Array {
        var buffer = Array()
        var added = Set<Element>()
        for elem in self {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }
}
