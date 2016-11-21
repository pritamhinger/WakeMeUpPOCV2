//
//  ViewController.swift
//  WakeMeUpPOC
//
//  Created by Pritam Hinger on 20/11/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import DateTimePicker

class ViewController: UIViewController {

    @IBOutlet weak var dateSelected: UILabel!
    @IBOutlet weak var pickDate: UIBarButtonItem!
    var current = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func pickButtonClicked(_ sender: Any) {
        let min = Date().addingTimeInterval(-60 * 60 * 24 * 4)
        let max = Date().addingTimeInterval(60 * 60 * 24 * 4)
        let picker = DateTimePicker.show(selected: current, minimumDate: min, maximumDate: max)
        picker.highlightColor = UIColor(red: 255.0/255.0, green: 138.0/255.0, blue: 138.0/255.0, alpha: 1)
        picker.doneButtonTitle = "Set Alarm"
        picker.todayButtonTitle = "Today"
        picker.completionHandler = { date in
            self.current = date
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm dd/MM/YYYY"
            self.dateSelected.text = formatter.string(from: date)
        }
    }

}

