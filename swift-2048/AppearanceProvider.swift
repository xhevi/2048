//
//  AppearanceProvider.swift
//  swift-2048
//
//  Created by Xhevi on 17/03/2017.
//  Copyright (c) 2017 Xhevi Qafmolla. Released under the terms of the MIT license.
//

import UIKit

protocol AppearanceProviderProtocol: class {
  func tileColor(_ value: Int) -> UIColor
  func numberColor(_ value: Int) -> UIColor
  func fontForNumbers() -> UIFont
}

class AppearanceProvider: AppearanceProviderProtocol {

  // Tiles are transparent
  func tileColor(_ value: Int) -> UIColor {
        return UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0)
  }

  // Provide a numeral color for a given value
  func numberColor(_ value: Int) -> UIColor {
        switch value {
        case 2:
          return UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 1.0)
        case 4:
          return UIColor(red: 66.0/255.0, green: 66.0/255.0, blue: 66.0/255.0, alpha: 1.0)
        case 8:
          return UIColor(red: 87.0/255.0, green: 87.0/255.0, blue: 87.0/255.0, alpha: 1.0)
        case 16:
          return UIColor(red: 108.0/255.0, green: 108.0/255.0, blue: 108.0/255.0, alpha: 1.0)
        case 32:
          return UIColor(red: 129.0/255.0, green: 129.0/255.0, blue: 129.0/255.0, alpha: 1.0)
        case 64:
          return UIColor(red: 150.0/255.0, green: 150.0/255.0, blue: 150.0/255.0, alpha: 1.0)
        case 128:
            return UIColor(red: 171.0/255.0, green: 171.0/255.0, blue: 171.0/255.0, alpha: 1.0)
        case 256:
            return UIColor(red: 192.0/255.0, green: 192.0/255.0, blue: 192.0/255.0, alpha: 1.0)
        case 512:
            return UIColor(red: 213.0/255.0, green: 213.0/255.0, blue: 213.0/255.0, alpha: 1.0)
        case 1024:
            return UIColor(red: 234.0/255.0, green: 234.0/255.0, blue: 234.0/255.0, alpha: 1.0)
        case 2048:
            return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        default:
          return UIColor.black
        }
  }

  // Provide the font to be used on the number tiles
  func fontForNumbers() -> UIFont {
    if let font = UIFont(name: "SFUIDisplay-Black", size: 27) {
        return font
    }
    return UIFont.systemFont(ofSize: 27)
  }
}
