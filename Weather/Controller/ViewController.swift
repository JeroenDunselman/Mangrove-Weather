
//  ViewController.swift
//  Weather
//
//  Created by Jeroen Dunselman on 22/12/2017.
//  Copyright © 2017 Jeroen Dunselman. All rights reserved.
//

import UIKit

protocol WeatherView: NSObjectProtocol {
  func currentDataAvailable()
  func forecastDataAvailable()
}

extension ViewController: WeatherView {
  
  func currentDataAvailable() {
    
    self.labelTemperature.text = self.weather.tempCurrent
    self.labelMax.text = self.weather.tempTodayMax
    self.labelMin.text = self.weather.tempTodayMin
    
    let imageName = iconNameFor(id: self.weather.weatherTypeCurrentId)
    let image = UIImage(named: imageName)
    self.imageIconCurrent.image = image
    self.labelWeatherDescription.text = self.weather.weatherTypeCurrent
  }
  
  func forecastDataAvailable() {
    
    self.tableView?.isHidden = false
    tableView.dataSource = self
    
    self.tableView?.reloadData()
  }
  
}

class ViewController: UIViewController {
  
  var navController: UINavigationController?
  
  let defaults = UserDefaults.standard
  var settings = Settings()
  var vcSettings: SettingsViewController?
  @IBOutlet weak var buttonSettings: UIButton!
  
  var weather = WeatherService()
  let textCellIdentifier = "ForecastCell"
  @IBOutlet var tableView: UITableView!
  
  @IBOutlet weak var labelCity: UILabel!
  @IBOutlet weak var labelWeatherDescription: UILabel!
  @IBOutlet weak var imageIconCurrent: UIImageView!
  @IBOutlet weak var labelTemperature: UILabel!
  
  @IBOutlet weak var labelToday: UILabel!
  @IBOutlet weak var labelDateCurrent: UILabel!
  
  @IBOutlet weak var labelMin: UILabel!
  @IBOutlet weak var labelMax: UILabel!
  

  
  func getData() {
    weather.view = self
    weather.location = settings.location
    weather.currentUnits = settings.temperatureUnitFahrenheit ? weather.units.Fahrenheit : weather.units.Celsius
    weather.getCurrentWeatherData()
    weather.getForecastWeatherData()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.loadSettings()
    vcSettings = self.storyboard?.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController

    self.initializeView()
    self.getData()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
 
  
  func initializeView() {
    
    self.labelCity.text = settings.location
    
    let day = Date().dayOfWeek()!
    let dayDescription = day.subString(startIndex: 0, endIndex: 2)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMM"
    let dateDescription = dateFormatter.string(from: Date())
    self.labelDateCurrent.text = "\(dayDescription) \(dateDescription)"
    self.labelToday.text = NSLocalizedString("Today", comment: "")
    
    self.labelWeatherDescription.text = ""
    self.labelTemperature.text = ""
    self.labelMax.text = ""
    self.labelMin.text = ""
    
    let image = UIImage(named: "unavailable")
    self.imageIconCurrent.image = image
    
    self.weather.forecast = []
    self.tableView.reloadData()
  }
  
  @IBAction func buttonInfo(_ sender: Any) {
    
    let vcInfo = self.storyboard?.instantiateViewController(withIdentifier: "Info")
    vcInfo?.navigationItem.title = NSLocalizedString("Information", comment: "")
    vcInfo?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissInfo))

    navController = UINavigationController(rootViewController: vcInfo!)
    presentDetail(navController!)
  }
  
  @IBAction func buttonSettings(_ sender: UIButton) {
    vcSettings?.settings = self.settings
    vcSettings?.navigationItem.title = NSLocalizedString("Settings", comment: "")
    vcSettings?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(dismissSettings))
    
    navController = UINavigationController(rootViewController: vcSettings!)
    presentDetail(navController!)
  }
  
  @objc func dismissSettings(){
    
    //  update defaults
    self.settings = (vcSettings?.settings)!
    writeSettings()
    
    //  update view
    self.initializeView()
    self.getData()
    
    dismiss()
  }
  
  func presentDetail(_ viewControllerToPresent: UIViewController) {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = kCATransitionPush
    transition.subtype = kCATransitionFromRight
    self.view.window!.layer.add(transition, forKey: kCATransition)
    
    present(viewControllerToPresent, animated: false)
  }
  
  @objc func dismissInfo() {
    dismiss()
  }
  
  func dismiss() {
    let transition = CATransition()
    transition.duration = 0.25
    transition.type = kCATransitionPush
    transition.subtype = kCATransitionFromLeft
    self.navController?.view.window!.layer.add(transition, forKey: kCATransition)
    dismiss(animated: false)
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return min(self.settings.numberOfDays, self.weather.forecast.count)
  }
  
  internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath) as! ForecastTableViewCell
    let row = indexPath.row
    
    var dayDescription = ""
    if row == 0 {
      dayDescription = NSLocalizedString("Tomorrow", comment: "")
    } else {
      let nextDate = Calendar.current.date(byAdding: .day, value: row + 1, to: Date())
      dayDescription = (nextDate?.dayOfWeek()!)!
    }
    cell.labelDay?.text = dayDescription
    
    cell.labelMin?.text = self.weather.forecast[row].min
    cell.labelMax?.text = self.weather.forecast[row].max
    
    let weatherType:Int = self.weather.forecast[row].typeId
    let imageName = iconNameFor(id: weatherType)
    if let image = UIImage(named: imageName) as UIImage! {
      cell.imageIcon.image = image
    }
    
    return cell
  }
  
  func iconNameFor(id: Int) -> String {
//    http://openweathermap.org/weather-conditions
    if id >= 200 || id < 300 { return "storm.png"}
    if id >= 300 || id < 800 { return "rain.png"}
    if id == 800             { return "sun.png"}
    if id >= 801 || id < 900 { return "clouds.png"}
    return ""
  }
  
}

extension Date {
  
  func dayOfWeek() -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    return dateFormatter.string(from: self).capitalized
  }
}

extension ViewController {
  
  func loadSettings() {

    if let location = defaults.string(forKey: "Location") as String! {
      settings.location = location
    }
    
    if defaults.integer(forKey:"Number of days Forecast") != 0 {
      settings.numberOfDays = defaults.integer(forKey:"Number of days Forecast")
    }
    
    settings.temperatureUnitFahrenheit = defaults.bool(forKey:"Temperature units Fahrenheit")
  }
  
  func writeSettings() {
    
    defaults.set(settings.location, forKey: "Location")
    defaults.set(settings.temperatureUnitFahrenheit, forKey: "Temperature units Fahrenheit")
    defaults.set(settings.numberOfDays, forKey: "Number of days Forecast")
    defaults.synchronize()
    
    self.labelCity.text = settings.location
  }
}

extension String {
  func subString(startIndex: Int, endIndex: Int) -> String {
    let end = (endIndex - self.count) + 1
    let indexStartOfText = self.index(self.startIndex, offsetBy: startIndex)
    let indexEndOfText = self.index(self.endIndex, offsetBy: end)
    let substring = self[indexStartOfText..<indexEndOfText]
    return String(substring)
  }
}

