//
//  ViewController.swift
//  Tip
//
//  Created by V on 2/18/17.
//  Copyright © 2017 vova. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var billField: UITextField!
    @IBOutlet weak var tipLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var tipControl: UISegmentedControl!
    var defaultIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let defaults = UserDefaults.standard
        defaultIndex = defaults.integer(forKey: "defaultPercentage")
        tipControl.selectedSegmentIndex = defaultIndex
        let bill = defaults.double(forKey: "defaultBill")
        let locale = Locale.current
        billField.placeholder = locale.currencySymbol
        if bill != 0.0 {
            billField.text = String(format: "%.2f", bill)
        }
        billField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showSettings"?:
            let settingsViewController = segue.destination as! SettingsViewController
            settingsViewController.defaultIndex = defaultIndex
            settingsViewController.delegate = self
            //animation
            settingsViewController.view.alpha = 0
            self.view.alpha = 1
            UIView.animate(withDuration: 0.5, animations: {
                settingsViewController.view.alpha = 1
                self.view.alpha = 0
            })
        default:
            preconditionFailure("Unexpected seque identifier")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateTip(AnyClass.self)
        billField.becomeFirstResponder()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Optionally initialize the property to a desired starting value
        billField.resignFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onTap(_ sender: Any) {
        view.endEditing(true)
        billField.becomeFirstResponder()
    }

    @IBAction func percentageChanged(_ sender: Any) {
        calculateTip(AnyClass.self)
    }
    
    @IBAction func calculateTip(_ sender: Any) {
        let tipPercentages = [0.15, 0.20, 0.25]
        let bill = Double(billField.text!) ?? 0
        let tip = bill * tipPercentages[tipControl.selectedSegmentIndex]
        let total = bill + tip;
        tipLabel.text = formatCurrency(value: tip)
        if !((tipLabel.text?.isEmpty)!) {
                tipLabel.text = "Tip " + tipLabel.text!
        }
        totalLabel.text = formatCurrency(value: total)
        if !((totalLabel.text?.isEmpty)!) {
            totalLabel.text = "Total " + totalLabel.text!
        }
    }
    
    func formatCurrency(value: Double) -> String {
        if value == 0.0 {
            return ""
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 2;
        formatter.locale = Locale(identifier: Locale.current.identifier)
        let result = formatter.string(from: value as NSNumber);
        return result!;
    }
    
    
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let dotsCount = textField.text!.components(separatedBy: Locale.current.decimalSeparator!).count - 1
        if dotsCount > 0 && string == Locale.current.decimalSeparator! {
            return false
        }
        let length = textField.text!.lengthOfBytes(using: String.Encoding.utf8)
        if string != "" && length >= 3 && String(textField.text![textField.text!.index(textField.text!.endIndex, offsetBy: -3)]) == Locale.current.decimalSeparator! { // no more then two digits after point
            return false
        }
        if textField.text! == "0" && length == 1 && string != Locale.current.decimalSeparator! && String(textField.text![textField.text!.index(textField.text!.endIndex, offsetBy: -1)]) != Locale.current.decimalSeparator! { // only one leading 0
            textField.text! = string
            return false
        }
        let bill = Double(billField.text! + string) ?? 0
        if bill > 1000000000 { //limit 1 billion
            return false
        }
        return true
    }
}

