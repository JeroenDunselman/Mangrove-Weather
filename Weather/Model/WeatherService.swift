//
//  WeatherService.swift
//  Weather
//
//  Created by Jeroen Dunselman on 24/12/2017.
//  Copyright © 2017 Jeroen Dunselman. All rights reserved.
//

import Foundation
import Alamofire

class WeatherService {
  
  //  url for weather forecast
  private let openWeatherMapAPIKey = "f253a82b395b623b4473abb0ba4804c5"
  private let urlForecast = "http://api.openweathermap.org/data/2.5/forecast/daily"
  private let urlCurrent = "http://api.openweathermap.org/data/2.5/weather"
  
  private var _weatherTypeCurrentDescription: String?
  private var _weatherTypeCurrentId: Int?
  private var _tempCurrent: String?
  private var _tempTodayMax: String?
  private var _tempTodayMin: String?
  private var _units: String?
  
  //  expose
  var view:WeatherView?
  
  public var location = "Rotterdam"
  public let units = (Celsius: "metric", Fahrenheit: "imperial")
  public var currentUnits = "metric"
  
  var forecast:[(min: String, max: String, type: String, typeId: Int)] = []
  
  var weatherTypeCurrent: String {
    return _weatherTypeCurrentDescription ?? ""
  }
  
  var weatherTypeCurrentId: Int {
    return _weatherTypeCurrentId ?? 0
  }
  
  var tempCurrent: String {
    return "\(_tempCurrent ?? "") °"
  }
  
  var tempTodayMax: String {
    return _tempTodayMax ?? ""
  }
  
  var tempTodayMin: String {
    return _tempTodayMin ?? ""
  }
  
  func getCurrentWeatherData() {
    let path = "\(urlCurrent)?q=\(location)&appid=\(openWeatherMapAPIKey)&units=\(currentUnits)"
    let urlString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let url = NSURL(string: urlString!)
    
    let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
      DispatchQueue.main.async {
        self.extractCurrentData(weatherData: data! as NSData)
      }
    }
    
    task.resume()
  }
  
  func extractCurrentData(weatherData: NSData)  {
    let json = try? JSONSerialization.jsonObject(with: weatherData as Data, options: []) as! NSDictionary
    
    if json != nil {
      if let main = json!["main"] as? NSDictionary {
        
        if let currentTemp = main.object(forKey: "temp") as? Double {
          let singleDecimal = (currentTemp*10).rounded()/10
          _tempCurrent = String(singleDecimal)
        }
        
        if let minTemp = main.object(forKey: "temp_min") as? Double {
          _tempTodayMin = String(Int(minTemp.rounded()))
        }
        
        if let maxTemp = main.object(forKey: "temp_max") as? Double {
          _tempTodayMax = String(Int(maxTemp.rounded()))
        }
        
        if let weatherTypes = json!["weather"] as? [NSDictionary], let weather = weatherTypes[0] as NSDictionary!,
          let description = weather.object(forKey: "description") as? String,
          let typeId = weather.object(forKey: "id") as? Int
        {
          _weatherTypeCurrentDescription = description
          _weatherTypeCurrentId = typeId
        }
        self.view?.currentDataAvailable()
      }
      
    }
    
  }
  
  func getForecastWeatherData() {
    let path = "\(urlForecast)?q=\(location)&appid=\(openWeatherMapAPIKey)&units=\(currentUnits)"
    let urlString = path.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    let url = NSURL(string: urlString!)
    
    let task = URLSession.shared.dataTask(with: url! as URL) { (data, response, error) in
      DispatchQueue.main.async {
        self.extractForecastData(weatherData: data! as NSData)
      }
    }
    
    task.resume()
  }
  
  func extractForecastData(weatherData: NSData)  {
    forecast = []
    let json = try? JSONSerialization.jsonObject(with: weatherData as Data, options: []) as! NSDictionary
    
    if json != nil {
      
      if let list = json!["list"] as? [NSDictionary] {
        var min = "Min n.a."
        var max = "Max n.a."
        var weather = ""
        var id = 0
        for i in 0..<list.count {
          if let temp = list[i].object(forKey: "temp") as? NSDictionary {
            
            if let tempMin = temp.object(forKey: "min") as? Double { // {
              min  = String(Int(tempMin.rounded()))
            }
            
            if let tempMax = temp.object(forKey: "max") as? Double {
              max = String(Int(tempMax.rounded()))
            }
          }
          
          if let weatherTypes = list[i].object(forKey: "weather") as? [NSDictionary], let weatherData = weatherTypes[0] as NSDictionary!, let description = weatherData.object(forKey: "main") as? String,
            let typeId = weatherData.object(forKey: "id") as? Int {
            weather = description
            id = typeId
          }
          
          forecast.append((min, max, weather, id))
        }
        
        self.view?.forecastDataAvailable()
      }
    }
  }
  
  
  
  
}
