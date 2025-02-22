//
//  ChooseAddressUV.swift
//  PassengerApp
//
//  Created by ADMIN on 09/10/17.
//  Copyright © 2017 V3Cube. All rights reserved.
//

import UIKit

class ChooseAddressUV: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let generalFunc = GeneralFunctions()
    
    var userProfileJson:NSDictionary!
    
    var bookingType = ""
    
    var ufxSelectedVehicleTypeId = ""
    var ufxSelectedVehicleTypeName = ""
    var ufxSelectedLatitude = ""
    var ufxSelectedLongitude = ""
    var ufxSelectedAddress = ""
    var ufxSelectedQty = ""
    
    var ufXProviderFlow = false
    
    var ufxServiceItemDict:NSDictionary!
    
    var heightContainerList = [CGFloat]()
    
    var loaderView:UIView!
    
    var dataArrList = [NSDictionary]()
    var nextPage_str = 1
    var isLoadingMore = false
    var isNextPageAvail = false
    
    var errorLbl:MyLabel!
    
    var selectedAddressPosition = -1
    
    var cntView:UIView!
    
    var isDataSet = false
    
    var isSafeAreaSet = false
    
    var companyId = ""
    var iDriverID = ""
    
    var isDeliverAll = ""
    
    var selectedAddressID = ""
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.configureRTLView()
        
        GeneralFunctions.postNotificationSignal(key: ConfigPubNub.resumeInst_key, obj: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
        
        
        cntView = self.generalFunc.loadView(nibName: "ChooseAddressScreenDesign", uv: self, contentView: contentView)
        cntView.isHidden = true
        
        self.contentView.addSubview(cntView)
        
        self.addBackBarBtn()
        
        setData()
        
        self.tableView.delegate = self
        
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        
        self.tableView.tableFooterView = UIView()
        self.tableView.register(UINib(nibName: "ChooseAddressTVCell", bundle: nil), forCellReuseIdentifier: "ChooseAddressTVCell")
        
        
        let rightButton = UIBarButtonItem(image: UIImage(named: "ic_add_nav_bar")!, style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.openAddNewAddress))
        self.navigationItem.rightBarButtonItem = rightButton
        
        self.dataArrList.removeAll()
        self.heightContainerList.removeAll()
        
    }
    
    override func closeCurrentScreen(){
        
        if(ufXProviderFlow == true){
            self.performSegue(withIdentifier: "unwindToUFXCheckOut", sender: self)
            return
        }
        
        if companyId == ""
        {
            super.closeCurrentScreen()
        }else
        {
            self.selectedAddressPosition = -2
            self.performSegue(withIdentifier: "unwindToCheckOut", sender: self)
        }
    }
    
    override func viewDidLayoutSubviews() {
        if(isSafeAreaSet == false){
            
            if(cntView != nil){
                cntView.frame.size.height = cntView.frame.size.height + GeneralFunctions.getSafeAreaInsets().bottom
            }
            
            isSafeAreaSet = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(isDataSet == false){
            cntView.frame = self.contentView.frame
            cntView.isHidden = false
            isDataSet = true
            
            
            getDtata()
        }
    }
    
    func setData(){
        self.navigationItem.title = self.generalFunc.getLanguageLabel(origValue: "Select Address", key: "LBL_SELECT_ADDRESS_TITLE_TXT")
        self.title = self.generalFunc.getLanguageLabel(origValue: "Select Address", key: "LBL_SELECT_ADDRESS_TITLE_TXT")
    }

    func getDtata(){
        if(loaderView == nil){
            loaderView =  self.generalFunc.addMDloader(contentView: self.contentView)
            loaderView.backgroundColor = UIColor.clear
        }else if(loaderView != nil && isLoadingMore == false){
            loaderView.isHidden = false
        }
        
        if(self.errorLbl != nil){
            self.errorLbl.isHidden = true
        }
        
        let parameters = ["type": "DisplayUserAddress", "eUserType": Utils.appUserType, "iUserId": GeneralFunctions.getMemberd(), "page": self.nextPage_str.description, "iCompanyId": self.companyId, "PassengerLat": self.ufxSelectedLatitude, "PassengerLon": self.ufxSelectedLongitude, "iDriverId":self.iDriverID, "eSystem":isDeliverAll]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: false)
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    
                    let dataArr = dataDict.getArrObj(Utils.message_str)
                    
                    for i in 0 ..< dataArr.count{
                        let dataTemp = dataArr[i] as! NSDictionary
                        
                        self.dataArrList += [dataTemp]
                        
                        var address = ""
                        if(dataTemp.get("vAddressType") == ""){
                            address = "\(dataTemp.get("vBuildingNo")), \(dataTemp.get("vLandmark"))\n\(dataTemp.get("vServiceAddress"))"
                        }else{
                           address = "\(dataTemp.get("vAddressType"))\n\(dataTemp.get("vBuildingNo")), \(dataTemp.get("vLandmark"))\n\(dataTemp.get("vServiceAddress"))"
                        }

                        var addHeight = address.height(withConstrainedWidth: Application.screenSize.width - 90, font: UIFont(name: Fonts().light, size: 16)!)
                        addHeight = addHeight + 45
                        
                        if(dataTemp.get("eLocationAvailable").uppercased() == "NO"){
                            addHeight = addHeight + self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SERVICE_NOT_AVAIL_ADDRESS_RESTRICT").height(withConstrainedWidth: Application.screenSize.width - 60, font: UIFont(name: Fonts().light, size: 14)!)
                        }else{
                           addHeight = addHeight - 20
                        }
                        self.heightContainerList += [addHeight]
                    }
                    let NextPage = dataDict.get("NextPage")
                    
                    if(NextPage != "" && NextPage != "0"){
                        self.isNextPageAvail = true
                        self.nextPage_str = Int(NextPage)!
                        
                        self.addFooterView()
                    }else{
                        self.isNextPageAvail = false
                        self.nextPage_str = 0
                        
                        self.removeFooterView()
                    }
                    
                    self.tableView.reloadData()
                    
                }else{
                    if(self.isLoadingMore == false){
                        if(self.errorLbl != nil){
                            self.errorLbl.isHidden = false
                        }else{
                            self.errorLbl = GeneralFunctions.addMsgLbl(contentView: self.view, msg: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                        }
                        
                    }else{
                        self.isNextPageAvail = false
                        self.nextPage_str = 0
                        
                        self.removeFooterView()
                    }
                    
                }
                
                //                self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                
                
            }else{
                if(self.isLoadingMore == false){
                    self.generalFunc.setError(uv: self)
                    
                }
            }
            
            self.isLoadingMore = false
            self.loaderView.isHidden = true
            
        })
    }
    
    @objc func openAddNewAddress(){
        let addAddressUv = GeneralFunctions.instantiateViewController(pageName: "AddAddressUV") as! AddAddressUV
        addAddressUv.ufxSelectedLatitude = self.ufxSelectedLatitude
        addAddressUv.ufxSelectedLongitude = self.ufxSelectedLongitude
        addAddressUv.ufxSelectedAddress = self.ufxSelectedAddress
        addAddressUv.ufxSelectedVehicleTypeId = self.ufxSelectedVehicleTypeId
	    addAddressUv.companyId = self.companyId
        addAddressUv.unwindToChoose = true
        addAddressUv.ufXProviderFlow = self.ufXProviderFlow
        self.pushToNavController(uv: addAddressUv)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return self.dataArrList.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.heightContainerList[indexPath.item]
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChooseAddressTVCell", for: indexPath) as! ChooseAddressTVCell
        
        let dataTemp = self.dataArrList[indexPath.item]
        
        var address = ""
        if(dataTemp.get("vAddressType") == ""){
            address = "\(dataTemp.get("vBuildingNo")), \(dataTemp.get("vLandmark"))\n\(dataTemp.get("vServiceAddress"))"
        }else{
            address = "\(dataTemp.get("vAddressType"))\n\(dataTemp.get("vBuildingNo")), \(dataTemp.get("vLandmark"))\n\(dataTemp.get("vServiceAddress"))"
        }
        
        if((self.selectedAddressPosition != -1 && self.selectedAddressPosition == indexPath.item) || selectedAddressID == dataTemp.get("iUserAddressId")){
            cell.selectImgView.image = UIImage(named: "ic_select_true")
            
        }else{
            cell.selectImgView.image = UIImage(named: "ic_select_false")
        }
        
        GeneralFunctions.setImgTintColor(imgView: cell.selectImgView, color: UIColor.UCAColor.AppThemeColor)
        
        
        
        if(dataTemp.get("eLocationAvailable").uppercased() == "NO"){
            
            cell.containerViewBottomSpace.constant = 30
            cell.selImgCenter.constant = -5
            cell.addLblCenter.constant = -5
            cell.serviceNotAvailLbl.text = self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_SERVICE_NOT_AVAIL_ADDRESS_RESTRICT")
            cell.addressLbl.textColor = UIColor(hex: 0x999999)
            GeneralFunctions.setImgTintColor(imgView: cell.selectImgView, color: UIColor(hex: 0x999999))
        }else{
            cell.containerViewBottomSpace.constant = 0
            
            cell.selImgCenter.constant = 0
            cell.addLblCenter.constant = 0
            cell.serviceNotAvailLbl.text = ""
            cell.addressLbl.textColor = UIColor.black
            GeneralFunctions.setImgTintColor(imgView: cell.selectImgView, color: UIColor.UCAColor.AppThemeColor)
        }
        
        cell.addressLbl.text = address
        cell.addressLbl.fitText()
        
//        cell.containerView.layer.cornerRadius = 5
//        cell.containerView.masksToBounds = true
//        cell.containerView.layer.shadowOpacity = 0.5
//        cell.containerView.layer.shadowOffset = CGSize(width: 0, height: 3)
//        cell.containerView.layer.shadowColor = UIColor(hex: 0xe6e6e6).cgColor
        
        let padding = UIScreen.main.scale * 15
        
        let deleteImg = UIImage(named: "ic_delete")!.imageWithInsets(insets: UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding))
        cell.deleteImgView.image = deleteImg
        
        cell.deleteImgView.tag = indexPath.item
        
        let deleteTapGue = UITapGestureRecognizer()
        
        deleteTapGue.addTarget(self, action: #selector(self.deleteImgTapped(sender:)))
        
        cell.deleteImgView.isUserInteractionEnabled = true
        
        cell.deleteImgView.addGestureRecognizer(deleteTapGue)
        
        GeneralFunctions.setImgTintColor(imgView: cell.deleteImgView, color: UIColor.black)
        
        cell.selectionStyle = .none
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    @objc func deleteImgTapped(sender:UITapGestureRecognizer){
        
        self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "Do you want to delete this address?", key: "LBL_DELETE_CONFIRM_MSG"), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_CANCEL_TXT"), completionHandler: { (btnClickedId) in
            
            if(btnClickedId == 0){
                self.deleteAddress(iUserAddressId: self.dataArrList[sender.view!.tag].get("iUserAddressId"))
            }
        })
    }
    
    func deleteAddress(iUserAddressId:String){
        
        let parameters = ["type":"DeleteUserAddressDetail","iUserId": GeneralFunctions.getMemberd(), "eUserType": Utils.appUserType, "iUserAddressId": iUserAddressId, "PassengerLat": self.ufxSelectedLatitude, "PassengerLon": self.ufxSelectedLongitude]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    GeneralFunctions.saveValue(key: Utils.USER_PROFILE_DICT_KEY, value: response as AnyObject)
                    
                    self.generalFunc.setAlertMessage(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message1")), positiveBtn: self.generalFunc.getLanguageLabel(origValue: "", key: "LBL_BTN_OK_TXT"), nagativeBtn: "", completionHandler: { (btnClickedId) in
                        
                        
                        let userProfileJson = (GeneralFunctions.getValue(key: Utils.USER_PROFILE_DICT_KEY) as! String).getJsonDataDict().getObj(Utils.message_str)
                        
                        if(userProfileJson.get("ToTalAddress") != "" && userProfileJson.get("ToTalAddress") != "0"){
                            
                            self.dataArrList.removeAll()
                            self.heightContainerList.removeAll()
                            self.tableView.reloadData()
                            self.getDtata()
                        }else{
                            
                            if (self.ufXProviderFlow == true){
                                
                                GeneralFunctions.removeValue(key: "UFX_PROVIDER_FLOW_ADDRESS_DETAIS")
                                self.performSegue(withIdentifier: "unwindToUFXCheckOut", sender: self)
                                return
                            }
                            if self.companyId == ""
                            {
                                super.closeCurrentScreen()
                            }else
                            {
                                self.selectedAddressPosition = -1
                                self.performSegue(withIdentifier: "unwindToCheckOut", sender: self)
                            }
                        
                        }
                       
                    })
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
            
            
        })
    }
    
    func checkSelectedAddress(iUserAddressId:String, position:Int, address: String){
        
        let parameters = ["type":"Checkuseraddressrestriction","iUserId": GeneralFunctions.getMemberd(), "UserType": Utils.appUserType, "iUserAddressId": iUserAddressId, "iSelectVehicalId": self.ufxSelectedVehicleTypeId]
        
        let exeWebServerUrl = ExeServerUrl(dict_data: parameters, currentView: self.view, isOpenLoader: true)
        exeWebServerUrl.setDeviceTokenGenerate(isDeviceTokenGenerate: false)
        exeWebServerUrl.currInstance = exeWebServerUrl
        exeWebServerUrl.executePostProcess(completionHandler: { (response) -> Void in
            
            if(response != ""){
                let dataDict = response.getJsonDataDict()
                
                if(dataDict.get("Action") == "1"){
                    if(self.bookingType == "LATER"){
                    }else{
                        let mainScreenUv = GeneralFunctions.instantiateViewController(pageName: "MainScreenUV") as! MainScreenUV
                        mainScreenUv.ufxSelectedVehicleTypeId = self.ufxSelectedVehicleTypeId
                        mainScreenUv.ufxSelectedVehicleTypeName = self.ufxSelectedVehicleTypeName
                        mainScreenUv.ufxSelectedQty = self.ufxSelectedQty
                        mainScreenUv.ufxAddressId = self.dataArrList[position].get("iUserAddressId")
                        mainScreenUv.ufxSelectedLatitude = self.dataArrList[position].get("vLatitude")
                        mainScreenUv.ufxSelectedLongitude = self.dataArrList[position].get("vLongitude")
                        mainScreenUv.ufxServiceItemDict = self.ufxServiceItemDict
                        self.pushToNavController(uv: mainScreenUv)
                    }
                    
                }else{
                    self.generalFunc.setError(uv: self, title: "", content: self.generalFunc.getLanguageLabel(origValue: "", key: dataDict.get("message")))
                }
                
            }else{
                self.generalFunc.setError(uv: self)
            }
          
        })
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let dataTemp = self.dataArrList[indexPath.item]
        
        if(dataTemp.get("eLocationAvailable").uppercased() == "NO"){
            return
        }
        
        let address = "\(self.dataArrList[indexPath.item].get("vAddressType"))\n\(self.dataArrList[indexPath.item].get("vBuildingNo")), \(self.dataArrList[indexPath.item].get("vLandmark"))\n\(self.dataArrList[indexPath.item].get("vServiceAddress"))"
        
        let previousSelectedAddressPosition = self.selectedAddressPosition
        self.selectedAddressPosition = indexPath.item
        
        if(previousSelectedAddressPosition != -1){
            self.tableView.reloadRows(at: [IndexPath(row: previousSelectedAddressPosition, section: indexPath.section)], with: .none)
        }
        
        self.tableView.reloadRows(at: [IndexPath(row: indexPath.item, section: indexPath.section)], with: .none)

        if (ufXProviderFlow == true){
            
            GeneralFunctions.saveValue(key: "UFX_PROVIDER_FLOW_ADDRESS_DETAIS", value: self.dataArrList[indexPath.item])
            self.performSegue(withIdentifier: "unwindToUFXCheckOut", sender: self)
            return
        }
        
        if (self.companyId == "")
        {
            checkSelectedAddress(iUserAddressId: self.dataArrList[indexPath.item].get("iUserAddressId"), position: indexPath.item, address: address)
        }else
        {
            self.performSegue(withIdentifier: "unwindToCheckOut", sender: self)
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y;
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if (maximumOffset - currentOffset <= 15) {
            
            if(isNextPageAvail==true && isLoadingMore==false){
                
                isLoadingMore=true
                
                getDtata()
            }
        }
    }
    
    func addFooterView(){
        let loaderView =  self.generalFunc.addMDloader(contentView: self.tableView, isAddToParent: false)
        loaderView.backgroundColor = UIColor.clear
        loaderView.frame = CGRect(x:0, y:0, width: Application.screenSize.width, height: 80)
        self.tableView.tableFooterView  = loaderView
        self.tableView.tableFooterView?.isHidden = false
    }
    
    func removeFooterView(){
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.tableFooterView?.isHidden = true
    }
    
    
    @IBAction func unwindToChooseAddress(_ segue:UIStoryboardSegue) {
        
        if(segue.source.isKind(of: AddAddressUV.self)){
            self.dataArrList.removeAll()
            self.heightContainerList.removeAll()
            self.tableView.reloadData()
            getDtata()
        }
    }
}
