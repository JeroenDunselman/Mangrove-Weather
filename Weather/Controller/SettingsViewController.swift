//
//  SettingsViewController
//
//  Created by Jeroen Dunselman on 25/11/2017.
//  Copyright © 2017 Jeroen Dunselman. All rights reserved.
//
import UIKit

class SettingsViewController: UIViewController {

  var settings: Settings?
  var pickerData: [String] = []
  var currentRow: Int = 0
  
  let textCellIdentifier = "SettingsCell"
  
  @IBOutlet var tableView: UITableView!
  @IBOutlet weak var valuePicker: UIPickerView!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.valuePicker.delegate = self
    self.valuePicker.dataSource = self
    
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.tableView.reloadData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func presentAlert() {
    let alertController = UIAlertController(title: "Location", message: "Enter the city you want to receive the forecast for", preferredStyle: .alert)
    
    let confirmAction = UIAlertAction(title: "OK", style: .default) { (_) in
      if let field = alertController.textFields?[0] {
        self.settings?.location = field.text!
        self.tableView.reloadData()
      } else {
        // user did not fill field
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
    
    alertController.addTextField { (textField) in
      textField.placeholder = "Location"
    }
    
    alertController.addAction(confirmAction)
    alertController.addAction(cancelAction)
    
    self.present(alertController, animated: true, completion: nil)
  }
  
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {

  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row]
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
  {
    if currentRow == 1 {
      self.settings?.temperatureUnitFahrenheit = row == 0 ? false : true
    }
    else if currentRow == 2 {
      self.settings?.numberOfDays = row + 1
    }
    self.tableView.reloadData()
  }
}

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var pickerRow = 0
    currentRow = indexPath.row
    self.valuePicker.isHidden = false
    
    if currentRow == 0 {
      //location
      self.valuePicker.isHidden = true
      self.presentAlert()
    }
      
    else if currentRow == 1{
      pickerData = ["Celsius", "Fahrenheit"]
      pickerRow = (self.settings?.temperatureUnitFahrenheit)! ? 1 : 0
    }
      
    else if currentRow == 2 {
      //number of days in forecast
      let len = 7
      let rng: [String] = (1...len).enumerated().flatMap {String($0.element)}
      
      pickerData = rng
      pickerRow = (self.settings?.numberOfDays)! - 1
    }
    
    if !self.valuePicker.isHidden {
      self.valuePicker.reloadAllComponents()
      self.valuePicker.selectRow(pickerRow, inComponent: 0, animated: true)
    }
    
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let settingsCell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier) as! SettingsTableViewCell
    let row = indexPath.row
    
    if row == 0 {
      settingsCell.labelKey?.text = NSLocalizedString("Location", comment: "")
      settingsCell.labelValue?.text = settings?.location
    }
    
    if row == 1 {
      settingsCell.labelKey?.text = NSLocalizedString("Unit", comment: "")
      settingsCell.labelValue?.text = (settings?.temperatureUnitFahrenheit)! ? "Fahrenheit" : "Celsius"
    }
    
    if row == 2 {
      settingsCell.labelKey?.text = NSLocalizedString("Number of days", comment: "")
      settingsCell.labelValue?.text = settings?.numberOfDays.description
    }
    
    return settingsCell
  }
  
}
