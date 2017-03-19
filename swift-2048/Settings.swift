//
//  Settings.swift
//  swift-2048
//
//  Created by Xhevi on 18/03/2017.
//  Copyright © 2017 Xhevi Qafmolla. All rights reserved.
//

import Foundation

class Settings {
    var gameTime: Int
    var gameTimeText: String
    let deviceType: String = ".phone"
    init(gameTime: Int, gameTimeText: String) {
        self.gameTime = gameTime
        self.gameTimeText = gameTimeText
    }
    
    
    
}
var gameSettings = Settings(gameTime: 600, gameTimeText: "10:00")


