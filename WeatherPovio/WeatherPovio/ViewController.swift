//
//  ViewController.swift
//  WeatherPovio
//
//  Created by Ljupco Gorgiev on 4/1/16.
//  Copyright © 2016 Developers. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, AddCityDelegate, WeatherInfoDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var citiesArray : NSMutableArray = []
    let plist = PlistDataSwift(name:kPlistKey)
    var refreshControl: UIRefreshControl!
    var cityModel : CityModel!
    
    // MARK:  Delegate methods from  AddCityTableController class
    func addCityDidCancel(controller : AddCityTableController){
        //        refresh()
    }
    
    func addCityDidDone(controller: AddCityTableController) {
        refresh()
    }
    
    // MARK:  Delegate methods from  WeatherInfoController class
    func weatherInfoDidCancel(controller: WeatherInfoController) {
        refresh()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshController()
        refresh()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func addRefreshController() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string:kPullToRefreshMessage)
        self.refreshControl.addTarget(self, action: "refresh", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(self.refreshControl)
    }
    
    func refresh (){
        // Code to reload new data and refresh tableView
        readLocalData()
        data_request()
        self.refreshControl.endRefreshing()
    }
    
    
    // MARK:  UITableViewDelegate Methods
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Value2, reuseIdentifier: nil)
        
        let cityDictionary : [String : String] = citiesArray[indexPath.row] as! Dictionary
        cityModel = CityModel(dictionary: cityDictionary as NSDictionary as! [String : String])
        cell.textLabel?.text = cityModel.cityName
        cell.textLabel?.font = UIFont.boldSystemFontOfSize(14.0)
        cell.textLabel?.textAlignment = .Left
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell.detailTextLabel?.text = String(cityModel.cityTemperature)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let secondViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WeatherInfoController") as! WeatherInfoController
        let cityDictionary : [String : String] = citiesArray[indexPath.row] as! Dictionary
        secondViewController.cityModel = CityModel(dictionary: cityDictionary)
        secondViewController.delegate = self;
        self.navigationController!.pushViewController(secondViewController, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if (plist != nil) {
                //code for remove dictionary from plist file
                let cityDictionary : [String : String] = citiesArray[indexPath.row] as! Dictionary
                do {
                    try plist!.removeDataFromPlistFile(cityDictionary)
                    
                    //remove dictionary form global araray and delete row without animation from tableView
                    citiesArray.removeObjectAtIndex(indexPath.row)
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                } catch {
                    print(error)
                }
            }
        }
    }
    
    
    // MARK:  Data methods
    func readLocalData() {
        if (plist != nil) {
            //read local data from plist file and fil global array
            citiesArray = plist!.getMutableArrayPlistFile()!
        } else {
            print("Unable to get Plist")
        }
    }
    
    func data_request()
    {
        //request to api for weather data for several cities
        let url_to_request = String(format:"%@%@&units=metric&appid=%@", kListCities, self.getAllCitiesID(), kAppID)
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
                    let listOfCities = jsonData.valueForKey(kKeyList) as! NSArray
                    let citiesTempArray : NSMutableArray = []
                    for cityDictionary in listOfCities {
                        //new weather data for each city added to temp array
                        let cityID = cityDictionary.valueForKey(kCityId) as! Int
                        let cityName = cityDictionary.valueForKey(kCityName) as! String
                        let temp = cityDictionary.valueForKey(kKeyMain)?.valueForKey(kCityTemperature) as! Int
                        let humidity = cityDictionary.valueForKey(kKeyMain)?.valueForKey(kCityHumidity) as! Int
                        let description = cityDictionary.valueForKey(kKeyWeather)?.objectAtIndex(0).valueForKey(kCityDescription) as! String
                        let cityTempDictionary : [String: String] = [kCityId : String(cityID), kCityName : cityName, kCityTemperature : String(temp), kCityHumidity : String(humidity), kCityDescription : description]
                        citiesTempArray.addObject(cityTempDictionary)
                    }
                    
                    if (self.plist != nil) {
                        do {
                            //save new weather data from temp array into local plist file
                            try self.plist!.addArrayToPlistFile(citiesTempArray)
                            self.readLocalData()
                        } catch {
                            print(error)
                        }
                    }
                }catch {
                    print("Error with Json: \(error)")
                }
            }
        }
        self.tableView?.reloadData()
        task.resume()
    }
    
    func getAllCitiesID() -> String {
        //get all cityID form global array into string format to be passed for data request to api
        let citiesIDArray : NSMutableArray = []
        for cityDictionary in citiesArray {
            let cityTempModel = CityModel(dictionary:cityDictionary as! [String : String])
            citiesIDArray.addObject(cityTempModel.cityId)
        }
        let string = citiesIDArray.componentsJoinedByString(",")
        return string
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddCityTableController" {
            let yourNextViewController = (segue.destinationViewController as! AddCityTableController)
            yourNextViewController.delegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

