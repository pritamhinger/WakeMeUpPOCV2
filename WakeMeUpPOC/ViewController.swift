//
//  ViewController.swift
//  WakeMeUpPOC
//
//  Created by Pritam Hinger on 20/11/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import DateTimePicker

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var pickDate: UIBarButtonItem!
    
    var items = NSMutableArray()
    
    var current = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        itemTextField.delegate = self
        loadItems()
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
            //self.dateSelected.text = formatter.string(from: date)
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row] as! String
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
        items.write(toFile: savePath, atomically: true)
    }
    
    func loadItems() {
        let savePath = getPath()
        if FileManager.default.fileExists(atPath: savePath){
            items = NSMutableArray(contentsOfFile: savePath)!
            tableView.reloadData()
        }
    }
    
    func getPath() -> String {
        let pathArray = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentDirectory = pathArray[0] as String
        return documentDirectory.appending("items_list")
        
    }
}

