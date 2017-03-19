//
//  NumberTileGame.swift
//  swift-2048
//
//  Created by Xhevi on 17/03/2017.
//  Copyright (c) 2017 Xhevi Qafmolla. Released under the terms of the MIT license.
//

import UIKit

/// A view controller representing the swift-2048 game. It serves mostly to tie a GameModel and a GameboardView
/// together. Data flow works as follows: user input reaches the view controller and is forwarded to the model. Move
/// orders calculated by the model are returned to the view controller and forwarded to the gameboard view, which
/// performs any animations to update its state.
class NumberTileGameViewController : UIViewController, GameModelProtocol {
  // How many tiles in both directions the gameboard contains
  var dimension: Int
  // The value of the winning tile
  var threshold: Int
    
  // Holding game state before gameover
    var gameover: Bool = false

  var board: GameboardView?
  var model: GameModel?

  // Default width of the gameboard
  let boardWidth: CGFloat = 375.0
  // How much padding to place between the tiles
  let defaultPadding: CGFloat = 0.0

  // Amount of space to place between the different component views (gameboard, etc.)
  let viewPadding: CGFloat = 10.0

  // Amount that the vertical alignment of the component views should differ from if they were centered
  let verticalViewOffset: CGFloat = 0.0

  init(dimension d: Int, threshold t: Int) {
    dimension = d > 2 ? d : 2
    threshold = t > 8 ? t : 8
    super.init(nibName: nil, bundle: nil)
    model = GameModel(dimension: dimension, threshold: threshold, delegate: self)
    view.backgroundColor = UIColor.black
    setupSwipeControls()
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  func setupSwipeControls() {
    let upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.upCommand(_:)))
    upSwipe.numberOfTouchesRequired = 1
    upSwipe.direction = UISwipeGestureRecognizerDirection.up
    view.addGestureRecognizer(upSwipe)

