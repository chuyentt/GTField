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
    private var itemList:[String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shareItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        self.navigationItem.rightBarButtonItems = [shareItem]
        
        setupView()
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
            break;
        case .distanceUnit:
            self.title = "Select Distance Unit"
            break;
        case .latLngFormat:
            self.title = "Select Coordinate Format"
            break;
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "Cell")
        let text = itemList[indexPath.row]
        cell.textLabel?.text = text
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        setSelect(indexPath.row)
    }
    
    func setSelect(_ index: Int) {
        switch selectionType {
        case .areaUnit:
            setAreaUnit(index)
            break
        case .distanceUnit:
            setDistanceUnit(index)
            break
        case .latLngFormat:
            setLatLngFormat(index)
            break
        }
    }

}
