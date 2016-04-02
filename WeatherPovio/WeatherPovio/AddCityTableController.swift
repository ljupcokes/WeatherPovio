//
//  AddCityTableController.swift
//  WeatherPovio
//
//  Created by Ljupco Gorgiev on 4/2/16.
//  Copyright © 2016 Developers. All rights reserved.
//

import UIKit

protocol AddCityDelegate: class {
    func addCityDidDone(controller : AddCityTableController)
    func addCityDidCancel(controller : AddCityTableController)
}

class AddCityTableController: UITableViewController {
    
    @IBOutlet var nameCity : UITextField!
    
    var cityModel : CityModel!
    weak var delegate : AddCityDelegate?
    
    //
    @IBAction func cancel(sender : AnyObject) {
        delegate?.addCityDidCancel(self)
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func done(sender : AnyObject) {
        data_request()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // MARK:  Data methods
    func data_request()
    {
        //request to api for weather data for city which is added from textField
        let url_to_request = String(format:"%@%@&appid=%@", kAddCity, (nameCity.text?.capitalizedString)!, kAppID)
        let mainUrlRequest = url_to_request.stringByReplacingOccurrencesOfString("\\s", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: nil)
        let requestURL: NSURL = NSURL(string: mainUrlRequest)!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                do{
                    let jsonData:NSDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers ) as! NSDictionary
                    let errorCode = jsonData.valueForKey(kKeyCodError)?.integerValue
                    if errorCode == 404 {
                        //handle error from server Error: Not found city
                        let errorMessage = jsonData.valueForKey(kMessageError) as! String
                        print(errorMessage)
                        return
                    }
                    let cityID = jsonData.valueForKey(kCityId) as! Int
                    let cityName = jsonData.valueForKey(kCityName) as! String
                    let temp = jsonData.valueForKey(kKeyMain)?.valueForKey(kCityTemperature) as! Int - 273
                    let humidity = jsonData.valueForKey(kKeyMain)?.valueForKey(kCityHumidity) as! Int
                    let description = jsonData.valueForKey(kKeyWeather)?.objectAtIndex(0).valueForKey(kCityDescription) as! String
                    let cityDictionary : [String: String] = [kCityId : String(cityID), kCityName : cityName, kCityTemperature : String(temp), kCityHumidity : String(humidity), kCityDescription : description]
                    self.cityModel = CityModel(dictionary: cityDictionary)
                    
                    if let plist = PlistDataSwift(name:kPlistKey) {
                        let tmpArray  = plist.getMutableArrayPlistFile()!
                        for cityDictionary in tmpArray {
                            let cityTempModel = CityModel(dictionary:cityDictionary as! [String : String])
                            if self.cityModel.cityId == cityTempModel.cityId {
                                return
                            }
                        }
                        
                        do {
                            //add new dictionary values for new city into local plist file
                            try plist.addValuesToPlistFile(cityDictionary)
                        } catch {
                            print(error)
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.navigationController?.popViewControllerAnimated(true)
                        self.delegate?.addCityDidDone(self)
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

