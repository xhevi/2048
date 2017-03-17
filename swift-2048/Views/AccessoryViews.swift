//
//  AccessoryViews.swift
//  swift-2048
//
//  Created by Xhevi on 17/03/2017.
//  Copyright (c) 2017 Xhevi Qafmolla. Released under the terms of the MIT license.
//

import UIKit


// A simple view to display buttons for controlling the app
class ControlView {
    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
    init () {
        button.backgroundColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.5)
        button.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
//        addSubview(button)
    }
    @objc func resetButtonTapped() {
        print("Button pressed")
    }
}
