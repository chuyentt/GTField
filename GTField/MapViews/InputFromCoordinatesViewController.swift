//
//  InputFromCoordinatesViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/10/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import MapKit
import GeoTrans

protocol InputFromCoordinatesViewControllerDelegate: class {
    func didFinishWithLocation(_ location: CLLocation)
    func didFinishWithValue(_ value: Double, _ index: Int, _ type: SelectionType)
}

class InputFromCoordinatesViewController: UITableViewController {
    weak var delegate: InputFromCoordinatesViewControllerDelegate?
    var textField: UITextField?
    var value: Double = 0.0
    var format: Int = 0
    var selectionType: SelectionType?
    var index: Int = 0
    
    var zone_: Int = 0
    var hemisphere: String = "N"
    var coordiateString: String = ""
    var warningMessage: NSString?
    var easting: Double = 0
    var northing: Double = 0
    var height: Double = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var altitude: Double = 0
    var location: CLLocation?
    var currentLocation: CLLocation?
    
    var srcSC:UISegmentedControl?
    var saveButton: UIBarButtonItem?
    @IBOutlet var footerLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        self.clearsSelectionOnViewWillAppear = true
        
        saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(done(_:)))
        
        self.navigationItem.rightBarButtonItem = saveButton
        tableView.allowsSelection = false
        
        srcSC = UISegmentedControl(items: ["Local coordinate system", "Geodetic"])
        srcSC?.selectedSegmentIndex = 0
        srcSC?.isEnabled = false
        tableView.tableHeaderView = srcSC!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        textFieldDidChange(textField!)
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
        if warningMessage?.length == 0 {
            //value = ((textField?.text)! as NSString).doubleValue
            location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude*RAD2DEG, longitude: longitude*RAD2DEG), altitude: altitude, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
            delegate?.didFinishWithLocation(location!)
            self.dismiss(animated: true, completion: { () -> Void in
                
            })
        } else {
            let alert = UIAlertController(title: NSLocalizedString(warningMessage! as String, comment: ""),
                                          message: nil,
                                          preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        // Kiểm tra lưới chiếu để chọn hàm cho đúng
        let coordinateType = getCoordinateType()
        let type: CoordinateType = CoordinateType(rawValue: coordinateType)!
        switch type {
        case CoordinateType.britishNationalGrid:
            geotrans?.getGeodeticForBNGCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: CoordinateType.britishNationalGrid.rawValue, bngString: textField.text, precision: 5, height: 0, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.geocentric, CoordinateType.localCartesian:
            let charSet: CharacterSet = CharacterSet.init(charactersIn: ",").union(CharacterSet.init(charactersIn: ":")).union(CharacterSet.init(charactersIn: " "))
            let arr = textField.text?.components(separatedBy: charSet).filter({ (s) -> Bool in
                s.length > 0
            })
            if (arr?.count)! >= 2 {
                switch getMapGridFormat() {
                case 0: // ENH
                    easting = NSString(string: (arr?[0])!).doubleValue
                    northing = NSString(string: (arr?[1])!).doubleValue
                    break
                case 1: // H:NEH
                    northing = NSString(string: (arr?[0])!).doubleValue
                    easting = NSString(string: (arr?[1])!).doubleValue
                    break
                default:
                    break
                }
                
            }
            if (arr?.count)! >= 3 {
                height = NSString(string: (arr?[2])!).doubleValue
            }
            
            geotrans?.getGeodeticForCartesianCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, x: easting, y: northing, z: height)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.globalAreaReferenceSystem:
            geotrans?.getGeodeticForGARSCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, garsString: textField.text, precision: 5, height: 0, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.georef:
            geotrans?.getGeodeticForGEOREFCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, georefString: textField.text, precision: 5, height: 0, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.militaryGridReferenceSystem, CoordinateType.usNationalGrid:
            geotrans?.getGeodeticForMGRSorUSNGCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, mgrsString: textField.text, precision: 5, height: 0, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.universalPolarStereographic:
            let charSet: CharacterSet = CharacterSet.init(charactersIn: ",").union(CharacterSet.init(charactersIn: ":")).union(CharacterSet.init(charactersIn: " "))
            let arr = textField.text?.components(separatedBy: charSet).filter({ (s) -> Bool in
                s.length > 0
            })
            if (arr?.count)! >= 3 {
                switch getMapGridFormat() {
                case 0: // H:ENH
                    hemisphere = (arr?[0])!
                    easting = NSString(string: (arr?[1])!).doubleValue
                    northing = NSString(string: (arr?[2])!).doubleValue
                    break
                case 1: // H:NEH
                    hemisphere = (arr?[0])!
                    northing = NSString(string: (arr?[1])!).doubleValue
                    easting = NSString(string: (arr?[2])!).doubleValue
                    break
                default:
                    break
                }
                
            }
            if (arr?.count)! >= 4 {
                height = NSString(string: (arr?[3])!).doubleValue
            }
            
            geotrans?.getGeodeticForUPSCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, hemisphere: hemisphere, easting: easting, northing: northing, height: height, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.universalTransverseMercator:
            let charSet: CharacterSet = CharacterSet.init(charactersIn: ",").union(CharacterSet.init(charactersIn: ":")).union(CharacterSet.init(charactersIn: " "))
            let arr = textField.text?.components(separatedBy: charSet).filter({ (s) -> Bool in
                s.length > 0
            })
            
            if (arr?.count)! >= 4 {
                switch getMapGridFormat() {
                case 0: // Z H:ENH
                    zone_ = NSString(string: (arr?[0])!).integerValue
                    hemisphere = (arr?[1])!
                    easting = NSString(string: (arr?[2])!).doubleValue
                    northing = NSString(string: (arr?[3])!).doubleValue
                    break
                case 1: // Z H:NEH
                    zone_ = NSString(string: (arr?[0])!).integerValue
                    hemisphere = (arr?[1])!
                    northing = NSString(string: (arr?[2])!).doubleValue
                    easting = NSString(string: (arr?[3])!).doubleValue
                    break
                default:
                    break
                }
                
            }
            if (arr?.count)! >= 5 {
                height = NSString(string: (arr?[4])!).doubleValue
            }
            
            geotrans?.getGeodeticForUTMCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, zone: zone_, hemisphere: hemisphere, easting: easting, northing: northing, height: height, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        case CoordinateType.albersEqualAreaConic,
             CoordinateType.azimuthalEquidistant,
             CoordinateType.bonne,
             CoordinateType.cassini,
             CoordinateType.cylindricalEqualArea,
             CoordinateType.eckert4,
             CoordinateType.eckert6,
             CoordinateType.equidistantCylindrical,
             CoordinateType.gnomonic,
             CoordinateType.lambertConformalConic1Parallel,
             CoordinateType.lambertConformalConic2Parallels,
             CoordinateType.mercatorScaleFactor,
             CoordinateType.mercatorStandardParallel,
             CoordinateType.millerCylindrical,
             CoordinateType.mollweide,
             CoordinateType.neys,
             CoordinateType.newZealandMapGrid,
             CoordinateType.obliqueMercator,
             CoordinateType.orthographic,
             CoordinateType.polyconic,
             CoordinateType.polarStereographicScaleFactor,
             CoordinateType.polarStereographicStandardParallel,
             CoordinateType.sinusoidal,
             CoordinateType.stereographic,
             CoordinateType.transverseMercator,
             CoordinateType.transverseCylindricalEqualArea,
             CoordinateType.vanDerGrinten,
             CoordinateType.webMercator:
            
            let charSet: CharacterSet = CharacterSet.init(charactersIn: ",").union(CharacterSet.init(charactersIn: ":")).union(CharacterSet.init(charactersIn: " "))
            let arr = textField.text?.components(separatedBy: charSet).filter({ (s) -> Bool in
                s.length > 0
            })
            
            if (arr?.count)! >= 2 {
                switch getMapGridFormat() {
                case 0: // ENH
                    easting = NSString(string: (arr?[0])!).doubleValue
                    northing = NSString(string: (arr?[1])!).doubleValue
                    break
                case 1: // NEH
                    easting = NSString(string: (arr?[1])!).doubleValue
                    northing = NSString(string: (arr?[0])!).doubleValue
                    break
                default:
                    break
                }
                
            }
            if (arr?.count)! >= 3 {
                height = NSString(string: (arr?[2])!).doubleValue
            }
            
            geotrans?.getGeodeticForMapProjectionCoordinates(&latitude, lng: &longitude, alt: &altitude, warningMessage: &warningMessage, type: type.rawValue, easting: easting, northing: northing, height: height, hType: 7)
            saveButton?.isEnabled = warningMessage?.length == 0
            break
        default:
            break
        }
        
        var title = ""
        if warningMessage?.length == 0 {
            location = CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude*RAD2DEG, longitude: longitude*RAD2DEG), altitude: altitude, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
            title = (location?.coordinate.latLngFormated(withTarget: true))!
        } else {
            if warningMessage != nil {
                title = NSLocalizedString(warningMessage! as String, comment: "")
            }
        }
        footerLabel?.text = title
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        footerLabel = header.textLabel
        footerLabel.numberOfLines = 0
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("Input coordinates for a marker", comment: "")
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let title = String().padding(toLength: 80, withPad: "-", startingAt: 0)
        return title
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.contentMode = .center
        if textField == nil {
            let frame = cell.contentView.frame
            textField = UITextField(frame: frame.applying(CGAffineTransform(translationX: 20, y: 0)))
            textField?.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            textField?.text = currentLocation?.coordinate.localCoordinate(false)
            textField?.delegate = self
            textField?.keyboardType = .numbersAndPunctuation
            textField?.clearButtonMode = .whileEditing
        }
        cell.contentView.addSubview(textField!)
        cell.contentView.layer.borderColor = UIColor.gray.cgColor
        cell.contentView.layer.borderWidth = 0.5
        textField?.becomeFirstResponder()
        return cell
    }
}

extension InputFromCoordinatesViewController: UITextFieldDelegate {
    
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
