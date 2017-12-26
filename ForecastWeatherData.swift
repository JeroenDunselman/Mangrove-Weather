//
//  ForecastWeatherData.swift
//
//  Created by Jeroen Dunselman on 18/12/2016.
//  Copyright © 2016 Jeroen Dunselman. All rights reserved.
//

import Foundation
import Alamofire

class ForecastWeatherData {
  var list:[NSDictionary] = []
  var view:WeatherView?
    //url for weather forecast
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/forecast/daily"
    private let openWeatherMapAPIKey = "f253a82b395b623b4473abb0ba4804c5"
//    openweathermap.org/data/2.5/forecast/daily?q=Utrecht&appid=
    var lat: String?
    var lon: String?
    private var _cityName: String?
    
    private var _temp: String?
    private var _weather: String?
    typealias JSONStandard = Dictionary<String, AnyObject>
    
    var weatherDays : NSArray?
    var weatherData: [NSDictionary] = Array()
    
    var cityName: String {
        return _cityName ?? "Location Unknown"
    }
    
    var temp: String {
        return _temp ?? "0 °C"
    }
    
    var weather: String {
        return _weather ?? "Weather Invalid"
    }
    
    func setCoordinates(lat:String, lon:String) {
        self.lat = lat
        self.lon = lon
    }
    
    func downloadData(completed: @escaping ()-> ()) {
        let url = "\(openWeatherMapBaseURL)?lat=\(self.lat!)&lon=\(self.lon!)&APIKEY=\(openWeatherMapAPIKey)&units=metric&cnt=7&"
        Alamofire.request(url).responseJSON(
            completionHandler: {
                response in
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data!, options: []) as! JSONStandard
                    if let list = json["list"] as? [NSDictionary] {
                        for day in list {
                            
                            let weatherArray = day["weather"] as? [NSDictionary]
                            let weather = weatherArray?[0]
                            let weatherType = weather?["main"] as! String
                            let weatherDesc = weather?["description"] as! String
                            
                            let temperatureDict = day["temp"] as? NSDictionary
                            let dayTemperature = String(format: "%.0f°",temperatureDict?["day"] as! Double)
                            
                            let dayDict = ["Temp":dayTemperature, "Desc":weatherDesc, "Type":weatherType]
                            self.weatherData.append(dayDict as NSDictionary)
                        }
                        self.weatherDays = list as NSArray?
                    }
                    if let city = json["city"] as? NSDictionary {
                        self._cityName = city["name"] as? String
                    }
                   
                } catch let error as NSError {
                    print("Failed to load: \(error.localizedDescription)")
                }
        })
    }
  
  
  func extractData(weatherData: NSData)  {
    let json = try? JSONSerialization.jsonObject(with: weatherData as Data, options: []) as! NSDictionary
    
    if json != nil {
      if let main = json!["list"] as? [NSDictionary] {
//        print(main)
//        return main
        list = main
        self.view?.forecastDataAvailable()
      }

    }
//    return []
  }
}


