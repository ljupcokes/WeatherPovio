//
//  WeatherInfoController.swift
//  WeatherPovio
//
//  Created by Ljupco Gorgiev on 4/2/16.
//  Copyright © 2016 Developers. All rights reserved.
//

import UIKit

protocol WeatherInfoDelegate: class {
    func weatherInfoDidCancel(controller : WeatherInfoController)
}

class WeatherInfoController: UIViewController {
    
    @IBOutlet var lblCity : UILabel!
    @IBOutlet var lblTemperature : UILabel!
    @IBOutlet var lblHumidity : UILabel!
    @IBOutlet var lblDescription : UILabel!
    @IBOutlet var txtViewDescription : UITextView!
    
    var cityModel : CityModel!
    weak var delegate : WeatherInfoDelegate?
    
    @IBAction func cancel(sender : AnyObject) {
        navigationController?.popViewControllerAnimated(true)
        delegate?.weatherInfoDidCancel(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
        data_request()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func refreshUI() {
        //refresh all UI components on view
        lblCity.text = cityModel.cityName
        lblTemperature.text = String(cityModel.cityTemperature)
        lblHumidity.text = String(cityModel.cityHumidity)
        txtViewDescription.text = cityModel.cityDescription.capitalizedString
    }
    
    
    // MARK:  Data methods
    func data_request()
    {
        //request to api for selected city to get current info
        let url_to_request = String(format:"%@%@&appid=%@", kAddCity, cityModel.cityName as String, kAppID)
        let requestURL: NSURL = NSURL(string: url_to_request)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                
                do{
                    let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                    let cityID = jsonData.valueForKey(kCityId) as! Int
                    let cityName = jsonData.valueForKey(kCityName) as! String
                    let temp = jsonData.valueForKey(kKeyMain)?.valueForKey(kCityTemperature) as! Int - 273
                    let humidity = jsonData.valueForKey(kKeyMain)?.valueForKey(kCityHumidity) as! Int
                    let description = jsonData.valueForKey(kKeyWeather)?.objectAtIndex(0).valueForKey(kCityDescription) as! String
                    let cityDictionary : [String: String] = [kCityId : String(cityID), kCityName : cityName, kCityTemperature : String(temp), kCityHumidity : String(humidity), kCityDescription : description]
                    self.cityModel = CityModel(dictionary:cityDictionary)
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshUI()
                    }
                    
                    if let plist = PlistDataSwift(name:kPlistKey) {
                        do {
                            //update new dictionary values for selected city into local plist file
                            try plist.updateValuesToPlistFile(cityDictionary)
                        } catch {
                            print(error)
                        }
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        task.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
