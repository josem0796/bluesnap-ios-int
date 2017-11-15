//
//  ViewController.swift
//  RatesSwiftExample
//
////

import UIKit
import BluesnapSDK

class ViewController: UIViewController {
	
	// MARK: - Outlets
	
	@IBOutlet weak var currencyButton: UIButton!
	@IBOutlet weak var valueTextField: UITextField!
	@IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var withShippingSwitch: UISwitch!
    @IBOutlet weak var taxTextField: UITextField!
    @IBOutlet weak var resultTextView: UITextView!
    @IBOutlet weak var fullBillingSwitch: UISwitch!
    @IBOutlet weak var withEmailSwitch: UISwitch!
    @IBOutlet weak var coverAllView: UIView!
    @IBOutlet weak var coverAllLabel: UILabel!
    @IBOutlet weak var returningShopperSwitch: UISwitch!
    @IBOutlet weak var returningShopperIdLabel: UILabel!
    @IBOutlet var returningShopperIdTextField: UITextField!
    
    // MARK: private properties
    
    fileprivate var bsToken : BSToken?
    fileprivate var shouldInitKount = true
    fileprivate var sdkRequest: BSSdkRequest?
    fileprivate var hideCoverView : Bool = false
    final fileprivate let LOADING_MESSAGE = "Loading, please wait"
    final fileprivate let PROCESSING_MESSAGE = "Processing, please wait"
    final fileprivate let initialShippingCoutry = "US"
    final fileprivate let initialShippingState = "MA"
    final fileprivate let baseCurrency = "USD"
    final fileprivate let applePayMerchantIdentifier = "merchant.com.example.bluesnap"
    final fileprivate var returningShopperId : Int = 22061813
    final fileprivate var shopperId : Int? = nil


    // MARK: - UIViewController's methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		registerTapToHideKeyboard()
        
        resultTextView.text = ""
        
