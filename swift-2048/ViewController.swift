//
//  ViewController.swift
//  swift-2048
//
//  Created by Xhevi on 17/03/2017.
//  Copyright (c) 2017 Xhevi Qafmolla. Released under the terms of the MIT license.
//

import UIKit

class ViewController: UIViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()

  }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // Load immediately game with default settings
    override func viewDidAppear(_ animated: Bool) {
        let game = NumberTileGameViewController(dimension: 4, threshold: 2048)
        self.present(game, animated: true, completion: nil)
        
    }
   
   

}

