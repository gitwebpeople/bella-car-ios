//
//  ManageWalletUV.swift
//  PassengerApp
//
//  Created by ADMIN on 17/05/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit
import SafariServices

class ManageWalletUV: UIViewController, MyLabelClickDelegate, MyBtnClickDelegate, UIWebViewDelegate  {

    var pageHeight:CGFloat = 640
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var balanceHLbl: MyLabel!
    @IBOutlet weak var balanceVLbl: MyLabel!
    @IBOutlet weak var viewTransactionBtn: MyButton!
    @IBOutlet weak var moneyTxtFieldContainerView: UIView!
    @IBOutlet weak var moneyTxtField: MyTextField!
    @IBOutlet weak var addMoneyHLbl: MyLabel!
    @IBOutlet weak var safeLbl: MyLabel!
    @IBOutlet weak var moneyContainerView1: UIView!
    @IBOutlet weak var moneyContainerView2: UIView!
    @IBOutlet weak var moneyContainerView3: UIView!
    @IBOutlet weak var moneyLbl1: MyLabel!
    @IBOutlet weak var moneyLbl2: MyLabel!
    @IBOutlet weak var moneyLbl3: MyLabel!
    @IBOutlet weak var termsLbl1: MyLabel!
    @IBOutlet weak var termsLbl2: MyLabel!
    @IBOutlet weak var addMoneyBtn: MyButton!
    @IBOutlet weak var updateAmountIndicator: UIActivityIndicatorView!
    
    /* PAYMENT FLOW CHANGES */
    let webView = UIWebView()
    var activityIndicator:UIActivityIndicatorView!
    /* ................. */
    
    let generalFunc = GeneralFunctions()
    
    var userProfileJson:NSDictionary!
    
    var cntView:UIView!
    
    var isFirstLaunch = true
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.configureRTLView()
     
        updateWalletAmount()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.layer.zPosition = 1
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.layer.zPosition = -1
        
        if(isFirstLaunch){
            
            cntView.frame.size = CGSize(width: cntView.frame.width, height: pageHeight)
            
            self.scrollView.contentSize = CGSize(width: self.scrollView.contentSize.width, height: pageHeight)
            
            isFirstLaunch = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cntView = self.generalFunc.loadView(nibName: "ManageWalletScreenDesign", uv: self, contentView: scrollView)
        
        
        self.view.backgroundColor = UIColor(hex: 0xF2F2F4)
        
        scrollView.backgroundColor = UIColor(hex: 0xF2F2F4)
        
        cntView.frame.size = CGSize(width: cntView.frame.width, height: pageHeight)
        
        self.scrollView.addSubview(cntView)
        self.scrollView.bounces = false
//        self.contentView.addSubview(self.generalFunc.loadView(nibName: "", uv: self, contentView: contentView))

        /* PAYMENT FLOW CHANGES */
        self.webView.isHidden = true
        /* ........... */
        
        self.addBackBarBtn()
        
        setData()
    }