    let downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.downCommand(_:)))
    downSwipe.numberOfTouchesRequired = 1
    downSwipe.direction = UISwipeGestureRecognizerDirection.down
    view.addGestureRecognizer(downSwipe)

    let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.leftCommand(_:)))
    leftSwipe.numberOfTouchesRequired = 1
    leftSwipe.direction = UISwipeGestureRecognizerDirection.left
    view.addGestureRecognizer(leftSwipe)

    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(NumberTileGameViewController.rightCommand(_:)))
    rightSwipe.numberOfTouchesRequired = 1
    rightSwipe.direction = UISwipeGestureRecognizerDirection.right
    view.addGestureRecognizer(rightSwipe)
  }


  // View Controller
  override func viewDidLoad()  {
    super.viewDidLoad()
    setupGame()
  }

  func reset() {
    assert(board != nil && model != nil)
    let b = board!
    let m = model!
    gameover = false
    b.reset()
    m.reset()
    m.insertTileAtRandomLocation(withValue: 2)
    m.insertTileAtRandomLocation(withValue: 2)
    timer.invalidate()
    time = gameSettings.gameTime
    timerLabel.text = gameSettings.gameTimeText
    runTimer()
    resetButton.setTitleColor(UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6), for: .normal)
    timerLabel.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6)
    hideScreenshotButton()
  }
    
    
    // Reset button
    let resetButton = UIButton(frame: CGRect(x: 0, y: 0, width: 90, height: 50))
    
    
    
    // Countdown timer
    var time = gameSettings.gameTime
    var timer = Timer()
    let timerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 110, height: 30))
    func updateTimer() {
        time -= 1
        if (time == 0) {
            gameover = true
            timer.invalidate()
            showScreenshotButton()
            timerLabel.text = "time's up"
            timerLabel.textColor = UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6)
            self.followUpLost(msg: "time's up")
            return
        }
        timerLabel.text = timeString(time: TimeInterval(time))
    }
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%i:%02i", minutes, seconds)
    }
    
    // Function to display screenshot button on gameover
    let screenshotButton = UIButton(frame: CGRect(x: 0, y: 0, width: 130, height: 50))


    
    func showScreenshotButton() {
        screenshotButton.isHidden = false
        screenshotButton.isUserInteractionEnabled = true
        screenshotButton.titleLabel?.adjustsFontSizeToFitWidth = true;
        screenshotButton.frame.origin.x = resetButton.frame.origin.x-screenshotButton.frame.width+20 // there is 10pt padding
        screenshotButton.frame.origin.y = resetButton.frame.origin.y
        screenshotButton.contentEdgeInsets = UIEdgeInsetsMake(20,10,0,10)
        screenshotButton.setTitle("screenshot", for: .normal)
        screenshotButton.setTitle("saved!", for: .highlighted)
        screenshotButton.titleLabel?.textAlignment = .right
        screenshotButton.setTitleColor(UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6), for: .normal)
        screenshotButton.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6), for: .highlighted)
        screenshotButton.addTarget(self, action: #selector(NumberTileGameViewController.captureScreen), for: .touchUpInside)
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            if #available(iOS 8.2, *) {
                screenshotButton.titleLabel!.font =  UIFont.systemFont(ofSize: 37, weight: UIFontWeightHeavy)
            } else {
                // Fallback on earlier versions
                screenshotButton.titleLabel!.font =  UIFont.systemFont(ofSize: 37)
            }
        } else {
            if #available(iOS 8.2, *) {
                screenshotButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17, weight: UIFontWeightHeavy)
            } else {
                // Fallback on earlier versions
                screenshotButton.titleLabel!.font =  UIFont.systemFont(ofSize: 18)
            }
        }
        view.addSubview(screenshotButton)

    }
    
    func captureScreen() {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    func hideScreenshotButton() {
        screenshotButton.isUserInteractionEnabled = false
        screenshotButton.isHidden = true
    }
    
  func setupGame() {
    let vcHeight = view.bounds.size.height
    let vcWidth = view.bounds.size.width

    // This nested function provides the x-position for a component view
    func xPositionToCenterView(_ v: UIView) -> CGFloat {
      let viewWidth = v.bounds.size.width
      let tentativeX = 0.5*(vcWidth - viewWidth)
      return tentativeX >= 0 ? tentativeX : 0
    }
    
    // This nested function provides the y-position for a component view
    func yPositionToCenterView(_ v: UIView) -> CGFloat {
        let viewHeight = v.bounds.size.height
        let tentativeY = 0.5*(vcHeight - viewHeight)
        return tentativeY >= 0 ? tentativeY : 0
    }
    
    
    // Create the gameboard
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width
    let padding: CGFloat = defaultPadding
    let boardWidth = screenWidth
    let width: CGFloat = CGFloat(floorf(CFloat(boardWidth)))/CGFloat(dimension)
    let gameboard = GameboardView(dimension: dimension,
      tileWidth: width-0.05, // substract the tile border
      tilePadding: padding,
      cornerRadius: 0,
      backgroundColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0),
      foregroundColor: UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.0))

    var f = gameboard.frame
    f.origin.x = xPositionToCenterView(gameboard)
    f.origin.y = yPositionToCenterView(gameboard)
    gameboard.frame = f

    // Reset game button styling and adding to view
    if (UIDevice.current.userInterfaceIdiom == .pad) {
        if #available(iOS 8.2, *) {
            resetButton.titleLabel!.font =  UIFont.systemFont(ofSize: 37, weight: UIFontWeightHeavy)
        } else {
            // Fallback on earlier versions
            resetButton.titleLabel!.font =  UIFont.systemFont(ofSize: 37)
        }
    } else {
        if #available(iOS 8.2, *) {
            resetButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17, weight: UIFontWeightHeavy)
        } else {
            // Fallback on earlier versions
            resetButton.titleLabel!.font =  UIFont.systemFont(ofSize: 18)
        }
    }
    
    resetButton.titleLabel?.adjustsFontSizeToFitWidth = true;
    resetButton.frame.origin.x = view.bounds.size.width-resetButton.frame.width+5
    resetButton.frame.origin.y = view.bounds.size.height-resetButton.frame.height
    resetButton.setTitle("restart", for: .normal)
    resetButton.titleLabel?.textAlignment = .right
    resetButton.setTitleColor(UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6), for: .normal)
    resetButton.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6), for: .highlighted)
    resetButton.contentEdgeInsets = UIEdgeInsetsMake(20,0,0,0)
    resetButton.addTarget(self, action: #selector(NumberTileGameViewController.reset), for: .touchUpInside)
    view.addSubview(resetButton)
    
    
    // Countdown timer styling and adding to view and starting it
    timerLabel.textAlignment = .left
    timerLabel.adjustsFontSizeToFitWidth = true;
    timerLabel.textColor = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6)
    timerLabel.text = gameSettings.gameTimeText
    timerLabel.frame.origin.x = 10
    timerLabel.frame.origin.y = resetButton.frame.origin.y+20
    if (UIDevice.current.userInterfaceIdiom == .pad) {
        if #available(iOS 8.2, *) {
            timerLabel.font =  UIFont.systemFont(ofSize: 37, weight: UIFontWeightHeavy)
        } else {
            // Fallback on earlier versions
            timerLabel.font =  UIFont.systemFont(ofSize: 37)
        }
    } else {
        if #available(iOS 8.2, *) {
            timerLabel.font =  UIFont.systemFont(ofSize: 17, weight: UIFontWeightHeavy)
        } else {
            // Fallback on earlier versions
            timerLabel.font =  UIFont.systemFont(ofSize: 18)
        }
    }

    
    view.addSubview(timerLabel)
    runTimer()
    
    
    // Add to game state
    view.addSubview(gameboard)
    board = gameboard

    assert(model != nil)
    let m = model!
    m.insertTileAtRandomLocation(withValue: 2)
    m.insertTileAtRandomLocation(withValue: 2)
  }
    
    
    
    // Functions when user wins or loses
    var youLost: [String] = ["🤦‍♂️", "🤦‍♀️", "🤦🏿‍♂️", "🤦🏿‍♀️", "🤦🏾‍♂️", "🤦🏾‍♀️", "🙊", "💩", "😢", "👎", "😩", "😿", "👻", "👾", "🐒", "🐣", "🆘", "💔", "🔥", "🕸", "🍌", "🔫", "🥊", "🏳️", "🔨", "🤕", "🤢", "🐭", "⛄️", "🚧"]
    var youWon: [String] = ["🥇", "🎯", "🎰", "🏆", "❤️", "🌈", "⚡️", "💵", "🎉", "🏁", "🦄", "🍾", "🍻", "🤸‍♂️", "😇"]
    //    var youWonMsg: [String] = ["Respectz!", "Boom!", "Wot!", "Rockin!", "You rulez!", "Awesome!"]
    
    func followUpLost(msg: String) {
        // TODO: alert delegate we lost
        let alertView = UIAlertView()
        alertView.title = "Ouch, \(msg)! \(youLost[Int(arc4random_uniform(UInt32(youLost.count)))])"
              alertView.message = "You lost, sorry..."
        alertView.addButton(withTitle: "No worries")
        alertView.show()
         resetButton.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6), for: .normal)
    }
    
    func followUpWon() {
        gameover = true
        timer.invalidate()
        showScreenshotButton()
        timerLabel.textColor = UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6)
        
        // TODO: alert delegate we won
        let alertView = UIAlertView()
        alertView.title = "Wow, you won! \(youWon[Int(arc4random_uniform(UInt32(youWon.count)))])"
              alertView.message = "Respectz, you're a genius..."
        alertView.addButton(withTitle: "Thanks")
        alertView.show()
        // TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
        resetButton.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6), for: .normal)
        return
    }

  // Misc
  func followUp() {
    assert(model != nil)
    let m = model!
    let (userWon, _) = m.userHasWon()
    
    if userWon {
      followUpWon()
    }

    
    // Now, insert more tiles
    let randomVal = Int(arc4random_uniform(10))
    m.insertTileAtRandomLocation(withValue: randomVal == 1 ? 4 : 2)

    // At this point, the user may lose
    if m.userHasLost() {
        gameover = true
        timer.invalidate()
        showScreenshotButton()
        timerLabel.textColor = UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6)
        showScreenshotButton()
        followUpLost(msg: "no more moves")
    }
  }

  // Commands
  @objc(up:)
  func upCommand(_ r: UIGestureRecognizer!) {
    if gameover {return} // Ignore when game is over
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.up,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(down:)
  func downCommand(_ r: UIGestureRecognizer!) {
    if gameover {return} // Ignore when game is over
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.down,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(left:)
  func leftCommand(_ r: UIGestureRecognizer!) {
    if gameover {return} // Ignore when game is over
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.left,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  @objc(right:)
  func rightCommand(_ r: UIGestureRecognizer!) {
    if gameover {return} // Ignore when game is over
    assert(model != nil)
    let m = model!
    m.queueMove(direction: MoveDirection.right,
      onCompletion: { (changed: Bool) -> () in
        if changed {
          self.followUp()
        }
      })
  }

  func moveOneTile(from: (Int, Int), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveOneTile(from: from, to: to, value: value)
  }

  func moveTwoTiles(from: ((Int, Int), (Int, Int)), to: (Int, Int), value: Int) {
    assert(board != nil)
    let b = board!
    b.moveTwoTiles(from: from, to: to, value: value)
  }

  func insertTile(at location: (Int, Int), withValue value: Int) {
    assert(board != nil)
    let b = board!
    b.insertTile(at: location, value: value)
  }
}
