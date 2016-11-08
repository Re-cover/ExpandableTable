//
//  ViewController.swift
//  ExpandableTable
//
//  Created by Recover on 2016/11/4.
//  Copyright © 2016年 Recover. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var expandableTableView: UITableView!
    
    var cellDescriptors = [[[String: AnyObject]]]()
    
    var visibleRowsPerSection = [[Int]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureTableView()
        
        loadCellDescriptors()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureTableView() {
        expandableTableView.delegate = self
        expandableTableView.dataSource = self
        expandableTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        expandableTableView.register(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
        expandableTableView.register(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
        expandableTableView.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
        expandableTableView.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
        expandableTableView.register(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
        expandableTableView.register(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
    }
}

// MARK: 数据处理
extension ViewController {
    func loadCellDescriptors() {
        if let path = Bundle.main.path(forResource: "CellDescriptor", ofType: "plist") {
            for descriptor in NSMutableArray(contentsOfFile: path)! {
                let cellDescriptor = descriptor as! [[String: AnyObject]]
                cellDescriptors.append(cellDescriptor)
            }
        }
        getIndicesOfVisibleRows()
        expandableTableView.reloadData()
    }
    
    func getIndicesOfVisibleRows() {
        visibleRowsPerSection.removeAll()
        for sectionCells in cellDescriptors {
            let currentSectionCells = sectionCells
            var visibleRows = [Int]()
            
            for row in 0...currentSectionCells.count - 1 {
                if currentSectionCells[row]["isVisible"] as! Bool == true {
                    visibleRows.append(row)
                }
            }
            visibleRowsPerSection.append(visibleRows)
        }
    }
    
    func getCellDescriptor(for indexPath: IndexPath) -> [String: AnyObject] {
        let indexOfVisiableRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        let cellDescriptor = cellDescriptors[indexPath.section][indexOfVisiableRow]
        return cellDescriptor
    }
    
    func setCellDescriptor(for key:String, value: AnyObject, section: Int, row: Int) {
        cellDescriptors[section][row][key] = value
    }
    
    func IndexOfParentCellForSubCell(at section: Int, row: Int) -> Int{
        for i in (0...row - 1).reversed() {
            if cellDescriptors[section][i]["isExpandable"] as! Bool {
                return i
            }
        }
        return 0
    }
}

// MARK: CustomCellDelegate
extension ViewController: CustomCellDelegate {
    func dateWasSelected(_ cell: CustomCell, selectedDateString: String) {
        let indexPath = expandableTableView.indexPath(for: cell)!
        let realIndex = visibleRowsPerSection[indexPath.section][indexPath.row]
        let indexOfParentCell = IndexOfParentCellForSubCell(at: indexPath.section, row: realIndex)
        setCellDescriptor(for: "primaryTitle", value: selectedDateString as AnyObject, section: indexPath.section, row: indexOfParentCell)
        setCellDescriptor(for: "isExpanded", value: false as AnyObject, section: indexPath.section, row: indexOfParentCell)
        setCellDescriptor(for: "isVisible", value: false as AnyObject, section: indexPath.section, row: realIndex)
        getIndicesOfVisibleRows()
        expandableTableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
    }
    
    func maritalStatusSwitchChangedState(_ cell: CustomCell, isOn: Bool) {
        let indexPath = expandableTableView.indexPath(for: cell)!
        let realIndex = visibleRowsPerSection[indexPath.section][indexPath.row]
        let indexOfParentCell = IndexOfParentCellForSubCell(at: indexPath.section, row: realIndex)
        
        let valueToStore = isOn as AnyObject
        let valueToDisplay = (isOn ? "Married" : "Single") as AnyObject
        setCellDescriptor(for: "value", value: valueToStore, section: indexPath.section, row: realIndex)
        setCellDescriptor(for: "primaryTitle", value: valueToDisplay, section: indexPath.section, row: indexOfParentCell)
        setCellDescriptor(for: "isExpanded", value: false as AnyObject, section: indexPath.section, row: indexOfParentCell)
        setCellDescriptor(for: "isVisible", value: false as AnyObject, section: indexPath.section, row: realIndex)
        getIndicesOfVisibleRows()
        expandableTableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
    }
    
    func textfieldTextWasChanged(_ cell: CustomCell, newText: String) {
        let indexPath = expandableTableView.indexPath(for: cell)!
        
        //如果输入姓名后，未点击键盘回车，直接点击 FullName Cell 收起，会导致
        //代理方法 cell 为 nil，从而 realIndex 和 indexOfParentCell 为 nil，因此设置 indexOfParentCell 为固定值 0
        
        //let realIndex = visibleRowsPerSection[indexPath.section][indexPath.row]
        //let indexOfParentCell = IndexOfParentCellForSubCell(at: indexPath.section, row: realIndex)
        
        let indexOfParentCell = 0
        
        let currentFullname = cellDescriptors[indexPath.section][indexOfParentCell]["primaryTitle"] as! String
        let fullnameParts = currentFullname.characters.split(separator: " ").map(String.init)
        var firstName = ""
        var lastName = ""
        var newFullname = ""
        
        if indexPath.row == 1 {
            if fullnameParts.count == 2 {
                firstName = newText
                lastName = fullnameParts[1]
                newFullname = "\(newText) \(lastName)"
            }
            else {
                firstName = newText
                newFullname = newText
            }
        }
        else {
            firstName = fullnameParts[0]
            lastName = newText
            newFullname = "\(firstName) \(newText)"
        }
        setCellDescriptor(for: "primaryTitle", value: newFullname as AnyObject, section: 0, row: 0)
        setCellDescriptor(for: "primaryTitle", value: firstName as AnyObject, section: 0, row: 1)
        setCellDescriptor(for: "primaryTitle", value: lastName as AnyObject, section: 0, row: 2)
        expandableTableView.reloadData()
    }
    
    func sliderDidChangeValue(_ cell: CustomCell, newSliderValue: NSNumber) {
        let section = 2
        let row = 1
        setCellDescriptor(for: "value", value: newSliderValue as AnyObject, section: section, row: row)
        setCellDescriptor(for: "primaryTitle", value: "\(newSliderValue.floatValue)" as AnyObject, section: section, row: row - 1)
        expandableTableView.reloadSections(IndexSet(integer: section), with: .none)
    }
}

// MARK: UITableViewDelegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellDescriptor = getCellDescriptor(for: indexPath)
        switch currentCellDescriptor["cellIdentifier"] as! String{
        case "idCellNormal":
            return 60.0
        case "idCellDatePicker":
            return 270.0
        default:
            return 44.0
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]

        let currentCellDescriptor = getCellDescriptor(for: indexPath)
        let isExpandable = currentCellDescriptor["isExpandable"] as! Bool
        let isExpanded = currentCellDescriptor["isExpanded"] as! Bool
        
        var shouldExpandAndShowSubRows = false
        if isExpandable && !isExpanded {
            shouldExpandAndShowSubRows = true
        }
        
        setCellDescriptor(for: "isExpanded", value: shouldExpandAndShowSubRows as AnyObject, section: indexPath.section, row: indexOfTappedRow)
        let additonalRows = currentCellDescriptor["additionalRows"] as! Int
        if additonalRows > 0 {
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + additonalRows){
                setCellDescriptor(for: "isVisible", value: shouldExpandAndShowSubRows as AnyObject, section: indexPath.section, row: i)
            }
        } else {
            if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
                let indexOfParentCell = IndexOfParentCellForSubCell(at: indexPath.section, row: indexOfTappedRow)
                let title = (tableView.cellForRow(at: indexPath) as! CustomCell).textLabel?.text as AnyObject
                
                setCellDescriptor(for: "primaryTitle", value: title, section: indexPath.section, row: indexOfParentCell)
                setCellDescriptor(for: "isExpanded", value: false as AnyObject, section: indexPath.section, row: indexOfParentCell)
                for i in (indexOfParentCell + 1)...(indexOfParentCell + (cellDescriptors[indexPath.section][indexOfParentCell]["additionalRows"] as! Int)) {
                    setCellDescriptor(for: "isVisible", value: false as AnyObject, section: indexPath.section, row: i)
                }
            }
        }
        
        getIndicesOfVisibleRows()
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .fade)
    }
}

// MARK: UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellDescriptors.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return visibleRowsPerSection[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Personal"
        case 1:
            return "Preferences"
        case 2:
            return "Work Experience"
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentCellDescriptor = getCellDescriptor(for: indexPath)
        let identifier = currentCellDescriptor["cellIdentifier"] as! String
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CustomCell
        cell.delegate = self
        
        switch identifier {
        case "idCellNormal":
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textLabel?.text = primaryTitle as? String
            }
            if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                cell.detailTextLabel?.text = secondaryTitle as? String
            }
        case "idCellTextfield":
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textField.placeholder = primaryTitle as? String
                cell.textField.text = primaryTitle as? String
            }
        case "idCellSwitch":
            cell.lblSwitchLabel.text = currentCellDescriptor["primaryTitle"] as? String
            let value = currentCellDescriptor["value"] as? Bool
            cell.swMaritalStatus.setOn(value!, animated: false)
        case "idCellValuePicker":
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
        case "idCellSlider":
            let value = currentCellDescriptor["value"] as! NSNumber
            cell.slExperienceLevel.value = (value as NSNumber).floatValue
        default:
            break
        }
        return cell
    }
}

