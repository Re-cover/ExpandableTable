//
//  CustomCell.swift
//  ExpandableTable
//
//  Created by Recover on 2016/11/5.
//  Copyright © 2016年 Recover. All rights reserved.
//

import UIKit

protocol CustomCellDelegate {
    func dateWasSelected(_ cell: CustomCell, selectedDateString: String)
    
    func maritalStatusSwitchChangedState(_ cell: CustomCell, isOn: Bool)
    
    func textfieldTextWasChanged(_ cell: CustomCell, newText: String)
    
    func sliderDidChangeValue(_ cell: CustomCell,  newSliderValue: NSNumber)
}

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var lblSwitchLabel: UILabel!
    
    @IBOutlet weak var swMaritalStatus: UISwitch!
    
    @IBOutlet weak var slExperienceLevel: UISlider!
    
    let bigFont = UIFont.init(name: "Avenir-Book", size: 17.0)
   
    let smallFont = UIFont.init(name: "Avenir-Light", size: 17.0)
    
    let primaryColor = UIColor.black
    
    let secondaryColor = UIColor.lightGray
    
    var delegate: CustomCellDelegate!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        if textField != nil {
            textField.font = bigFont
            textField.textColor = primaryColor
        }
        
        if detailTextLabel != nil {
            detailTextLabel!.font = bigFont
            detailTextLabel!.textColor = secondaryColor
        }
        
        if textField != nil {
            textField.font = bigFont
            textField.delegate = self
        }
        
        if lblSwitchLabel != nil {
            lblSwitchLabel.font = bigFont
        }
        
        if slExperienceLevel != nil {
            slExperienceLevel.minimumValue = 0.0
            slExperienceLevel.maximumValue = 1.0
            slExperienceLevel.value = 0.0
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func setDate(_ sender: AnyObject) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        let dateString = dateFormatter.string(from: datePicker.date)
        
        if delegate != nil {
            delegate.dateWasSelected(self, selectedDateString: dateString)
        }
    }
    
    @IBAction func handleSwitchStateChange(_ sender: AnyObject) {
        if delegate != nil {
            delegate.maritalStatusSwitchChangedState(self, isOn: swMaritalStatus.isOn)
        }
    }
    
    @IBAction func handleSliderValueChange(_ sender: AnyObject) {
        if delegate != nil {
            delegate.sliderDidChangeValue(self, newSliderValue: NSNumber(value: Float(slExperienceLevel.value)))
        }
    }
    
}

// MARK: - UITextFieldDelegate
extension CustomCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if delegate != nil {
            delegate.textfieldTextWasChanged(self, newText: textField.text!)
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if delegate != nil {
            delegate.textfieldTextWasChanged(self, newText: textField.text!)
        }
        return true
    }
}
