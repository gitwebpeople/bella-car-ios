//
//  EditProfileUV.swift
//  PassengerApp
//
//  Created by ADMIN on 15/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class EditProfileUV: UIViewController, MyBtnClickDelegate, MyTxtFieldClickDelegate, MyLabelClickDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollViewCOntentViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var scrollViewContentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profilePicViewArea: UIView!
    @IBOutlet weak var editPicAreaView: UIView!
    
    @IBOutlet weak var userProfilePicBgView: UIView!
    @IBOutlet weak var userProfilePicBgImgView: UIImageView!
    @IBOutlet weak var usrProfileImgView: UIImageView!
    @IBOutlet weak var fNameTxtField: MyTextField!
    @IBOutlet weak var lNameTxtField: MyTextField!
    @IBOutlet weak var emailTxtField: MyTextField!
    @IBOutlet weak var countryTxtField: MyTextField!
    @IBOutlet weak var mobileTxtField: MyTextField!
    @IBOutlet weak var languageTxtField: MyTextField!
    @IBOutlet weak var currencyTxtField: MyTextField!
    @IBOutlet weak var editIconImgView: UIImageView!
    
    @IBOutlet weak var langTxtFieldHeight: NSLayoutConstraint!
    @IBOutlet weak var currencyTxtFieldHeight: NSLayoutConstraint!
    
    @IBOutlet weak var updateBtn: MyButton!
    
    var manageProfileUv:ManageProfileUV!
    
    var containerViewHeight:CGFloat = 0
    
    let generalFunc = GeneralFunctions()
    
    var required_str = ""
    
    var isCountrySelected = false
    var selectedCountryCode = ""
    var selectedPhoneCode = ""
    
    var selectedCurrency = ""
    var selectedLngCode = ""
    
    var languageNameList = [String]()
    var languageCodes = [String]()
    
    var currenyList = [String]()
    
    
    var isFirstLaunch = true
    var cntView:UIView!
    
    var openImgSelection:OpenImageSelectionOption!
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cntView = self.generalFunc.loadView(nibName: "EditProfileScreenDesign", uv: self, contentView: scrollView)
        
        self.scrollView.addSubview(cntView)
        
        
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.dark))
        blurEffectView.frame = userProfilePicBgView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.userProfilePicBgView.addSubview(blurEffectView)
        
        setData()
    }
    
    func setData(){
        required_str = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT")
        
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PROFILE_TITLE_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PROFILE_TITLE_TXT")
//        LBL_EDIT_PROFILE_TXT
        fNameTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FIRST_NAME_HEADER_TXT"))
        lNameTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LAST_NAME_HEADER_TXT"))
        emailTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_EMAIL_LBL_TXT"))
        countryTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_COUNTRY_TXT"))
        mobileTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_MOBILE_NUMBER_HEADER_TXT"))
        languageTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LANGUAGE_TXT"))
        currencyTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CURRENCY_TXT"))
        
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        fNameTxtField.setText(text: userProfileJson.get("vName"))
        lNameTxtField.setText(text: userProfileJson.get("vLastName"))
        emailTxtField.setText(text: userProfileJson.get("vEmail"))
        countryTxtField.setText(text: userProfileJson.get("vPhoneCode"))
        mobileTxtField.setText(text: userProfileJson.get("vPhone"))
        languageTxtField.setText(text: userProfileJson.get("vLang"))
        currencyTxtField.setText(text: userProfileJson.get("vCurrencyPassenger"))
        
        countryTxtField.disableMenu()
        languageTxtField.disableMenu()
        currencyTxtField.disableMenu()
        
        languageTxtField.setEnable(isEnabled: false)
        currencyTxtField.setEnable(isEnabled: false)
        
        self.countryTxtField.setEnable(isEnabled: false)
        self.countryTxtField.myTxtFieldDelegate = self
        
        self.languageTxtField.myTxtFieldDelegate = self
        self.currencyTxtField.myTxtFieldDelegate = self
        
        self.selectedCurrency = userProfileJson.get("vCurrencyPassenger")
        
        if(userProfileJson.get("vPhoneCode") != ""){
            isCountrySelected = true
            selectedCountryCode = userProfileJson.get("vCountry")
            selectedPhoneCode = userProfileJson.get("vPhoneCode")
        }
        
        self.updateBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_PROFILE_UPDATE_PAGE_TXT"))
        self.updateBtn.clickDelegate = self
        
        userProfilePicBgImgView.sd_setImage(with: URL(string: CommonUtils.user_image_url + GeneralFunctions.getMemberd() + "/" + userProfileJson.get("vImgName")), placeholderImage:UIImage(named:"ic_no_pic_user"))

        usrProfileImgView.sd_setImage(with: URL(string: CommonUtils.user_image_url + GeneralFunctions.getMemberd() + "/" + userProfileJson.get("vImgName")), placeholderImage:UIImage(named:"ic_no_pic_user"))
        
        Utils.createRoundedView(view: usrProfileImgView, borderColor: UIColor.UCAColor.AppThemeColor_1, borderWidth: 2)

        editPicAreaView.backgroundColor = UIColor.UCAColor.AppThemeColor_1
        Utils.createRoundedView(view: editPicAreaView, borderColor: UIColor.clear, borderWidth: 0)
        
        GeneralFunctions.setImgTintColor(imgView: editIconImgView, color: UIColor.UCAColor.AppThemeTxtColor)
        
        self.mobileTxtField.getTextField()!.keyboardType = .numberPad
        self.emailTxtField.getTextField()!.keyboardType = .emailAddress
        
        setLanguage()
        
        let userProfileImgTapGue = UITapGestureRecognizer()
        userProfileImgTapGue.addTarget(self, action: #selector(self.profilePicTapped))
        
        self.profilePicViewArea.isUserInteractionEnabled = true
        self.profilePicViewArea.addGestureRecognizer(userProfileImgTapGue)
        
    }
    
    @objc func profilePicTapped(){
        self.openImgSelection = OpenImageSelectionOption(uv: self)
        self.openImgSelection.show { (isImageUpload) in
            if(isImageUpload == true){
                self.setData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isFirstLaunch == true){
            languageTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
            currencyTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
            countryTxtField.addArrowView(color: UIColor(hex: 0xbfbfbf), transform: CGAffineTransform(rotationAngle: 90 * CGFloat(CGFloat.pi/180)))
            
            if(containerViewHeight > self.scrollViewCOntentViewHeight.constant){
                self.scrollViewCOntentViewHeight.constant = containerViewHeight
            }
            
            cntView.frame.size = CGSize(width: cntView.frame.width, height: self.scrollViewCOntentViewHeight.constant)
            
            self.scrollView.bounces = false
//            self.scrollView.setContentViewSize(offset: 15, currentMaxHeight: self.scrollViewCOntentViewHeight.constant)
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: self.scrollViewCOntentViewHeight.constant)
            
            isFirstLaunch = false
        }
    }
    
    func myTxtFieldTapped(sender: MyTextField) {
        if(sender == self.countryTxtField){
            let countryListUv = GeneralFunctions.instantiateViewController(pageName: "CountryListUV") as! CountryListUV
            countryListUv.fromEditProfile = true
            self.pushToNavController(uv: countryListUv)
        }else if(sender == self.currencyTxtField){
            let openListView = OpenListView(uv: self, containerView: self.view)
            
            openListView.show(listObjects: currenyList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_CURRENCY"), currentInst: openListView, handler: { (selectedItemId) in
                self.currencyValueChanged(selectedItemId: selectedItemId)
            })
        }else if(sender == self.languageTxtField){
            let openListView = OpenListView(uv: self, containerView: self.view)
            openListView.show(listObjects: languageNameList, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SELECT_LANGUAGE_HINT_TXT"), currentInst: openListView, handler: { (selectedItemId) in
                self.lngValueChanged(selectedItemId: selectedItemId)
            })
        }
    }
    
    func setLanguage(){
        let dataArr = GeneralFunctions.getValue(key: Utils.LANGUAGE_LIST_KEY) as! NSArray
        
        for i in 0 ..< dataArr.count{
            let tempItem = dataArr[i] as! NSDictionary
            
            if((GeneralFunctions.getValue(key: Utils.LANGUAGE_CODE_KEY) as! String) == tempItem.get("vCode")){
                languageTxtField.setText(text: tempItem.get("vTitle"))
                self.selectedLngCode = tempItem.get("vCode")
            }
            
            languageNameList += [tempItem.get("vTitle")]
            languageCodes += [tempItem.get("vCode")]
            
        }
        
        if(dataArr.count < 2){
            self.scrollViewCOntentViewHeight.constant = self.scrollViewCOntentViewHeight.constant - self.langTxtFieldHeight.constant - 20
            self.langTxtFieldHeight.constant = 0.0
            self.languageTxtField.isHidden = true
        }
        
        setCurrency()
    }
    
    func lngValueChanged(selectedItemId:Int){
        self.selectedLngCode = self.languageCodes[selectedItemId]
        self.languageTxtField.setText(text: self.languageNameList[selectedItemId])
    }
    
    func setCurrency(){
        let dataArr = GeneralFunctions.getValue(key: Utils.CURRENCY_LIST_KEY) as! NSArray
        
        for i in 0 ..< dataArr.count{
            let tempItem = dataArr[i] as! NSDictionary
            currenyList += [tempItem.get("vName")]
        }
        
        if(dataArr.count < 2){
            self.scrollViewCOntentViewHeight.constant = self.scrollViewCOntentViewHeight.constant - self.currencyTxtFieldHeight.constant - 20
            self.currencyTxtFieldHeight.constant = 0.0
            self.currencyTxtField.isHidden = true
        }
    }
    
    func currencyValueChanged(selectedItemId:Int){
        
        self.selectedCurrency = self.currenyList[selectedItemId]
        self.currencyTxtField.setText(text: self.selectedCurrency)
        
    }
    
    func myBtnTapped(sender: MyButton) {
//        let noWhiteSpace = generalFunc.getLanguageLabel(origValue: "Password should not contain whitespace.", key: "LBL_ERROR_NO_SPACE_IN_PASS");
//        let pass_length = generalFunc.getLanguageLabel(origValue: "Password must be", key: "LBL_ERROR_PASS_LENGTH_PREFIX")
//            + " \(Utils.minPasswordLength)"  + generalFunc.getLanguageLabel(origValue: "or more character long.",key: "LBL_ERROR_PASS_LENGTH_SUFFIX");
        
        let mobileInvalid = generalFunc.getLanguageLabel(origValue: "Invalid mobile no.", key: "LBL_INVALID_MOBILE_NO")
        
        let fNameEntered = Utils.checkText(textField: self.fNameTxtField.getTextField()!) ? true : Utils.setErrorFields(textField: self.fNameTxtField.getTextField()!, error: required_str)
        let lNameEntered = Utils.checkText(textField: self.lNameTxtField.getTextField()!) ? true : Utils.setErrorFields(textField: self.lNameTxtField.getTextField()!, error: required_str)
        let emailEntered = Utils.checkText(textField: self.emailTxtField.getTextField()!) ? (GeneralFunctions.isValidEmail(testStr: Utils.getText(textField: self.emailTxtField.getTextField()!)) ? true : Utils.setErrorFields(textField: self.emailTxtField.getTextField()!, error: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_EMAIL_ERROR_TXT"))) : Utils.setErrorFields(textField: self.emailTxtField.getTextField()!, error: required_str)
//        let mobileEntered = Utils.checkText(textField: self.mobileTxtField.getTextField()!) ? true : Utils.setErrorFields(textField: self.mobileTxtField.getTextField()!, error: required_str)
        let mobileEntered = Utils.checkText(textField: self.mobileTxtField.getTextField()!) ? (Utils.getText(textField: self.mobileTxtField.getTextField()!).count >= Utils.minMobileLength ? true : Utils.setErrorFields(textField: self.mobileTxtField.getTextField()!, error: mobileInvalid)) : Utils.setErrorFields(textField: self.mobileTxtField.getTextField()!, error: required_str)
        
        let countryEntered = isCountrySelected ? true : Utils.setErrorFields(textField: self.countryTxtField.getTextField()!, error: required_str)
        
        if (fNameEntered == false || lNameEntered == false || emailEntered == false || mobileEntered == false
            || countryEntered == false) {
            return;
        }
        
        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        let vPhoneCode = userProfileJson.get("vPhoneCode")
        let vPhone = userProfileJson.get("vPhone")
        
        if let SITE_TYPE = GeneralFunctions.getValue(key: Utils.SITE_TYPE_KEY) as? String{
            if(SITE_TYPE == "Demo" && userProfileJson.get("vEmail") == "rider@gmail.com"){
                self.generalFunc.setError(uv: self, title: "", content: userProfileJson.get("SITE_TYPE_DEMO_MSG"))
                return
            }
        }
        
        if(GeneralFunctions.getValue(key: Utils.MOBILE_VERIFICATION_ENABLE_KEY) != nil && (GeneralFunctions.getValue(key: Utils.MOBILE_VERIFICATION_ENABLE_KEY) as! String).uppercased() == "YES" && (vPhoneCode != self.selectedPhoneCode  || vPhone != Utils.getText(textField: self.mobileTxtField.getTextField()!))){
            
            DispatchQueue.main.async() {
                self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_VERIFY_MOBILE_CONFIRM_MSG"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "OK", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedId) in
                    
                    if(btnClickedId == 0){
                        let accountVerificationUv = GeneralFunctions.instantiateViewController(pageName: "AccountVerificationUV") as! AccountVerificationUV
                        accountVerificationUv.mobileNum = self.selectedPhoneCode + Utils.getText(textField: self.mobileTxtField.getTextField()!)
                        accountVerificationUv.isEditProfile = true
                        accountVerificationUv.requestType = "DO_PHONE_VERIFY"
                        self.pushToNavController(uv: accountVerificationUv)
                    }
                })
            }
        }else{
            
            let vCurrencyPassenger = userProfileJson.get("vCurrencyPassenger")
            let vLang = userProfileJson.get("vLang")
            
            if(userProfileJson.get("ONLYDELIVERALL").uppercased() == "YES" || userProfileJson.get("DELIVERALL") == "Yes") && (vLang != self.selectedLngCode || vCurrencyPassenger != self.selectedCurrency)
            {
                var foodItmData = NSMutableArray.init()
                if (UserDefaults.standard.object(forKey: Utils.CART_INFO_DATA) != nil) {
                    
                    foodItmData = (GeneralFunctions.getValue(key: Utils.CART_INFO_DATA) as! NSArray).mutableCopy() as! NSMutableArray
                    
                }
                if foodItmData.count != 0
                {
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CART_REMOVE_NOTE"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_YES"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NO"), completionHandler: { (btnClickedIndex) in
                        
                        if btnClickedIndex == 0
                        {
                            let cartItemsArray = (GeneralFunctions.getValue(key: Utils.CART_INFO_DATA) as! NSArray).mutableCopy() as! NSMutableArray
                            cartItemsArray.removeAllObjects()
                            GeneralFunctions.saveValue(key: Utils.CART_INFO_DATA, value: cartItemsArray as AnyObject)
                            
                            self.updateProfile()
                        }
                        
                    })
                }else
                {
                    updateProfile()
                }
            }else
            {
                updateProfile()
            }
          
        }
    }
    
    func updateProfile(){
        
        let parameters = ["type":"updateUserProfileDetail","vName": Utils.getText(textField: self.fNameTxtField.getTextField()!), "vLastName": Utils.getText(textField: self.lNameTxtField.getTextField()!), "vEmail": Utils.getText(textField: self.emailTxtField.getTextField()!), "vPhone": Utils.getText(textField: self.mobileTxtField.getTextField()!), "vPhoneCode": self.selectedPhoneCode, "vCountry": self.selectedCountryCode, "vDeviceType": Utils.deviceType, "iMemberId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "LanguageCode": selectedLngCode, "CurrencyCode": self.selectedCurrency]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    _ = SetUserData(uv: self, userProfileJson: dataDict, isStoreUserId: false)
                    
                    let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)

                    let vCurrencyPassenger = userProfileJson.get("vCurrencyPassenger")
                    let vLang = userProfileJson.get("vLang")

                    if(vLang != self.selectedLngCode || vCurrencyPassenger != self.selectedCurrency){
                        
                        self.generalFunc.setAlertMessage(uv: self, title: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_TRIP_CANCEL_CONFIRM_TXT"), content: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_NOTIFY_RESTART_APP_TO_CHANGE"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Ok", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedIndex) in
                            
                            let window = UIApplication.shared.delegate!.window!
                            
                            GeneralFunctions.restartApp(window: window!)
                        })
                        
                        return
                    }
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)

                    if(self.manageProfileUv.isFromAccountVerifyScreen == true){
                        self.manageProfileUv!.performSegue(withIdentifier: "unwindToAccountVerificationScreen", sender: self.manageProfileUv)
                    }else{
                        self.manageProfileUv!.openViewProfileUv()
                    }
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    
    }
    
    @IBAction func unwindToEditProfile(_ segue:UIStoryboardSegue) {
        //        unwindToSignUp
        
        if(segue.source .isKind(of: CountryListUV.self))
        {
            
            let sourceViewController = segue.source as? CountryListUV
            let selectedPhoneCode:String = sourceViewController!.selectedCountryHolder!.vPhoneCode
            let selectedCountryCode = sourceViewController!.selectedCountryHolder!.vCountryCode
            
            self.selectedCountryCode = selectedCountryCode
            self.selectedPhoneCode = selectedPhoneCode
            
            self.countryTxtField.setText(text: "+" + selectedPhoneCode)
//            self.countryTxtField.getTextField()!.text = "+" + selectedPhoneCode
            self.isCountrySelected = true
            
            self.countryTxtField.getTextField()!.sendActions(for: .editingChanged)
        }else if(segue.source.isKind(of: AccountVerificationUV.self)){
            let accountVerificationUv = segue.source as! AccountVerificationUV
            
            if(accountVerificationUv.mobileNumVerified == true){
                updateProfile()
            }
        }
        
    }
    
    func myLableTapped(sender: MyLabel) {
       
    }
}
