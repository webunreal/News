//
//  UserDefaultsService.swift
//  News
//
//  Created by Nikolai Ivanov on 26.02.2021.
//

import Foundation

public struct UserDefaultsService {
    private let userDefaults = UserDefaults.standard
    
    init() {
        userDefaults.set("us", forKey: "selectedCountry")
        userDefaults.set("General", forKey: "selectedCategory")
    }
    
    public func setCountry(country: String) {
        userDefaults.set(country, forKey: "selectedCountry")
    }
    
    public func getCountry() -> String {
        userDefaults.string(forKey: "selectedCountry") ?? ""
    }
}
