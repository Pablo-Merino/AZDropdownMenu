//
//  AppDelegate.swift
//  AZDropdownMenu
//
//  Created by Chris Wu on 01/05/2016.
//  Copyright (c) 2016 Chris Wu. All rights reserved.
//

import UIKit

public class AZDropdownMenu: UIView {
    
    private let DROPDOWN_MENU_CELL_KEY : String = "MenuItemCell"

    /// The dark overlay behind the menu
    private let overlay:UIView = UIView()
    private var menuView: UITableView!
    
    /// Array of titles for the menu
    private var titles = [String]()
    
    /// Property to figure out if initial layout has been configured
    private var isSetUpFinished : Bool

    /// The handler used when menu item is tapped
    public var cellTapHandler : ((indexPath:NSIndexPath) -> Void)?
    
    // MARK: - Configuration options

    /// Row height of the menu item
    public var itemHeight : Int = 44 {
        didSet {
            let menuFrame = CGRectMake(0, 0, frame.size.width, menuHeight)
            self.menuView.frame = menuFrame
        }
    }
    
    /// The color of the menu item
    public var itemColor : UIColor = UIColor.whiteColor()
    
    /// The text color of the menu item
    public var itemFontColor : UIColor = UIColor.blackColor()
    
    /// Font size of the menu item
    public var itemFontSize : CGFloat = 14.0
    
    /// The alpha for the background overlay
    public var overlayAlpha : CGFloat = 0.5 {
        didSet {
            self.overlay.alpha = self.overlayAlpha
        }
    }
    
    /// Color for the background overlay
    public var overlayColor : UIColor = UIColor.blackColor() {
        didSet {
            self.overlay.backgroundColor = self.overlayColor
        }
    }
    
    public var menuSeparatorStyle:CWDropdownMenuSeperatorStyle = .Singleline {
        didSet {
            switch(menuSeparatorStyle){
                case .None:
                    self.menuView.separatorStyle = .None
                case .Singleline:
                    self.menuView.separatorStyle = .SingleLine
            }
        }
    }
    
    /// The text alignment of the menu item
    public var itemAlignment : NSTextAlignment = .Left
    
    private var calcMenuHeight : CGFloat {
        get {
            return CGFloat(self.itemHeight * self.titles.count)
        }
    }
    
    private var menuHeight : CGFloat {
        get {
            return (self.calcMenuHeight > frame.size.height) ? frame.size.height : self.calcMenuHeight
        }
    }

    // MARK: - Initializer
    public init(titles:[String]) {
        self.isSetUpFinished = false
        self.titles = titles
        super.init(frame:UIScreen.mainScreen().bounds)
        self.accessibilityIdentifier = "CWDropdownMenu"
        self.backgroundColor = UIColor.clearColor()
        self.alpha = 0.95;
        self.translatesAutoresizingMaskIntoConstraints = false
        initOverlay()
        initMenu()
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    override public func layoutSubviews() {
        if self.isSetUpFinished == false {
            setupInitialLayout()
        }
    }

    private func initOverlay() {
        let frame = UIScreen.mainScreen().bounds
        self.overlay.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.height)
        self.overlay.backgroundColor = self.overlayColor
        self.overlay.accessibilityIdentifier = "OVERLAY"
        self.overlay.alpha = 0
        self.addSubview(self.overlay)
    }

    private func initMenu() {
        let frame = UIScreen.mainScreen().bounds
        let menuFrame = CGRectMake(0, 0, frame.size.width, menuHeight)

        self.menuView = UITableView(frame: menuFrame, style: .Plain)
        self.menuView.userInteractionEnabled = true
        self.menuView.rowHeight = CGFloat(self.itemHeight)
        self.menuView.registerClass(UITableViewCell.self, forCellReuseIdentifier:DROPDOWN_MENU_CELL_KEY)
        self.menuView.dataSource = self
        self.menuView.delegate = self
        self.menuView.scrollEnabled = false
        self.menuView.accessibilityIdentifier = "MENU"
        self.addSubview(self.menuView)
    }

    private func setupInitialLayout() {

        let viewWidth = UIScreen.mainScreen().bounds.width

        var constraintsArray : [NSLayoutConstraint] = []
        let height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: menuHeight)
        let width = NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: viewWidth)

        constraintsArray.append(height)
        constraintsArray.append(width)

        self.addConstraints(constraintsArray)
        self.isSetUpFinished = true
        
    }
    
    private func animateOvelay(alphaValue: CGFloat, interval: Double, completionHandler: (() -> Void)? ) {
        UIView.animateWithDuration(
            interval,
            animations: {
                self.overlay.alpha = alphaValue
            }, completion: { (finished: Bool) -> Void in
                if let completionHandler = completionHandler {
                    completionHandler()
                }
            }
        )
    }

    //MARK: - Public methods to control the menu
    
    /**
    Show menu
    
    - parameter view: The view to be attached by the menu, ex. the controller's view
    */
    public func showMenuFromView(view:UIView){
        
        view.addSubview(self)
        
        animateOvelay(overlayAlpha, interval: 0.4, completionHandler: nil)
        self.menuView.reloadData()
        UIView.animateWithDuration(
            0.2,
            delay:0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0.6,
            options:[],
            animations:{
                self.frame.origin.y = view.frame.origin.y
                } , completion:{ (finished : Bool) -> Void in

            }
        )
    }
    
    public func hideMenu() {

        animateOvelay(0.0, interval: 0.1, completionHandler: nil)

        UIView.animateWithDuration(
            0.3, delay: 0.1,
            options: [],
            animations: {
                self.frame.origin.y = -1200
            },
            completion: { (finished: Bool) -> Void in
                self.removeFromSuperview()
            }
        )
    }
}


// MARK: - UITableViewDataSource
extension AZDropdownMenu: UITableViewDataSource {

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(DROPDOWN_MENU_CELL_KEY) {
            cell.selectionStyle = UITableViewCellSelectionStyle.Gray
            cell.backgroundColor = self.itemColor
            cell.textLabel?.textColor = self.itemFontColor
            cell.textLabel?.textAlignment = self.itemAlignment
            cell.textLabel?.font = UIFont.systemFontOfSize(self.itemFontSize)
            cell.textLabel?.text = self.titles[indexPath.row]
            return cell
            
        }
        return UITableViewCell()
    }

}

// MARK: - UITableViewDelegate
extension AZDropdownMenu: UITableViewDelegate {

    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
        self.cellTapHandler?(indexPath:indexPath)
        hideMenu()
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(self.itemHeight)
    }

}

/**
 The separator style of the menu
 
 - Singleline: A solid single line
 - None:       No Separator
 */
public enum CWDropdownMenuSeperatorStyle {
    case Singleline, None
}
