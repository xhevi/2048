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
    init(gameTime: Int, gameTimeText: String) {
        self.gameTime = gameTime
        self.gameTimeText = gameTimeText
    }
}
var gameSettings = Settings(gameTime: 10, gameTimeText: "0:10")
