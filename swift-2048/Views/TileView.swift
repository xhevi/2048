//
//  TileView.swift
//  swift-2048
//
//  Created by Xhevi on 17/03/2017.
//  Copyright (c) 2017 Xhevi Qafmolla. Released under the terms of the MIT license.
//

import UIKit

/// A view representing a single swift-2048 tile.
class TileView : UIView {
  var value : Int = 0 {
    didSet {
      backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
      numberLabel.text = "\(value)"
    }
  }

  unowned let delegate : AppearanceProviderProtocol
  let numberLabel : UILabel

  required init(coder: NSCoder) {
    fatalError("NSCoding not supported")
  }
    
  init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: AppearanceProviderProtocol) {
    delegate = d
    numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
    numberLabel.textAlignment = NSTextAlignment.center
    if #available(iOS 8.2, *) {
        numberLabel.font = UIFont.systemFont(ofSize: 25, weight: UIFontWeightBlack)
    } else {
        // Fallback on earlier versions
        numberLabel.font = UIFont.systemFont(ofSize: 28)
    }
    
    super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
    addSubview(numberLabel)
    layer.cornerRadius = radius

    self.value = value
    backgroundColor = delegate.tileColor(value)
    numberLabel.textColor = delegate.numberColor(value)
    numberLabel.text = "\(value)"
  }
}
