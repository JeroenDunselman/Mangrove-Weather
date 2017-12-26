//
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
        
        if let imageName = self.weatherTypeIcons.object(forKey: self.weather.weatherTypeCurrent) as? String,
            let image = UIImage(named: imageName) as UIImage! {
            self.imageIconCurrent.image = image
        }
        
        self.labelWeatherDescription.text = self.weather.weatherTypeCurrent
    }
    
    func forecastDataAvailable() {
        //    activityIndicator?.stopAnimating()
        
        self.tableView?.isHidden = false
        tableView.dataSource = self
        
        self.tableView?.reloadData()
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

class ViewController: UIViewController {
    
    var settings = Settings()
    var vcSettings: SettingsViewController?
    let textCellIdentifier = "ForecastCell"
    let defaults = UserDefaults.standard
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelWeatherDescription: UILabel!
    @IBOutlet weak var imageIconCurrent: UIImageView!
    @IBOutlet weak var labelTemperature: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelMin: UILabel!
    @IBOutlet weak var labelMax: UILabel!
    
    
    @IBOutlet weak var labelToday: UILabel!
    @IBOutlet weak var buttonSettings: UIButton!
    
    var weather = WeatherService()
    func getData() {
        weather.view = self
        weather.location = settings.location
        weather.currentUnits = settings.temperatureUnitCelsius ? weather.units.Celsius : weather.units.Fahrenheit
        weather.getCurrentWeatherData()
        weather.getForecastWeatherData()
    }
    
    let weatherTypeIcons:NSDictionary = [
        "clear sky" : "01d.png",
        "few clouds" : "02d.png",
        "scattered clouds" : "03d.png",
        "broken clouds" : "04d.png",
        "shower rain" : "09d.png",
        "rain" : "10d.png",
        "light rain" : "10d.png",
        "thunderstorm" : "11d.png",
        "snow" : "13d.png",
        "mist" : "50d.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadSettings()
        self.getData()
        
        self.labelCity.text = settings.location
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        let day = Date().dayOfWeek()!
        let substring3 = day.subString(startIndex: 0, endIndex: 2)
        self.labelToday.text = "\(substring3) \(dateFormatter.string(from: Date()))"  //Date().description
        
        vcSettings = self.storyboard?.instantiateViewController(withIdentifier: "Settings") as? SettingsViewController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func buttonInfo(_ sender: Any) {
    }
    
    @IBAction func buttonSettings(_ sender: UIButton) {
        vcSettings?.settings = self.settings
        vcSettings?.navigationItem.title = "Settings"
        vcSettings?.navigationItem.leftBarButtonItem =
            UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(goBack))
        
        let navController = UINavigationController(rootViewController: vcSettings!)
        
        let transition = CATransition()
        transition.duration = 0.2
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        view.window!.layer.add(transition, forKey: kCATransition)
        
        present(navController, animated: false, completion: nil)
    }
    
    @objc func goBack(){
        
        //  update defaults
        self.settings = (vcSettings?.settings)!
        writeSettings()
        
        //  update view
        self.getData()
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings.numberOfDays // 7
    }
    
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath as IndexPath) as! ForecastTableViewCell
        let row = indexPath.row
        
        var dayDescription = ""
        if row == 0 {
            dayDescription = "Tomorrow"
        } else {
            let nextDate = Calendar.current.date(byAdding: .day, value: row, to: Date())
            dayDescription = (nextDate?.dayOfWeek()!)!
        }
        cell.labelDay?.text = dayDescription
        cell.labelMin?.text = self.weather.forecast[row].min
        cell.labelMax?.text = self.weather.forecast[row].max
        
        let type:String = (self.weather.forecast[row].type).lowercased()
        let imageName = self.weatherTypeIcons.object(forKey: type) as! String
        if let image = UIImage(named: imageName) as UIImage! {
            cell.imageIcon.image = image
        }
        
        return cell
    }
    
}

extension Date {
    
    func dayOfWeek() -> String? {
        //    if self == Date() { return "Today" }
        //    if self == Calendar.current.date(byAdding: .day, value: 1, to: self) { return "Tomorrow" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).capitalized
        // or use capitalized(with: locale)
    }
}

extension ViewController {
    
    func loadSettings() {
        
        if defaults.string(forKey: "Location") != ""  {
            settings.location = defaults.value(forKey: "Location")! as! String
        }
        
        if defaults.bool(forKey:"Temperature units Celsius") {
            settings.temperatureUnitCelsius = defaults.bool(forKey: "Temperature units Celsius")
        } else {
            settings.temperatureUnitCelsius = false
        }
        
        if defaults.integer(forKey:"Number of days Forecast") != 0 {
            settings.numberOfDays = defaults.integer(forKey: "Number of days Forecast")
        }
    }
    
    func writeSettings() {
        
        defaults.set(settings.location, forKey: "Location")
        defaults.set(settings.temperatureUnitCelsius, forKey: "Temperature units Celsius")
        defaults.set(settings.numberOfDays, forKey: "Number of days Forecast")
        defaults.synchronize()
        
        self.labelCity.text = settings.location
    }
}

