//
//  ViewController.swift
//  WakeMeUpPOC
//
//  Created by Pritam Hinger on 20/11/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import DateTimePicker
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickDate: UIBarButtonItem!
    
    var items = NSMutableArray()
    var isNotificationAccessGranted = false
    var current = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tryGettingAccess(completionHandler: { (granted, error) in
            if error != nil{
                print("Some error occured while getting notification access")
            }
            else{
                self.isNotificationAccessGranted = granted
                print("User response to allow acces is : \(granted)")
            }
        })
        
        tableView.delegate = self
        tableView.dataSource = self
        itemTextField.delegate = self
        loadItems()
    }
    
    func setNotificationSettings() {
        
    }
    
    @IBAction func addItemToList(_ sender: UIButton) {
        if (itemTextField.text?.characters.count)! <= 0 {
            return;
        }
        
        items.add(itemTextField.text!)
        itemTextField.text = ""
        tableView.reloadData()
        saveItems()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if (textField.text?.characters.count)! <= 0 {
            return true;
        }
        
        items.add(textField.text!)
        tableView.reloadData()
        textField.text = ""
        textField.resignFirstResponder()
        saveItems()
        return true
    }
    
    @IBAction func pickButtonClicked(_ sender: Any) {
        
        if !isNotificationAccessGranted{
            print("Access needs to be provided")
            tryGettingAccess(completionHandler: { (granted, error) in
                if error != nil{
                    print("Some error occured while getting notification access")
                }
                else{
                    self.isNotificationAccessGranted = granted
                    print("User response to allow acces is : \(granted)")
                }
            })
            return;
        }
        
        let min = Date().addingTimeInterval(-60 * 60 * 1)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 60)
        let picker = DateTimePicker.show(selected: current, minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.doneButtonTitle = "Set Alarm"
        picker.todayButtonTitle = "Today"
        picker.completionHandler = { date in
            self.current = date
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm dd/MM/YYYY"
            print("Selected Date : \(formatter.string(from: date))")
            self.createNotification(forTime: date)
        }
    }
    
    func createNotification(forTime date:Date) {
        let content = UNMutableNotificationContent()
        let identifier = "APDEVLAP"
        let categoryIdentifier = "NotificationCat"
        content.title = "Alarm Title"
        content.subtitle = "Alarm SubTitle"
        content.body = "Alarm Body"
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = categoryIdentifier
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if error != nil{
                print("Something terribly went wrong while creating alarm. \nError : \(error)")
            }
        })
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        
        let deleteAction = UNNotificationAction(identifier: "Delete", title: "Delete it..!!", options: [])
        let notificationCategory =  UNNotificationCategory(identifier: categoryIdentifier, actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([notificationCategory])
        
        print("Everything done...!!")
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm dd/MM/YYYY"
        items.add(formatter.string(from: date))
        saveItems()
        tableView.reloadData()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("WIll Present called")
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Did Present called")
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            print("Dismiss Called")
        case UNNotificationDefaultActionIdentifier:
            print("Default action called")
        case "Snooze":
                print("Snoozing")
            case "Delete":
            print("Deleting")
        default:
            print("Dafulting")
        }
        
        
        
        completionHandler();
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            removeItem(atIndex: indexPath.row)
        }
    }
    
    func removeItem(atIndex index:Int) {
        items.removeObject(at: index)
        tableView.reloadData()
        saveItems()
    }
    
    func saveItems() {
        let savePath = getPath()
        print("Path is \(savePath)")
        items.write(toFile: savePath, atomically: true)
    }
    
    func loadItems() {
        let savePath = getPath()
        print("Path is \(savePath)")
        if FileManager.default.fileExists(atPath: savePath){
            items = NSMutableArray(contentsOfFile: savePath)!
            tableView.reloadData()
        }
    }
    
    func getPath() -> String {
        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = pathArray[0] as String
        return documentDirectory.appending("/items_list")
        
    }
    
    func tryGettingAccess(completionHandler: @escaping (_ granted:Bool, _ error:Error?) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { (granted, error) in
            completionHandler(granted, error);
        })
    }
}

