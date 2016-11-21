//
//  NotificationViewController.swift
//  Notifications
//
//  Created by Pritam Hinger on 20/11/16.
//  Copyright © 2016 AppDevelapp. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {

    @IBOutlet var label: UILabel?
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var heading: UILabel!
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content
        self.label?.text = content.body
        self.heading.text = content.title
        self.subTitle.text = content.subtitle
        
    }
    
    func didReceive(_ response: UNNotificationResponse, completionHandler completion: @escaping (UNNotificationContentExtensionResponseOption) -> Void) {
        
    }

}
