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
    b.reset()
    m.reset()
    m.insertTileAtRandomLocation(withValue: 2)
    m.insertTileAtRandomLocation(withValue: 2)
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

    
    // Reset game button
    let resetButton = UIButton(frame: CGRect(x: view.bounds.size.width-75, y: view.bounds.size.height-50, width: 95, height: 50))
    if #available(iOS 8.2, *) {
        resetButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17, weight: UIFontWeightHeavy)
    } else {
        // Fallback on earlier versions
        resetButton.titleLabel!.font =  UIFont.systemFont(ofSize: 17)
    }
    resetButton.setTitle("restart", for: .normal)
    resetButton.setTitleColor(UIColor(red: 45.0/255.0, green: 45.0/255.0, blue: 45.0/255.0, alpha: 0.6), for: .normal)
    resetButton.setTitleColor(UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 0.6), for: .highlighted)
    resetButton.contentEdgeInsets = UIEdgeInsetsMake(20,0,0,20)
    resetButton.addTarget(self, action: #selector(NumberTileGameViewController.reset), for: .touchUpInside)
    view.addSubview(resetButton)

    
    // Add to game state
    view.addSubview(gameboard)
    board = gameboard

    assert(model != nil)
    let m = model!
    m.insertTileAtRandomLocation(withValue: 2)
    m.insertTileAtRandomLocation(withValue: 2)
  }

  // Misc
  func followUp() {
    assert(model != nil)
    let m = model!
    let (userWon, _) = m.userHasWon()
    if userWon {
      // TODO: alert delegate we won
      let alertView = UIAlertView()
      alertView.title = "You win!"
      alertView.message = "Respect :)"
      alertView.addButton(withTitle: "Thanks")
      alertView.show()
      // TODO: At this point we should stall the game until the user taps 'New Game' (which hasn't been implemented yet)
      return
    }

    // Now, insert more tiles
    let randomVal = Int(arc4random_uniform(10))
    m.insertTileAtRandomLocation(withValue: randomVal == 1 ? 4 : 2)

    // At this point, the user may lose
    if m.userHasLost() {
      // TODO: alert delegate we lost
      let alertView = UIAlertView()
      alertView.title = "You lost!"
      alertView.message = "Sorry :("
      alertView.addButton(withTitle: "OK")
      alertView.show()
    }
  }

  // Commands
  @objc(up:)
  func upCommand(_ r: UIGestureRecognizer!) {
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
