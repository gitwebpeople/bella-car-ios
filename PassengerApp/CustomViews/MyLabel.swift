//
//  PaddingLabel.swift
//  Login_SignUp
//
//  Created by Chirag on 09/12/15.
//  Copyright © 2015 ESW. All rights reserved.
//

import UIKit

protocol MyLabelClickDelegate {
    func myLableTapped(sender:MyLabel)
}

public enum IconPosition {
    case left
    case right
}

class MyLabel: UILabel {
    typealias OnLabelClickedHandler = (_ instance:MyLabel) -> Void

    @IBInspectable internal var paddingRight:CGFloat = 0
    @IBInspectable internal var paddingLeft:CGFloat = 0
    @IBInspectable internal var paddingTop:CGFloat = 0
    @IBInspectable internal var paddingBottom:CGFloat = 0
    
    @IBInspectable internal var fontFamilyWeight:String!
    
    @IBInspectable internal var isAppThemeBg:Bool = false
    @IBInspectable internal var isAppTheme1Bg:Bool = false
    @IBInspectable internal var isAppThemeFont:Bool = false
    @IBInspectable internal var isAppTheme1Font:Bool = false
    @IBInspectable internal var isAppThemeTextFont:Bool = false
    @IBInspectable internal var isAppThemeText1Font:Bool = false
    
    var xOffset:CGFloat = 0
    var yOffset:CGFloat = 0
    
    var isInCenterOfScreen = false
    
    var fontName = Fonts().light
    
    // MARK:- Delegate
    var clickDelegate:MyLabelClickDelegate?
    var clickHandler:OnLabelClickedHandler!

    let tapGue = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        setConfig()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        setConfig()
    }
    
    func setConfig(){
        
        setFontFamily()
        setColor()
    }
    
    func setFontFamily(){
        if(fontFamilyWeight == nil){
            fontName = Fonts().light
        }else{
            var compareStr = ""
            var fontCon = [String] ()
            fontCon = fontFamilyWeight.components(separatedBy: "-")
            if(fontCon.count > 0){
                compareStr = fontCon.last ?? ""
            }
            
            if("Regular" == fontFamilyWeight || "Regular" == compareStr || Utils.fontFname == fontCon.first ?? ""){
                fontName = Fonts().regular
            }else if("Medium" == fontFamilyWeight || "Medium" == compareStr || "Semibold" == compareStr || "Semibold" == fontFamilyWeight){
                fontName = Fonts().semibold
            }else if("Light" == fontFamilyWeight || "Light" == compareStr){
                fontName = Fonts().light
            }else if("Bold" == fontFamilyWeight || "Bold" == compareStr){
                fontName = Fonts().bold
            }else{
                fontName = Fonts().light
            }
        }
        
        self.font = UIFont(name: fontName, size: self.font.pointSize)
    }
    
    func setClickHandler(handler:@escaping OnLabelClickedHandler){
        self.setTapGesture()
        self.clickHandler = handler
    }
    
    func setColor(){
        if(isAppThemeBg == true){
            self.backgroundColor = UIColor.UCAColor.AppThemeColor
        }else if(isAppTheme1Bg == true){
            self.backgroundColor = UIColor.UCAColor.AppThemeColor_1
        }
        
        if(isAppThemeFont == true){
            self.textColor = UIColor.UCAColor.AppThemeColor
        }else if(isAppTheme1Font == true){
            self.textColor = UIColor.UCAColor.AppThemeColor_1
        }else if(isAppThemeTextFont == true){
            self.textColor = UIColor.UCAColor.AppThemeTxtColor
        }else if(isAppThemeText1Font == true){
            self.textColor = UIColor.UCAColor.AppThemeTxtColor_1
        }
    }
    
    func setCustomTextColor(color:UIColor){
        isAppThemeFont = false
        isAppTheme1Font = false
        isAppThemeTextFont = false
        isAppThemeText1Font = false
        
        self.textColor = color
    }
    
    func setCustomBGColor(color:UIColor){
        isAppThemeBg = false
        isAppTheme1Bg = false
        
        self.backgroundColor = color
    }
    
    func setTapGesture(){
        tapGue.addTarget(self, action: #selector(self.myLblTapped(sender:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGue)
    }
    
    func setClickDelegate(clickDelegate:MyLabelClickDelegate){
        self.setTapGesture()
        self.clickDelegate = clickDelegate
    }
    
    @objc func myLblTapped(sender:UITapGestureRecognizer){
        if (Application.window != nil){
            Application.window?.endEditing(true)
        }
        
        if(clickHandler != nil){
            clickHandler(self)
        }
        
        clickDelegate?.myLableTapped(sender: self)
    }
    
    override func drawText(in rect: CGRect) {
        setFontFamily()
        setColor()
        if(isInCenterOfScreen){
//            self.center = CGPoint((Application.screenSize.width  / 2) - (self.frame.width / 2),
//                                 (Application.screenSize.height / 2)  - (self.frame.height / 2))
            
            self.center = self.superview != nil ? self.superview!.center : (CGPoint((Application.screenSize.width  / 2) - (self.frame.width / 2),
                                                                                    (Application.screenSize.height / 2)  - (self.frame.height / 2)))
            
            self.center.x = self.center.x + xOffset
            self.center.y = self.center.y + yOffset
        }
        
        super.drawText(in: rect.inset(by: getPadding()))
    }
    
    func getPadding() -> UIEdgeInsets{
        let padding = UIEdgeInsets(top: paddingTop, left: paddingLeft, bottom: paddingBottom, right: paddingRight)

        return padding
    }
    
    func setPadding(paddingTop:CGFloat, paddingBottom:CGFloat, paddingLeft:CGFloat, paddingRight:CGFloat){
        self.paddingTop = paddingTop
        self.paddingBottom = paddingBottom
        self.paddingLeft = paddingLeft
        self.paddingRight = paddingRight
    }
    
    func setInCenter(isInCenterOfScreen:Bool){
        self.isInCenterOfScreen = isInCenterOfScreen
    }
    
    // Override -intrinsicContentSize: for Auto layout code
    override public var intrinsicContentSize: CGSize {
        let superContentSize = super.intrinsicContentSize
        let width = superContentSize.width + getPadding().left + getPadding().right
        let heigth = superContentSize.height + getPadding().top + getPadding().bottom
        return CGSize(width: width, height: heigth)
    }
    
    
    // Override -sizeThatFits: for Springs & Struts code
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)
        let width = superSizeThatFits.width + getPadding().left + getPadding().right
        let heigth = superSizeThatFits.height + getPadding().top + getPadding().bottom
        return CGSize(width: width, height: heigth)
    }

    
    func addImage(originalText:String, image:UIImage?, color:UIColor, position:IconPosition){
        
        let textStr = NSMutableAttributedString(string: originalText)
        
        // create our NSTextAttachment
        let imgAttachment = NSTextAttachment()
        imgAttachment.image = image?.withRenderingMode(.alwaysTemplate).setTintColor(color: color)
        
        let imgAttrStr = NSAttributedString(attachment: imgAttachment)
        
        if(position == .right){
            textStr.append(imgAttrStr)
        }else{
            textStr.insert(imgAttrStr, at: 0)
        }
        self.attributedText = textStr
    }
}