        // Example of using BSImageLibrary
        //if let img = BSImageLibrary.getFlag(countryCode: "US") {
        //}
 	}
	
	override func viewWillAppear(_ animated: Bool) {
        
        if bsToken == nil {
            initBsToken(returningShopper: returningShopperSwitch.isOn)
        }
		super.viewWillAppear(animated)
		self.navigationController?.isNavigationBarHidden = true
        if hideCoverView {
            coverAllView.isHidden = true
            hideCoverView = true
        }
        self.returningShopperIdLabel.isHidden = !returningShopperSwitch.isOn
        self.returningShopperIdTextField.isHidden = !returningShopperSwitch.isOn
        amountValueDidChange(valueTextField)
    }
	
	// MARK: - Dismiss keyboard
	
    func registerTapToHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        if valueTextField.isFirstResponder {
            valueTextField.resignFirstResponder()
        } else if taxTextField.isFirstResponder {
            taxTextField.resignFirstResponder()
        } else if self.returningShopperIdTextField.isFirstResponder {
            self.returningShopperIdTextField.resignFirstResponder()
        }
    }
    

	// MARK: - Actions
	
	@IBAction func convertButtonAction(_ sender: UIButton) {
        
        resultTextView.text = ""

        // Override the navigation name, so that the next screen navigation item will say "Cancel"
        let backItem = UIBarButtonItem()
        backItem.title = "Cancel"
        navigationItem.backBarButtonItem = backItem

        coverAllLabel.text = PROCESSING_MESSAGE
        coverAllView.isHidden = false
        hideCoverView = true
        
        DispatchQueue.main.async {
            // open the purchase screen
            self.fillSdkRequest()
            BlueSnapSDK.showCheckoutScreen(
                inNavigationController: self.navigationController,
                animated: true,
                sdkRequest: self.sdkRequest)
        }
    }
	
	@IBAction func currencyButtonAction(_ sender: UIButton) {
        
        coverAllLabel.text = LOADING_MESSAGE
        coverAllView.isHidden = false
        hideCoverView = true
        
        DispatchQueue.main.async {
            self.fillSdkRequest()
            BlueSnapSDK.showCurrencyList(
                inNavigationController: self.navigationController,
                animated: true,
                selectedCurrencyCode: self.sdkRequest!.priceDetails.currency,
                updateFunc: self.updateViewWithNewCurrency,
                errorFunc: {
                    self.showErrorAlert(message: "Failed to display currency List, please try again")
            })
        }
	}
	
	// MARK: - UIPopoverPresentationControllerDelegate
	
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		return UIModalPresentationStyle.none
	}
    
    // MARK: private methods
    
    /**
        If you have the shopper details, you can supply initial values to the BlueSnap purchasde flow.
        This is just an exmaple with hard-coded values.
        You can supply partial data as you have it.
    */
    private func setInitialShopperDetails() {
        
        sdkRequest?.billingDetails = BSBillingAddressDetails(email: "john@gmail.com", name: "John Doe", address: "333 elm st", city: "New York", zip: "532464", country: "US", state: "MA")

        if withShippingSwitch.isOn {
            sdkRequest?.shippingDetails = BSShippingAddressDetails(phone: "972-528-9999999", name: "Mary Doe", address: "333 elm st", city: "Boston", zip: "111222", country: initialShippingCoutry, state: initialShippingState)
        }
    }
    
    /**
     Show error pop-up
     */
    private func showErrorAlert(message: String) {
        let alert = createErrorAlert(title: "Oops", message: message)
        present(alert, animated: true, completion: nil)
    }

    private func createErrorAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in })
        alert.addAction(cancel)
        return alert
        //After you create alert, you show it like this: present(alert, animated: true, completion: nil)
    }

    /**
     Here we adjust the checkout details with the latest amounts from the fields on our view.
    */
    private func fillSdkRequest() {
        
        let amount = (valueTextField.text! as NSString).doubleValue
        let taxAmount = (taxTextField.text! as NSString).doubleValue
        let currency = currencyButton.titleLabel?.text ?? "USD"
        let priceDetails = BSPriceDetails(amount: amount, taxAmount: taxAmount, currency: currency)
        let withShipping = withShippingSwitch.isOn
        let fullBilling = fullBillingSwitch.isOn
        let withEmail = withEmailSwitch.isOn
        sdkRequest = BSSdkRequest(withEmail: withEmail, withShipping: withShipping, fullBilling: fullBilling, priceDetails: priceDetails, billingDetails: nil, shippingDetails: nil, purchaseFunc: self.completePurchase, updateTaxFunc: self.updateTax)
    }
    
    /**
     This function is called by the change currency screen when the user changes the currency.
     Here we update yhje checkout details and the fields in our view according tp the new currency.
    */
    private func updateViewWithNewCurrency(oldCurrency : BSCurrency?, newCurrency : BSCurrency?) {
        
        if let priceDetails = sdkRequest?.priceDetails {
            if let newCurrency = newCurrency {
                var oldRate: NSNumber! = 1.0
                if let oldCurrency = oldCurrency {
                    oldRate = oldCurrency.getRateNSNumber()
                }
                // convert the prices back to $
                priceDetails.amount = priceDetails.amount.doubleValue / oldRate.doubleValue as NSNumber
                priceDetails.taxAmount = priceDetails.taxAmount.doubleValue / oldRate.doubleValue as NSNumber
                
                priceDetails.currency = newCurrency.getCode()
                priceDetails.amount = priceDetails.amount.doubleValue * newCurrency.getRateNSNumber().doubleValue as NSNumber
                priceDetails.taxAmount = priceDetails.taxAmount.doubleValue * newCurrency.getRateNSNumber().doubleValue as NSNumber
            }

            valueTextField.text = String(format: "%.2f", CGFloat(priceDetails.amount ?? 0))
            taxTextField.text = String(format: "%.2f", CGFloat(priceDetails.taxAmount ?? 0))
            currencyButton.titleLabel?.text = priceDetails.currency
        }
    }
    
    /**
     This is the callback we pass to BlueSnap SDK; it will be called when all the shopper details have been
     enetered, and the secured payment details have been successfully submitted to BlueSnap server.
     In a real app, you would send the checkout details to your app server, which then would call BlueSnap API
     to execute the purchase.
     In this sample app we do it client-to-server, but this is not the way to do it in a real app.
     Note that after a transaction was created with the token, you need to clear it or generate a new one for the next transaction.
    */
    
    private func completePurchase(purchaseDetails: BSBaseSdkResult!) {
        
        if let paypalPurchaseDetails = purchaseDetails as? BSPayPalSdkResult {
            
            NSLog("PayPal transaction completed Successfully! invoice ID: \(paypalPurchaseDetails.payPalInvoiceId ?? "")")
            showThankYouScreen(errorText: nil)
            return // no need to complete purchase via BlueSnap API
        }
        
        hideCoverView = false
        coverAllView.isHidden = false
        coverAllLabel.text = PROCESSING_MESSAGE
       
        // The creation of BlueSnap Demo transaction here should be done in the merchant server!!!
        // This is just for demo purposes
        DispatchQueue.main.async {
            let demo = DemoTreansactions()
            var result: (success: Bool, data: String?) = (false, nil)
            if let applePayPurchaseDetails = purchaseDetails as? BSApplePaySdkResult {
                
                demo.createApplePayTransaction(
                    purchaseDetails: applePayPurchaseDetails,
                    bsToken: self.bsToken!,
                    completion: { success, data in
                        result.data = data
                        result.success = success
                        self.logResultDetails(result: result, purchaseDetails: applePayPurchaseDetails)
                        self.showThankYouScreen(result)
                })
                
            } else if let ccPurchaseDetails = purchaseDetails as? BSExistingCcSdkResult {
                
                let creditCard = ccPurchaseDetails.creditCard
                NSLog("CC Expiration: \(creditCard.getExpiration() )")
                NSLog("CC type: \(creditCard.ccType ?? "")")
                NSLog("CC last 4 digits: \(creditCard.last4Digits ?? "")")
                demo.createTokenizedTransaction(
                    purchaseDetails: ccPurchaseDetails,
                    bsToken: self.bsToken!,
                    completion: { success, data in
                        result.data = data
                        result.success = success
                        self.logResultDetails(result: result, purchaseDetails: ccPurchaseDetails)
                        self.showThankYouScreen(result)
                })
            } else if let ccPurchaseDetails = purchaseDetails as? BSCcSdkResult {
                
                let creditCard = ccPurchaseDetails.creditCard
                NSLog("CC Issuing country: \(creditCard.ccIssuingCountry ?? "")")
                NSLog("CC type: \(creditCard.ccType ?? "")")
                NSLog("CC last 4 digits: \(creditCard.last4Digits ?? "")")
                demo.createCreditCardTransaction(
                    purchaseDetails: ccPurchaseDetails,
                    bsToken: self.bsToken!,
                    completion: { success, data in
                        result.data = data
                        result.success = success
                        self.logResultDetails(result: result, purchaseDetails: ccPurchaseDetails)
                        self.showThankYouScreen(result)
                })
            }
        }
    }

    func showThankYouScreen(_ result: (success: Bool, data: String?)) {
        // Show success/fail screen
        NSLog("- - - - - - - - - - - - - -")
        if result.success == true {
            NSLog("BLS transaction created Successfully!\n\n\(result.data!)")
            showThankYouScreen(errorText: nil)
        } else {
            let errorText = result.data ?? ""
            NSLog("An error occurred trying to create BLS transaction.\n\n\(errorText)")
            showThankYouScreen(errorText: errorText)
        }
        hideCoverView = true
    }
    
    /**
    Called when value is typed in the amount field; this function is used to auto-calculate the tax value
     */
    @IBAction func amountValueDidChange(_ sender: UITextField) {
        
        let amount = (valueTextField.text! as NSString).doubleValue
        if (amount > 0 && withShippingSwitch.isOn) {
            let currency = currencyButton.titleLabel?.text ?? "USD"
            let priceDetails = BSPriceDetails(amount: amount, taxAmount: 0, currency: currency)
            updateTax(initialShippingCoutry, initialShippingState, priceDetails)
            taxTextField.text = "\(priceDetails.taxAmount ?? 0)"
        } else {
            taxTextField.text = "0"
        }
    }
    
    /**
     Called when the "with shipping" switch changes, to re-calculate the tax
    */
    @IBAction func withShippingValueChanged(_ sender: UISwitch) {
        amountValueDidChange(valueTextField)
    }
    
    /**
     Called when the "new shopper" switch changes, to create a new token with/without shopper
     */
    @IBAction func returningShopperValueChanged(_ sender: UISwitch) {
        
        self.returningShopperIdLabel.isHidden = !sender.isOn
        self.returningShopperIdTextField.isHidden = !sender.isOn
        
        coverAllView.isHidden = false
        hideCoverView = true
        initBsToken(returningShopper: sender.isOn)
    }

    /**
        This function is called to recalculate the tax amoutn based on the country/state.
        In this example we give tax only to US states, with 5% for all states, except NY which has 8%.
    */
    func updateTax(_ shippingCountry : String,
                       _ shippingState : String?,
                       _ priceDetails : BSPriceDetails) -> Void {

        var taxPercent: NSNumber = 0
        if shippingCountry.uppercased() == "US" {
            taxPercent = 5
            if let state = shippingState {
                if state == "NY" {
                    taxPercent = 8
                }
            }
        } else if shippingCountry.uppercased() == "CA" {
            taxPercent = 1
        }
        let newTax: NSNumber = priceDetails.amount.doubleValue * taxPercent.doubleValue / 100.0 as NSNumber
        NSLog("Changing tax amount from \(priceDetails.taxAmount) to \(newTax)")
        priceDetails.taxAmount = newTax
    }

    private func showThankYouScreen(errorText: String?) {
        
        // clear the used token
        bsToken = nil
        
        // Show thank you screen (ThankYouViewController)
        if let thankYouScreen = storyboard?.instantiateViewController(withIdentifier: "ThankYouViewController") as? ThankYouViewController {
            thankYouScreen.errorText = errorText
            self.navigationController?.pushViewController(thankYouScreen, animated: true)
        } else {
            resultTextView.text = "An error occurred trying to show the Thank You screen."
        }
    }

    private func logResultDetails(result: (success:Bool, data: String?), purchaseDetails: BSBaseSdkResult!) {
        
        NSLog("--------------------------------------------------------")
        NSLog("Result success: \(result.success)")
        
        NSLog(" amount=\(purchaseDetails.getAmount() ?? 0.0)")
        NSLog(" tax=\(purchaseDetails.getTaxAmount() ?? 0.0)")
        NSLog(" currency=\(purchaseDetails.getCurrency() ?? "")")
        
        if let purchaseDetails = purchaseDetails as? BSCcSdkResult {
            NSLog(" payment type= Credit Card")
            if let billingDetails = purchaseDetails.getBillingDetails() {
                NSLog("Result Data: Name:\(billingDetails.name ?? "")")
                if let zip = billingDetails.zip {
                    NSLog(" Zip code:\(zip)")
                }
                if let email = billingDetails.email {
                    NSLog(" Email:\(email)")
                }
                if self.fullBillingSwitch.isOn {
                    NSLog(" Street address:\(billingDetails.address ?? "")")
                    NSLog(" City:\(billingDetails.city ?? "")")
                    NSLog(" Country code:\(billingDetails.country ?? "")")
                    NSLog(" State code:\(billingDetails.state ?? "")")
                }
            }
            
            if let shippingDetails = purchaseDetails.getShippingDetails() {
                NSLog("Shipping Data: Name:\(shippingDetails.name ?? "")")
                NSLog(" Phone:\(shippingDetails.phone ?? "")")
                NSLog(" Zip code:\(shippingDetails.zip ?? "")")
                NSLog(" Street address:\(shippingDetails.address ?? "")")
                NSLog(" City:\(shippingDetails.city ?? "")")
                NSLog(" Country code:\(shippingDetails.country ?? "")")
                NSLog(" State code:\(shippingDetails.state ?? "")")
            }
            
        } else if let _ = purchaseDetails as? BSApplePaySdkResult {
            NSLog(" payment type= Apple Pay")
            NSLog("No extra data")
            
        } else if let purchaseDetails = purchaseDetails as? BSPayPalSdkResult {
            NSLog(" payment type= Pay Pal")
            NSLog("PayPal invoice ID:\(purchaseDetails.payPalInvoiceId ?? "")")
        }
        NSLog("--------------------------------------------------------")
    }
    


    // MARK: BS Token functions
    
    /**
     Create a test BS token and set it in BlueSnapSDK.
     In a real app, you would get the token from your app server.
     */
    func initBsToken(returningShopper: Bool) {
        
        // To simulate expired token use:
        //    bsToken = BSToken(tokenStr: "5e2e3f50e287eab0ba20dc1712cf0f64589c585724b99c87693a3326e28b1a3f_", serverUrl: bsToken?.getServerUrl())
        
        self.coverAllView.isHidden = false
        
        shopperId = returningShopper ? returningShopperId : nil
        
        BlueSnapSDK.createSandboxTestTokenWithShopperId(shopperId: shopperId, completion: { resultToken, errors in
            
            if let resultToken = resultToken {
                self.bsToken = resultToken
                BlueSnapSDK.initBluesnap(
                    bsToken: resultToken,
                    generateTokenFunc: self.generateAndSetBsToken,
                    initKount: self.shouldInitKount,
                    fraudSessionId: nil,
                    applePayMerchantIdentifier: self.applePayMerchantIdentifier,
                    merchantStoreCurrency: self.baseCurrency,
                    completion: { error in
                        DispatchQueue.main.async {
                            self.coverAllView.isHidden = true
                            self.hideCoverView = true
                        }
                })
            } else {
                NSLog("Failed to obtain Bluesnap Token")
                DispatchQueue.main.async {
                    self.coverAllView.isHidden = true
                    self.hideCoverView = true
                    self.showErrorAlert(message: "Failed to obtain BlueSnap Token, please try again.")
                }
            }
        })
    }
    
     /**
     Called by the BlueSnapSDK when token expired error is recognized.
     Here we generate and set a new token, so that when the action re-tries, it will succeed.
     */
    func generateAndSetBsToken(completion: @escaping (_ token: BSToken?, _ error: BSErrors?)->Void) {
        
        NSLog("Got BS token expiration notification!")
        
        BlueSnapSDK.createSandboxTestTokenWithShopperId(shopperId: shopperId, completion: { resultToken, errors in
            self.bsToken = resultToken
            NSLog("Got BS token= \(self.bsToken?.getTokenStr() ?? "")")
            DispatchQueue.main.async {
                completion(resultToken, errors)
            }
        })
    }
    
    @IBAction func returningShopperIdEditingDidEnd(_ sender: UITextField) {
        
        if sender.text != "\(self.returningShopperId)" {
            if let newShopperId = Int(sender.text ?? "") {
                self.returningShopperId = newShopperId
                if returningShopperSwitch.isOn {
                    coverAllView.isHidden = false
                    hideCoverView = true
                    initBsToken(returningShopper: true)
                }
            }
        }
    }
}

