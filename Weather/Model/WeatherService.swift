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

  private var _weatherTypeCurrent: String?
  private var _tempCurrent: String?
  private var _tempTodayMax: String?
  private var _tempTodayMin: String?
  private var _units: String?
  
  //  expose
  var view:WeatherView?
  
  public var location = "Rotterdam"
  public let units = (Celsius: "metric", Fahrenheit: "imperial")
  public var currentUnits = "metric"
  
  var forecast:[(min: String, max: String, type: String)] = []
  
  var weatherTypeCurrent: String {
    return _weatherTypeCurrent ?? ""
  }
  
  var tempCurrent: String {
    return _tempCurrent ?? "current n.a."
  }
  
  var tempTodayMax: String {
    return _tempTodayMax ?? "max n.a."
  }
  
  var tempTodayMin: String {
    return _tempTodayMin ?? "min n.a."
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
          _tempCurrent = String(Int(currentTemp))
        }
        
        if let minTemp = main.object(forKey: "temp_min") as? Double {
          _tempTodayMin = String(Int(minTemp))
        }
        
        if let maxTemp = main.object(forKey: "temp_max") as? Double {
          _tempTodayMax = String(Int(maxTemp))
        }
        
        if let weatherTypes = json!["weather"] as? [NSDictionary], let weather = weatherTypes[0] as NSDictionary!, let desc = weather.object(forKey: "description") as? String {
                          print(desc, "hiero")
              _weatherTypeCurrent = desc
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
        var descMin = "Min n.a."
        var descMax = "Max n.a."
        var descWeather = ""
        for i in 0..<list.count {
          if let temp = list[i].object(forKey: "temp") as? NSDictionary {
            print(temp)
            
            if let min = temp.object(forKey: "min") as? Double { // {
              descMin  = String(Int(min))
            }
            if let max = temp.object(forKey: "max") as? Double {
              descMax = String(Int(max))
            }
            
          }
          
          if let weatherTypes = list[i].object(forKey: "weather") as? [NSDictionary], let weather = weatherTypes[0] as NSDictionary!, let desc = weather.object(forKey: "main") as? String {
                        print(desc, "hiero")
            descWeather = desc
          }
          
          forecast.append((descMin, descMax, descWeather))
        }
        
        self.view?.forecastDataAvailable()
      }
    }
  }
  
}