    override func closeCurrentScreen() {
        /* PAYMENT FLOW CHANGES */
        if(GeneralFunctions.getPaymentMethod(userProfileJson: self.userProfileJson) == "2" && self.webView.isHidden == false){
            
            self.closeWebView()
            return
        }/* ........... */
        
        super.closeCurrentScreen()
    }

    
    func setData(){
        
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LEFT_MENU_WALLET")
        self.title = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_LEFT_MENU_WALLET")
        
        self.balanceHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_USER_BALANCE").uppercased()
        
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
//        self.balanceVLbl.text = Configurations.convertNumToAppLocal(numStr: userProfileJson.get("user_available_balance"))
       
        self.balanceVLbl.text = Configurations.convertNumToAppLocal(numStr: GeneralFunctions.getValue(key: "user_available_balance") as! String)
        
        self.viewTransactionBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_VIEW_TRANS_HISTORY"))
        
        if(userProfileJson.get("APP_PAYMENT_MODE").uppercased() == "CASH"){
            for view in self.cntView.subviews {
                if(view != self.headerView){
                    view.isHidden = true
                }
            }
            
            pageHeight = 210
        }
        
        headerView.layer.shadowOpacity = 0.5
//        headerView.layer.shadowRadius = 1.1
        headerView.layer.shadowOffset = CGSize(width: 0, height: 3)
        headerView.layer.shadowColor = UIColor(hex: 0xc0c0c1).cgColor
        headerView.backgroundColor = UIColor.UCAColor.AppThemeColor
        
        
        moneyTxtFieldContainerView.layer.shadowOpacity = 0.2
        moneyTxtFieldContainerView.layer.shadowOffset = CGSize(width: 0, height: 1)
        moneyTxtFieldContainerView.layer.shadowColor = UIColor.black.cgColor
        
        self.addMoneyHLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_MONEY").uppercased()
        self.safeLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_MONEY_TXT1")
        
        self.moneyTxtField.setPlaceHolder(placeHolder: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_RECHARGE_AMOUNT_TXT"))
        
        termsLbl1.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PRIVACY_POLICY")
        termsLbl1.fitText()
        termsLbl2.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_PRIVACY_POLICY1")
        
        moneyLbl1.text = Configurations.convertNumToAppLocal(numStr: userProfileJson.get("WALLET_FIXED_AMOUNT_1"))
        moneyLbl2.text = Configurations.convertNumToAppLocal(numStr: userProfileJson.get("WALLET_FIXED_AMOUNT_2"))
        moneyLbl3.text = Configurations.convertNumToAppLocal(numStr: userProfileJson.get("WALLET_FIXED_AMOUNT_3"))
        
        moneyLbl1.setClickDelegate(clickDelegate: self)
        moneyLbl2.setClickDelegate(clickDelegate: self)
        moneyLbl3.setClickDelegate(clickDelegate: self)
        termsLbl2.setClickDelegate(clickDelegate: self)
        
        termsLbl2.textColor = UIColor.UCAColor.AppThemeColor
        addMoneyBtn.setButtonTitle(buttonTitle: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_MONEY"))
        
        self.updateAmountIndicator.color = UIColor.UCAColor.AppThemeTxtColor
        
        self.moneyTxtField.getTextField()!.keyboardType = .decimalPad
        addMoneyBtn.clickDelegate = self
        
        viewTransactionBtn.clickDelegate = self
        viewTransactionBtn.setCustomColor(textColor: UIColor.UCAColor.walletPageViewTransBtnTextColor, bgColor: UIColor.UCAColor.walletPageViewTransBtnBGColor, pulseColor: UIColor.UCAColor.walletPageViewTransBtnPulseColor)
        
        pageHeight = pageHeight + termsLbl1.text!.height(withConstrainedWidth: Application.screenSize.width - 50, font: UIFont(name: Fonts().light, size: 16)!)
        
        
    }
    
    func myBtnTapped(sender: MyButton) {
        
        if(sender == addMoneyBtn){
            let required_str = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_FEILD_REQUIRD_ERROR_TXT")
            let error_money = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_ADD_CORRECT_DETAIL_TXT")
            
            let amount_str = Configurations.convertNumToEnglish(numStr: Utils.getText(textField: self.moneyTxtField.getTextField()!))

//            let moneyEntered = Utils.checkText(textField: self.moneyTxtField.getTextField()!) ? ((Utils.getText(textField: self.moneyTxtField.getTextField()!) != "0" && Utils.getText(textField: self.moneyTxtField.getTextField()!).isNumeric()) ? true: Utils.setErrorFields(textField: self.moneyTxtField.getTextField()!, error: error_money)) : Utils.setErrorFields(textField: self.moneyTxtField.getTextField()!, error: required_str)
//            
//            if(moneyEntered){
//                addMoneyToWallet()
//            }
            let moneyEntered = Utils.checkText(textField: self.moneyTxtField.getTextField()!) ? ((amount_str != "0" && amount_str.isNumeric()) ? true: Utils.setErrorFields(textField: self.moneyTxtField.getTextField()!, error: error_money)) : Utils.setErrorFields(textField: self.moneyTxtField.getTextField()!, error: required_str)
            
            if(moneyEntered){
                
                /* PAYMENT FLOW CHANGES */
                if(GeneralFunctions.getPaymentMethod(userProfileJson: self.userProfileJson) == "1"){
                    if(self.userProfileJson.get("ONLYDELIVERALL") == "Yes") // For only DeliverAll app
                    {
                        self.moneyTxtField.setText(text: "")
                        let addPaymentUv = GeneralFunctions.instantiateViewController(pageName: "AddPaymentUV") as! AddPaymentUV
                        addPaymentUv.walletAmountToBeAdd = amount_str
                        addPaymentUv.manageWalletUV = self
                        self.pushToNavController(uv: addPaymentUv)
                    }else
                    {
                        addMoneyToWallet(amount: amount_str)
                    }
                    
                }else if(GeneralFunctions.getPaymentMethod(userProfileJson: self.userProfileJson) == "2"){
                    
                    self.moneyTxtField.setText(text: "")
                    
                    let date = Date()
                    let nowDate:String = Utils.convertDateToFormate(date: date, formate: "yyyy-MM-dd HH:mm:ss")
                    let urlStr = "\(CommonUtils.PAYMENTLINK)amount=\(amount_str)&iUserId=\(GeneralFunctions.getMemberd())&UserType=\(Utils.appUserType)&vUserDeviceCountry=\(GeneralFunctions.getValue(key: Utils.DEFAULT_COUNTRY_KEY)!)&ccode=\(self.userProfileJson.get("vCurrencyPassenger"))&UniqueCode=\(nowDate)"
                    
                    self.webView.isHidden = false
                    self.webView.frame = self.view.bounds
                    self.webView.backgroundColor = UIColor.white
                    webView.delegate = self
                    self.contentView.addSubview(webView)
                    
                    self.activityIndicator = UIActivityIndicatorView.init(frame: CGRect(x:(self.webView.frame.width / 2) - 10, y:(self.webView.frame.height / 2) - 10, width: 20, height:20))
                    activityIndicator.style = .gray
                    activityIndicator.hidesWhenStopped = true
                    
                    self.contentView.addSubview(activityIndicator)
                    
                    let urlString = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    let url = URL.init(string: urlString!)
                    webView.loadRequest(URLRequest(url: url!))
                    
                }/* ........... */
                
            }
        }else if(sender == viewTransactionBtn){
            
            let transactionHistoryAllUv = GeneralFunctions.instantiateViewController(pageName: "TransactionHistoryUV") as! TransactionHistoryUV
            let transactionHistoryCreditUv = GeneralFunctions.instantiateViewController(pageName: "TransactionHistoryUV") as! TransactionHistoryUV
            let transactionHistoryDebitUv = GeneralFunctions.instantiateViewController(pageName: "TransactionHistoryUV") as! TransactionHistoryUV
            transactionHistoryAllUv.LIST_TYPE = "All"
            transactionHistoryCreditUv.LIST_TYPE = "Credit"
            transactionHistoryDebitUv.LIST_TYPE = "Debit"

            transactionHistoryAllUv.pageTabBarItem.title = self.generalFunc.getLanguageLabel(origValue: "ALL", key: "LBL_ALL").uppercased()
            transactionHistoryCreditUv.pageTabBarItem.title = self.generalFunc.getLanguageLabel(origValue: "Money In", key: "LBL_MONEY_IN").uppercased()
            transactionHistoryDebitUv.pageTabBarItem.title = self.generalFunc.getLanguageLabel(origValue: "Money Out", key: "LBL_MONEY_OUT").uppercased()
            
            let transactionHistoryTabUv = TransactionHistoryTabUV(viewControllers: [transactionHistoryAllUv, transactionHistoryCreditUv, transactionHistoryDebitUv], selectedIndex: 0)
            
            self.pushToNavController(uv: transactionHistoryTabUv)
//            (self.navigationDrawerController?.rootViewController as! UINavigationController).pushViewController(transactionHistoryTabUv, animated: true)
            
//            let transactionHistoryUv = GeneralFunctions.instantiateViewController(pageName: "TransactionHistoryUV") as! TransactionHistoryUV
//            self.pushToNavController(uv: transactionHistoryUv)
        }
    }

    func myLableTapped(sender: MyLabel) {
        if(sender == moneyLbl1){
            moneyTxtField.setText(text: Configurations.convertNumToEnglish(numStr: moneyLbl1.text!))
        }else if(sender == moneyLbl2){
            moneyTxtField.setText(text: Configurations.convertNumToEnglish(numStr: moneyLbl2.text!))
        }else if(sender == moneyLbl3){
            moneyTxtField.setText(text: Configurations.convertNumToEnglish(numStr: moneyLbl3.text!))
        }else if(sender == termsLbl2){
            let staticPageUV = GeneralFunctions.instantiateViewController(pageName: "StaticPageUV") as! StaticPageUV
            staticPageUV.STATIC_PAGE_ID = "4"
            self.pushToNavController(uv: staticPageUV)
        }
    }
    
    
    func addMoneyToWallet(amount:String){
        let parameters = ["type":"addMoneyUserWallet","iMemberId": GeneralFunctions.getMemberd(), "fAmount": amount, "UserType": Utils.appUserType]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                self.moneyTxtField.setText(text: "")
                if(dataDict.get("Action") == "1"){
                    
                    
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    let userProfileJson = response.getJsonDataDict().getObj(Utils.message_str)
                    
                    GeneralFunctions.saveValue(key: "user_available_balance_amount", value: userProfileJson.get("user_available_balance_amount") as AnyObject)   // Without Currency Symbole
                    
                    GeneralFunctions.saveValue(key: "user_available_balance", value: userProfileJson.get("user_available_balance") as AnyObject) // With Currency Symbole
                    
                    self.setData()

                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message1")))
                }else{
                    
                    if(dataDict.get(Utils.message_str) == "LBL_NO_CARD_AVAIL_NOTE"){
//                        LBL_NO_CARD_AVAIL_NOTE
                        self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "Add Card", key: "LBL_ADD_CARD"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "Cancel", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedIndex) in
                            
                            if(btnClickedIndex == 0){
                                
                                let paymentUV = GeneralFunctions.instantiateViewController(pageName: "PaymentUV") as! PaymentUV
                                self.pushToNavController(uv: paymentUV)
                            }
                            
                        })
                        
                        return
                    }
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get(Utils.message_str)))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
        })
    }
    
    func updateWalletAmount(){
        updateAmountIndicator.startAnimating()
        updateAmountIndicator.isHidden = false
        self.balanceVLbl.text = "  "
        let parameters = ["type":"GetMemberWalletBalance", "iUserId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            self.updateAmountIndicator.stopAnimating()
            self.updateAmountIndicator.isHidden = true
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
//                Utils.printLog(msgData: "dataDict:Balance:\(dataDict)")
                if(dataDict.get("Action") == "1"){
                    
                    GeneralFunctions.saveValue(key: "user_available_balance_amount", value: dataDict.get("user_available_balance_amount") as AnyObject)   // Without Currency Symbole
                    
                    GeneralFunctions.saveValue(key: "user_available_balance", value: dataDict.get("user_available_balance") as AnyObject) // With Currency Symbole
                    
                    if(self.userProfileJson.get("user_available_balance") != dataDict.get("MemberBalance")){
                        GeneralFunctions.saveValue(key: Utils.IS_WALLET_AMOUNT_UPDATE_KEY, value: "true" as AnyObject)
                    }
                    self.balanceVLbl.text = Configurations.convertNumToAppLocal(numStr: dataDict.get("MemberBalance"))
                }else{
                    self.balanceVLbl.text = "--"
                }
                
            }else{
                self.balanceVLbl.text = "--"
            }
        })
    }
    
    /* PAYMENT FLOW CHANGES */
    func closeWebView(){
        
        self.scrollView.scrollToTop()
        self.webView.isHidden = true
        self.webView.delegate = nil
        self.webView.removeFromSuperview()
        if(activityIndicator != nil){
            activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
        }
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        if(activityIndicator != nil){
            self.activityIndicator.startAnimating()
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if(activityIndicator != nil){
            self.activityIndicator.stopAnimating()
        }
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        let url : URL? = request.url
        
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        let urlString : String = url!.absoluteString
        
        if (urlString.contains(find: "sucess=1")){
            
            self.updateWalletAmount()
            self.closeWebView()
            
        }else if (urlString.contains(find: "sucess=0")){
            
            self.closeWebView()
            self.generalFunc.setError(uv: self)
            
        }
        
        return true
        
    }/* ............... */
}
