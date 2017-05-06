//
//  ModifyReminderViewController.swift
//  ReMindr
//
//  Created by Vincent Liu on 1/5/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit

protocol modifyReminderProtocol
{
    func modifyReminder(reminder: Reminder)
}

class ModifyReminderViewController: UIViewController {

    
    var delegate: modifyReminderProtocol?
    var modifyMode = false
    
    @IBOutlet weak var descTextfield: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var repSeg: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func finishModifying(_ sender: Any) {
        
    }
    
    @IBAction func cancelModifying(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func adc()
    {
//        if self.modifyMode == true
//        {
//            self.delegate?.modifyReminder(reminder: reminder!)
//            self.modifyMode == false
//        }
    }
    

}
