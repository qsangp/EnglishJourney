//
//  UserDefault.swift
//  EnglishJourney_2
//
//  Created by ielts-vuive on 04/06/2021.
//

import Foundation

func resetDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
    }
}
