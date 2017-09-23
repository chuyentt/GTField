//
//  InputViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/9/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit

protocol InputViewControllerDelegate: class {
    func didFinishWithValue(_ value: Double, _ index: Int, _ type: SelectionType)
}

class InputViewController: UITableViewController {
    weak var delegate: InputViewControllerDelegate?
    var textField: UITextField?
    var value: Double = 0.0
    var cellRef: UITableViewCell?
    var format: Int = 0
    var selectionType: SelectionType?
    var index: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        self.clearsSelectionOnViewWillAppear = true
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(done(_:)))
        self.navigationItem.rightBarButtonItem = saveButton
        tableView.allowsSelection = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    @IBAction func done(_ sender: UIBarButtonItem) {
        value = ((textField?.text)! as NSString).doubleValue
        
        delegate?.didFinishWithValue(value, index, selectionType!)
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.cellRef?.textLabel?.text
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.contentMode = .center
        let frame = cell.contentView.frame
        textField = UITextField(frame: frame.applying(CGAffineTransform(translationX: 20, y: 0)))
        textField?.text = self.cellRef?.detailTextLabel?.text
        textField?.delegate = self
        textField?.keyboardType = .numbersAndPunctuation
        textField?.becomeFirstResponder()
        textField?.clearButtonMode = .whileEditing
        cell.contentView.addSubview(textField!)
        cell.contentView.layer.borderColor = UIColor.gray.cgColor
        cell.contentView.layer.borderWidth = 0.5

        return cell
    }
}

extension InputViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //textField.backgroundColor = UIColor.yellow
        textField.textColor = UIColor.black
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = UIColor.clear
        textField.textColor = TEXTVIEW_TEXT_COLOR_DEFAULT
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
}
