//
//  SelectingTableViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 8/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

enum SelectionType: Int {
    case distanceUnit = 0
    case areaUnit = 1
    case latLngFormat = 2
}

class SelectingTableViewController: UITableViewController {
    var selectionType: SelectionType = .areaUnit
    var textLabel: UILabel?
    
    var itemList:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shareItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    func setupView() {
        switch selectionType {
        case .areaUnit:
            self.title = "Select Area Unit"
            itemList.append("\(AreaUnit.squareMeter.name) (\(AreaUnit.squareMeter.symbol))")
            itemList.append("\(AreaUnit.squareKilometer.name) (\(AreaUnit.squareKilometer.symbol))")
            itemList.append("\(AreaUnit.hectare.name) (\(AreaUnit.hectare.symbol))")
            itemList.append("\(AreaUnit.squareYard.name) (\(AreaUnit.squareYard.symbol))")
            itemList.append("\(AreaUnit.squareMile.name) (\(AreaUnit.squareMile.symbol))")
            itemList.append("\(AreaUnit.acre.name) (\(AreaUnit.acre.symbol))")
            break;
        case .distanceUnit:
            self.title = "Select Distance Unit"
            itemList.append("\(LengthUnit.meter.name) (\(LengthUnit.meter.symbol))")
            itemList.append("\(LengthUnit.kilometer.name) (\(LengthUnit.kilometer.symbol))")
            itemList.append("\(LengthUnit.yard.name) (\(LengthUnit.yard.symbol))")
            itemList.append("\(LengthUnit.mile.name) (\(LengthUnit.mile.symbol))")
            break;
        case .latLngFormat:
            self.title = "Select Coordinate Format"
            itemList.append("ddd°mm'ss.ssss N/S,E/W")
            itemList.append("ddd.dddddddddd N/S,E/W")
            itemList.append("+/-ddd°mm'ss.ssss")
            itemList.append("+/-ddd.dddddddddd")
            break;
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        let text = itemList[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = text
        var index = 0
        switch selectionType {
        case .areaUnit:
            index = getAreaUnit()
            break
        case .distanceUnit:
            index = getDistanceUnit()
            break
        case .latLngFormat:
            index = getLatLngFormat()
            break
        }
        if indexPath.row == index {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setSelect(indexPath.row)
    }
    
    func setSelect(_ index: Int) {
        let text = itemList[index]
        textLabel?.text = text
        switch selectionType {
        case .areaUnit:
            setAreaUnit(index)
            self.close(UIBarButtonItem())
            break
        case .distanceUnit:
            setDistanceUnit(index)
            self.close(UIBarButtonItem())
            break
        case .latLngFormat:
            setLatLngFormat(index)
            self.close(UIBarButtonItem())
            break
        }
    }

}
