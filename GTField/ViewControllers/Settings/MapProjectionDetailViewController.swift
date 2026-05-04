//
//  MapProjectionDetailViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 9/8/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import GeoTrans

protocol MapProjectionDetailViewControllerDelegate: class {
    func didSave()
}

class MapProjectionDetailViewController: UITableViewController {
    weak var delegate: MapProjectionDetailViewControllerDelegate?

    var type = 34
    var proj4String = ""
    var editable: Bool = false
    var prjParamItems = [ProjectionParameters]()
    var ellpParameters = EllipsoidParameters(code: "WE", name: "WGS 84", a: 6378137, rf: 298.257223563)
    var datumParameters = DatumParameters(code: "WGE", name: "WGS 84", deltaX: 0, deltaY: 0, deltaZ: 0, rotationX: 0, rotationY: 0, rotationZ: 0, scaleFactor: 0)
    var textField: UITextField?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        crsProcessing()
        
        self.tableView = UITableView(frame: self.tableView.frame, style: .grouped)
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        self.navigationItem.leftBarButtonItems = [cancelButton]
        
        // Uncomment the following line to preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = true

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        if editable {
            let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(_:)))
            self.navigationItem.rightBarButtonItem = saveButton
        }
        tableView.allowsSelection = editable
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        var ellps_code = "WE"
//        let arr = proj4String.components(separatedBy: " +")
//        // Lấy 2 xâu đầu tách ra để lấy index của lưới chiếu và ellipsoid code
//        var keyValue = arr[0].components(separatedBy: "=")
//        print(arr)
//        if keyValue[0] == "+proj_code" {
//            coordinateType = Int(keyValue[1])!
//            if coordinateType > 37 {
//                coordinateType = 0
//            }
//        }
//        keyValue = arr[1].components(separatedBy: "=")
//        if keyValue[0] == "ellps_code" {
//            ellps_code = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
//        }
//        
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if editable {
//            // Đọc MapProjectionType từ hệ thống sau khi đã chọn
//            if getCustomMapProjectionType() != type {
//                self.type = getCustomMapProjectionType()
//                crsProcessing()
//                tableView.reloadData()
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        // Đặt crs vào NSUserDefault
        
        var prjStr = ""
        for param in prjParamItems {
            prjStr.append(param.proj4())
        }
        let str = "+proj_code=\(type)\(ellpParameters.proj4())\(prjStr)\(datumParameters.proj4())"
        print(str)
        setCustomCrsProj4String("+proj_code=\(type)\(ellpParameters.proj4())\(prjStr)\(datumParameters.proj4())")
        delegate?.didSave()
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("Projection name", comment: "")
        case 1:
            return NSLocalizedString("Projection parameters", comment: "")
        case 2:
            return NSLocalizedString("Ellipsoid parameters", comment: "")
        case 3:
            return NSLocalizedString("Datum transformation parameters", comment: "")
        default:
            return ""
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: // Projection name
            return 1
        case 1: // Projection parameters
            let coordinateType: CoordinateType = CoordinateType(rawValue: Int(self.type))!
            switch coordinateType {
            case CoordinateType.britishNationalGrid:
                return 0
            case CoordinateType.militaryGridReferenceSystem:
                return 0
            case CoordinateType.localCartesian:
                return 4
            case CoordinateType.globalAreaReferenceSystem:
                return 0
            case CoordinateType.georef:
                return 0
            case CoordinateType.universalPolarStereographic:
                return 0
            case CoordinateType.universalTransverseMercator:
                return 0
                
            // =>MapProjection3Parameters
            case CoordinateType.eckert4,
                 CoordinateType.eckert6,
                 CoordinateType.millerCylindrical,
                 CoordinateType.mollweide,
                 CoordinateType.sinusoidal,
                 CoordinateType.vanDerGrinten:
                return 3
                
            //=>MapProjection4Parameters
            case CoordinateType.azimuthalEquidistant,
                 CoordinateType.bonne,
                 CoordinateType.cassini,
                 CoordinateType.cylindricalEqualArea,
                 CoordinateType.gnomonic,
                 CoordinateType.orthographic,
                 CoordinateType.polyconic,
                 CoordinateType.stereographic:
                return 4
                
            //=>MapProjection5Parameters
            case CoordinateType.transverseCylindricalEqualArea,
                 CoordinateType.transverseMercator,
                 CoordinateType.lambertConformalConic1Parallel:
                return 5
                
            //=>MapProjection6Parameters
            case CoordinateType.lambertConformalConic2Parallels,
                 CoordinateType.albersEqualAreaConic:
                return 6
                
            //=>MercatorScaleFactorParameters
            case CoordinateType.mercatorScaleFactor:
                return 4
                
            //=>MercatorStandardParallelParameters
            case CoordinateType.mercatorStandardParallel:
                return 5
                
            //=>EquidistantCylindricalParameters
            case CoordinateType.equidistantCylindrical:
                return 4
                
            //=>NeysParameters
            case CoordinateType.neys:
                return 5
                
            //=>
            case CoordinateType.newZealandMapGrid:
                return 0
                
            //TODO ObliqueMercatorParameters
            case CoordinateType.obliqueMercator:
                return 8
                
            //=>PolarStereographicScaleFactorParameters
            case CoordinateType.polarStereographicScaleFactor:
                return 5
                
            //=>PolarStereographicStandardParallelParameters
            case CoordinateType.polarStereographicStandardParallel:
                return 4
                
            //TODO Chưa có lưới chiếu này trong thư viện proj4
            case CoordinateType.webMercator:
                return 0
                
            default:
                return 0
            }
        case 2: //Ellipsoid parameters
            return 3
        case 3: // Datum transformation parameters
            return 8
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        let cell1: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "Cell1")
        if editable {
            cell.accessoryType = .disclosureIndicator
            cell1.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
            cell1.accessoryType = .none
        }
        switch indexPath.section {
        case 0: // Projection name
            cell.textLabel?.text = projectionItems[self.type].name
            
            return cell
        case 1: // Projection parameters
            cell1.textLabel?.text = NSLocalizedString(prjParamItems[indexPath.row].code, comment: "")
            switch prjParamItems[indexPath.row].format {
            case 0: // Double
                cell1.detailTextLabel?.text = "\(prjParamItems[indexPath.row].value)"
                break
                
            case 1: // Lat format
                cell1.detailTextLabel?.text = "\(prjParamItems[indexPath.row].value)"
                break
                
            case 2: // Lon format
                cell1.detailTextLabel?.text = "\(prjParamItems[indexPath.row].value)"
                break
                
            default:
                break
            }
            return cell1
        case 2: // Ellipsoid parameters
            switch indexPath.row {
            case 0: // Name
                cell1.textLabel?.text = NSLocalizedString("Name", comment: "")
                cell1.detailTextLabel?.text = ellpParameters.name
                break
                
            case 1: // a
                cell1.textLabel?.text = NSLocalizedString("Semi-major axis (m)", comment: "")
                cell1.detailTextLabel?.text = "\(ellpParameters.a)"
                cell1.accessoryType = .none
                cell1.selectionStyle = .none
                break
                
            case 2: // rf
                cell1.textLabel?.text = NSLocalizedString("Inverse flattening", comment: "")
                cell1.detailTextLabel?.text = "\(ellpParameters.rf)"
                cell1.accessoryType = .none
                cell1.selectionStyle = .none
                break
            default:
                break
            }
            return cell1
            
        case 3: // Datum transformation
            switch indexPath.row {
            case 0: // Name
                cell1.textLabel?.text = NSLocalizedString("Name", comment: "")
                cell1.detailTextLabel?.text = datumParameters.name
                cell1.selectionStyle = .default
                break
                
            case 1: // DeltaX
                cell1.textLabel?.text = NSLocalizedString("DeltaX (m)", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.deltaX)"
                //cell1.selectionStyle = .none
                break
                
            case 2: // DeltaY
                cell1.textLabel?.text = NSLocalizedString("DeltaY (m)", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.deltaY)"
                //cell1.selectionStyle = .none
                break
            case 3: // DeltaZ
                cell1.textLabel?.text = NSLocalizedString("DeltaZ (m)", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.deltaZ)"
                //cell1.selectionStyle = .none
                break
            case 4: // RotationX
                cell1.textLabel?.text = NSLocalizedString("RotationX (sec)", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.rotationX)"
                //cell1.selectionStyle = .none
                break
                
            case 5: // RotationY
                cell1.textLabel?.text = NSLocalizedString("RotationY (sec)", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.rotationY)"
                //cell1.selectionStyle = .none
                break
            case 6: // RotationZ
                cell1.textLabel?.text = NSLocalizedString("RotationZ (sec)", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.rotationZ)"
                //cell1.selectionStyle = .none
                break
            case 7: // ScaleFactor
                cell1.textLabel?.text = NSLocalizedString("scaleFactor", comment: "")
                cell1.detailTextLabel?.text = "\(datumParameters.scaleFactor)"
                //cell1.selectionStyle = .none
                break
            default:
                break
            }
            cell1.detailTextLabel?.backgroundColor = UIColor.blue
            return cell1
        default:
            cell1.textLabel?.text = "Cell \(indexPath.row)"
            cell1.detailTextLabel?.text = "Cell value \(indexPath.row)"
            return cell1
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch indexPath.section {
        case 0:
            let vc: SelectingTableViewController = SelectingTableViewController()
            vc.selectionType = .mapProjection
            vc.projectionIndex = self.type
            vc.delegate = self
            vc.items = projectionItems
            vc.title = NSLocalizedString("Select a map projection", comment: "")
            let nav: UINavigationController = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: {
                
            })
            break
        case 1: // Projection Parameters
            let vc: InputViewController = InputViewController()
            vc.value = datumParameters.deltaX
            vc.cellRef = cell
            vc.selectionType = .mapProjection
            vc.index = indexPath.row
            vc.format = prjParamItems[indexPath.row].format
            
            vc.delegate = self
            vc.title = NSLocalizedString("Map Projection parameter", comment: "")
            let nav: UINavigationController = UINavigationController(rootViewController: vc)
            self.present(nav, animated: true, completion: {
                
            })

            break
        case 2: // Ellipsoid Parameters
            switch indexPath.row {
            case 0: // Chọn datum từ danh sách. +datum=datum.code
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .ellipsoid
                vc.ellipsoidIndex = ellipsoidItems.firstIndex(where: { (item) -> Bool in
                    item.code == ellpParameters.code
                })!
                vc.delegate = self
                vc.items = ellipsoidItems
                vc.title = NSLocalizedString("Select an ellipsoid", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 1:
                
                break
            default:
                break
                
            }
            
            break
        case 3: // Datum Parameters
            switch indexPath.row {
            case 0: // Chọn datum từ danh sách. +datum=datum.code
                let vc: SelectingTableViewController = SelectingTableViewController()
                vc.selectionType = .datumTransformation
                var datumIndex = 9999
                if let index = datumItems.firstIndex(where: { (item) -> Bool in
                    item.code == datumParameters.code
                }) {
                    datumIndex = index
                }
                vc.datumIndex = datumIndex
                vc.delegate = self
                vc.items = datumItems
                vc.title = NSLocalizedString("Select a datum transformation", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
            case 1: // deltaX: Nếu thay đổi thì sẽ đổi datum.code
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.deltaX
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 2
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 2:
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.deltaY
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 3
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 3:
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.deltaZ
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 4
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 4:
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.rotationX
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 5
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 5:
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.rotationY
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 6
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 6:
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.rotationZ
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 7
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            case 7:
                let vc: InputViewController = InputViewController()
                vc.value = datumParameters.scaleFactor
                vc.cellRef = cell
                vc.selectionType = .datumTransformation
                vc.index = 8
                
                vc.delegate = self
                vc.title = NSLocalizedString("Datum transformation parameter", comment: "")
                let nav: UINavigationController = UINavigationController(rootViewController: vc)
                self.present(nav, animated: true, completion: {
                    
                })
                break
            default:
                break
                
            }
            break
        default:
            
            break
        }
    }
    
    /*
     * Xử lý ellipsoid
     */
    func ellpProcessing(_ ellps_code: String) -> EllipsoidParameters {
        let index = ellipsoidItems.firstIndex(where: { (_item:ListItem) -> Bool in
            (_item.code == ellps_code)
        })
        let ellpItem: ListItem = ellipsoidItems[index!]
        let arr = ellpItem.value.components(separatedBy: " +")
        var a: Double = 6378137.0
        var rf: Double = 298.257223563
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "+a" {
                a = Double(keyValue[1])!
            } else if keyValue[0] == "rf" {
                rf = Double(keyValue[1])!
            }
        }
        return EllipsoidParameters(code: ellpItem.code, name: ellpItem.name, a: a, rf: rf)
    }
    
    /*
     * Xử lý datum
     */
    func datumProcessing(_ dCode: String) -> DatumParameters {
        var datum: ListItem = datumItems[0]
        if let index = datumItems.firstIndex(where: { (_item) -> Bool in
            (_item.code == dCode)
        }) {
            datum = datumItems[index]
        } else {
            datum = ListItem(code: "WGE", name: "WGS 84", value: "+ellps_code=WE +towgs84=0,0,0,0,0,0,0")
        }
        
        let arr = datum.value.components(separatedBy: " +")
        for item in arr {
            let keyValue = item.components(separatedBy: "=")
            if keyValue[0] == "towgs84" {
                self.datumParameters = toWGS84Processing(keyValue)
            }
        }
        return DatumParameters(code: datum.code,
                               name: datum.name,
                               deltaX: datumParameters.deltaX,
                               deltaY: datumParameters.deltaY,
                               deltaZ: datumParameters.deltaZ,
                               rotationX: datumParameters.rotationX,
                               rotationY: datumParameters.rotationY,
                               rotationZ: datumParameters.rotationZ,
                               scaleFactor: datumParameters.scaleFactor)
    }
    
    func toWGS84Processing(_ keyValue: [String]) -> DatumParameters {
        var deltaX: Double = 0
        var deltaY: Double = 0
        var deltaZ: Double = 0
        var rotationX: Double = 0
        var rotationY: Double = 0
        var rotationZ: Double = 0
        var sf: Double = 0
        
        let keyValue = keyValue[1].components(separatedBy: ",")
        if keyValue.count == 7 {
            deltaX = Double(keyValue[0])!
            deltaY = Double(keyValue[1])!
            deltaZ = Double(keyValue[2])!
            rotationX = Double(keyValue[3])!
            rotationY = Double(keyValue[4])!
            rotationZ = Double(keyValue[5])!
            sf = Double(keyValue[6])!
        }
        return DatumParameters(code: "9999",
                               name: "TOWGS84",
                               deltaX: deltaX,
                               deltaY: deltaY,
                               deltaZ: deltaZ,
                               rotationX: rotationX,
                               rotationY: rotationY,
                               rotationZ: rotationZ,
                               scaleFactor: sf)
    }
    
    /*
     * Xử lý chuỗi proj4
     * type: UInt, _ arr: [String], _ select: Bool
     *
     */
    func crsProcessing() {
        var ellps_code = "WE"
        let arr = proj4String.components(separatedBy: " +")
        // Lấy 2 xâu đầu tách ra để lấy index của lưới chiếu và ellipsoid code
        var keyValue = arr[0].components(separatedBy: "=")
        print(arr)
        if editable {
            type = getCustomMapProjectionType()
        } else {
            if keyValue[0] == "+proj_code" {
                type = Int(keyValue[1])!
                if type > 37 {
                    type = 34
                }
            }
        }
        
        keyValue = arr[1].components(separatedBy: "=")
        if keyValue[0] == "ellps_code" {
            ellps_code = keyValue[1].trimmingCharacters(in: .whitespacesAndNewlines)
            ellpParameters = self.ellpProcessing(ellps_code)
        }
        
        let coordinateType: CoordinateType = CoordinateType(rawValue: Int(type))!
        switch (coordinateType) {
        case CoordinateType.britishNationalGrid:
            // Không có lưới chiếu này trong proj4
            prjParamItems = [ProjectionParameters]()
            break
            
        case CoordinateType.militaryGridReferenceSystem:
            // Không có lưới chiếu này trong proj4
            prjParamItems = [ProjectionParameters]()
            break
            
        case CoordinateType.localCartesian:
            // Không có lưới chiếu này trong proj4
            var originLongitude:Double = 0
            var originLatitude:Double = 0
            var originHeight:Double = 0
            var orientation:Double = 0
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    originLongitude = Double(keyValue[1])!
                } else if keyValue[0] == "lat_0" {
                    originLatitude = Double(keyValue[1])!
                } else if keyValue[0] == "h_0" {
                    originHeight = Double(keyValue[1])!
                } else if keyValue[0] == "o_0" {
                    orientation = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "originLongitude", value: originLongitude, format: 2),
                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 2),
                ProjectionParameters(code: "originHeight", value: originHeight, format: 0),
                ProjectionParameters(code: "orientation", value: orientation, format: 2)
            ]
            
            break
            
        case CoordinateType.globalAreaReferenceSystem:
            // Không có lưới chiếu này trong proj4
            prjParamItems = [ProjectionParameters]()
            break
            
        case CoordinateType.georef:
            // Không có lưới chiếu này trong proj4
            prjParamItems = [ProjectionParameters]()
            break
            
        case CoordinateType.universalPolarStereographic:
            // Không có lưới chiếu này trong proj4
            prjParamItems = [ProjectionParameters]()
            break
            
        case CoordinateType.universalTransverseMercator:
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [ProjectionParameters]()
            
            break
            
        // =>MapProjection3Parameters
        case CoordinateType.eckert4,
             CoordinateType.eckert6,
             CoordinateType.millerCylindrical,
             CoordinateType.mollweide,
             CoordinateType.sinusoidal,
             CoordinateType.vanDerGrinten:
            
            var centralMeridian: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
        //=>MapProjection4Parameters
        case CoordinateType.azimuthalEquidistant,
             CoordinateType.bonne,
             CoordinateType.cassini,
             CoordinateType.cylindricalEqualArea,
             CoordinateType.gnomonic,
             CoordinateType.orthographic,
             CoordinateType.polyconic,
             CoordinateType.stereographic:
            
            var centralMeridian: Double = 0
            var originLatitude: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_0" {
                    originLatitude = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>MapProjection5Parameters
        case CoordinateType.transverseCylindricalEqualArea,
             CoordinateType.transverseMercator,
             CoordinateType.lambertConformalConic1Parallel:
            
            var centralMeridian: Double = 0
            var originLatitude: Double = 0
            var scaleFactor: Double = 1.0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_0" {
                    originLatitude = Double(keyValue[1])!
                } else if keyValue[0] == "k" {
                    scaleFactor = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 1),
                ProjectionParameters(code: "scaleFactor", value: scaleFactor, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>MapProjection6Parameters
        case CoordinateType.lambertConformalConic2Parallels,
             CoordinateType.albersEqualAreaConic:
            
            var centralMeridian: Double = 0
            var originLatitude: Double = 0
            var standardParallel1: Double = 0
            var standardParallel2: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_0" {
                    originLatitude = Double(keyValue[1])!
                } else if keyValue[0] == "lat_1" {
                    standardParallel1 = Double(keyValue[1])!
                } else if keyValue[0] == "lat_2" {
                    standardParallel2 = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 1),
                ProjectionParameters(code: "standardParallel1", value: standardParallel1, format: 1),
                ProjectionParameters(code: "standardParallel2", value: standardParallel2, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>MercatorScaleFactorParameters
        case CoordinateType.mercatorScaleFactor:
            
            var centralMeridian: Double = 0
            var scaleFactor: Double = 1.0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "k" {
                    scaleFactor = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "scaleFactor", value: scaleFactor, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>MercatorStandardParallelParameters
        case CoordinateType.mercatorStandardParallel:
            
            var centralMeridian: Double = 0
            var standardParallel: Double = 0
            var scaleFactor: Double = 1.0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_ts" {
                    standardParallel = Double(keyValue[1])!
                } else if keyValue[0] == "k" {
                    scaleFactor = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "standardParallel", value: standardParallel, format: 1),
                ProjectionParameters(code: "scaleFactor", value: scaleFactor, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>EquidistantCylindricalParameters
        case CoordinateType.equidistantCylindrical:
            
            var centralMeridian: Double = 0
            var standardParallel: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_ts" {
                    standardParallel = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "standardParallel", value: standardParallel, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>NeysParameters
        case CoordinateType.neys:
            
            var centralMeridian: Double = 0
            var originLatitude: Double = 0
            var standardParallel: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_0" {
                    originLatitude = Double(keyValue[1])!
                } else if keyValue[0] == "lat_ts" {
                    standardParallel = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 1),
                ProjectionParameters(code: "standardParallel", value: standardParallel, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            
        //=>
        case CoordinateType.newZealandMapGrid:
            // Các tham số hệ này đã fix sẵn trong GeoTrans
            
//            var centralMeridian: Double = 0
//            var originLatitude: Double = 0
//            var falseEasting: Double = 0
//            var falseNorthing: Double = 0
//            
//            for item in arr {
//                let keyValue = item.components(separatedBy: "=")
//                if keyValue[0] == "lon_0" {
//                    centralMeridian = Double(keyValue[1])!
//                } else if keyValue[0] == "lat_0" {
//                    originLatitude = Double(keyValue[1])!
//                } else if keyValue[0] == "x_0" {
//                    falseEasting = Double(keyValue[1])!
//                } else if keyValue[0] == "y_0" {
//                    falseNorthing = Double(keyValue[1])!
//                } else if keyValue[0] == "datum" {
//                    self.datumParameters = self.datumProcessing(keyValue[1])
//                } else if keyValue[0] == "towgs84" {
//                    self.datumParameters = toWGS84Processing(keyValue)
//                }
//            }
            prjParamItems = [ProjectionParameters]()
//            prjParamItems = [
//                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
//                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 1),
//                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
//                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
//            ]
            break
            
            
        //TODO ObliqueMercatorParameters
        case CoordinateType.obliqueMercator:
            var originLatitude: Double = 0
            var latitude1: Double = 0
            var latitude2: Double = 0
            var longitude1: Double = 0
            var longitude2: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            var scaleFactor: Double = 1.0
            
            // lonc, alpha, gama => latitude1, latitude2, longitude1, longitude2
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lat_0" {
                    originLatitude = Double(keyValue[1])!
                } else if keyValue[0] == "lat_1" {
                    latitude1 = Double(keyValue[1])!
                } else if keyValue[0] == "lat_2" {
                    latitude2 = Double(keyValue[1])!
                } else if keyValue[0] == "lon_1" {
                    longitude1 = Double(keyValue[1])!
                } else if keyValue[0] == "lon_2" {
                    longitude2 = Double(keyValue[1])!
                }
                    //            } else if keyValue[0] == "lonc" {
                    //                let lonc = Double(keyValue[1])!
                    //            } else if keyValue[0] == "alpha" {
                    //                let alpha = Double(keyValue[1])!
                    //            } else if keyValue[0] == "gamma" {
                    //                let gamma = Double(keyValue[1])!
                else if keyValue[0] == "k" {
                    scaleFactor = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            //TODO: Tham số này cần phải đổi lại trong file Settings/tbl_srs.xls trong thư mục Project GTField
            //TODO Theo GeoTrans thì không có lonc, alpha, gama mà là latitude1, latitude2, longitude1, longitude2
            //+proj=omerc +lat_0=27.51882880555555 +lonc=52.60353916666667 +alpha=0.5716611944444444 +k=0.999895934 +x_0=658377.437 +y_0=3044969.194 +gamma=0.5716611944444444 +ellps=intl +towgs84=-133.63,-157.5,-158.62,0,0,0,0 +units=m +no_defs
            
            prjParamItems = [
                ProjectionParameters(code: "originLatitude", value: originLatitude, format: 1),
                ProjectionParameters(code: "longitude1", value: longitude1, format: 2),
                ProjectionParameters(code: "latitude1", value: latitude1, format: 1),
                ProjectionParameters(code: "longitude2", value: longitude2, format: 2),
                ProjectionParameters(code: "latitude2", value: latitude2, format: 1),
                ProjectionParameters(code: "scaleFactor", value: scaleFactor, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            //TODO Chưa có lưới chiếu này trong thư viện proj4
        //=>PolarStereographicScaleFactorParameters
        case CoordinateType.polarStereographicScaleFactor:
            
            var centralMeridian: Double = 0 //Longitude down from pole
            var scaleFactor: Double = 1.0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "k" {
                    scaleFactor = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "scaleFactor", value: scaleFactor, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            break
            
            //TODO Chưa có lưới chiếu này trong thư viện proj4
        //=>PolarStereographicStandardParallelParameters
        case CoordinateType.polarStereographicStandardParallel:
            var centralMeridian: Double = 0 //Longitude down from pole
            var standardParallel: Double = 0
            var falseEasting: Double = 0
            var falseNorthing: Double = 0
            
            for item in arr {
                let keyValue = item.components(separatedBy: "=")
                if keyValue[0] == "lon_0" {
                    centralMeridian = Double(keyValue[1])!
                } else if keyValue[0] == "lat_ts" {
                    standardParallel = Double(keyValue[1])!
                } else if keyValue[0] == "x_0" {
                    falseEasting = Double(keyValue[1])!
                } else if keyValue[0] == "y_0" {
                    falseNorthing = Double(keyValue[1])!
                } else if keyValue[0] == "datum" {
                    self.datumParameters = self.datumProcessing(keyValue[1])
                } else if keyValue[0] == "towgs84" {
                    self.datumParameters = toWGS84Processing(keyValue)
                }
            }
            
            prjParamItems = [
                ProjectionParameters(code: "centralMeridian", value: centralMeridian, format: 2),
                ProjectionParameters(code: "standardParallel", value: standardParallel, format: 1),
                ProjectionParameters(code: "falseEasting", value: falseEasting, format: 0),
                ProjectionParameters(code: "falseNorthing", value: falseNorthing, format: 0)
            ]
            
            break
            
            
        //TODO Chưa có lưới chiếu này trong thư viện proj4
        case CoordinateType.webMercator:
            prjParamItems = [ProjectionParameters]()
            // ========= DATUM TRANSFORMATION ========
            // Tạo tham số nguồn là geodetic (tọa độ trắc địa)
            //GeodeticParameters geodeticMlsEgmParams(CoordinateType.geodetic, HeightType.EGM2008TwoPtFiveMinBicubicSpline);
            
            // Tính chuyển tọa độ sang hệ đích (tọa độ trắc địa)
            //CoordinateConversionService ccsGeodeticMlsEgmToGeodetic(_srcCode, &geodeticMlsEgmParams, _targetCode, &geodeticMlsEgmParams);
            
            // Tính chuyển tọa độ trắc địa sang tọa độ trắc địa trên hệ cục bộ
            //Accuracy sourceAccuracy;
            //Accuracy targetAccuracy;
            //GeodeticCoordinates sourceCoordinates(CoordinateType.geodetic, _lng, _lat, _alt);
            //GeodeticCoordinates targetCoordinates;
            
            // Tính chuyển tọa độ trắc địa toàn cầu sang tọa độ trắc địa cục bộ có sử sụng datum
            //ccsGeodeticMlsEgmToGeodetic.convertSourceToTarget(&sourceCoordinates, &sourceAccuracy, targetCoordinates, targetAccuracy);
            
            //double __lat = targetCoordinates.latitude();
            //double __lng = targetCoordinates.longitude();
            // ========= END DATUM TRANSFORMATION ========
            
            //NSString *ellipsoidCode = @"WE"; // Luôn luôn là WE
            //char* eCode = (char *)[ellipsoidCode cStringUsingEncoding:NSASCIIStringEncoding];
            //WebMercator webMercator = WebMercator(eCode);
            //MapProjectionCoordinates *mapProjectionCoordinates = webMercator.convertFromGeodetic(new GeodeticCoordinates(CoordinateType.geodetic, __lng, __lat));
            //*easting = mapProjectionCoordinates->easting();
            //*northing = mapProjectionCoordinates->northing();
            break
            
            
        default:
            break;
        }
    }
}

extension MapProjectionDetailViewController:SelectingTableViewControllerDelegate {
    func didSelectItem(_ item: ListItem, _ selectionType: SelectionType) {
        switch selectionType {
        case .mapProjection:
            if let index = projectionItems.firstIndex(where: { (_item:ListItem) -> Bool in
                _item.code == item.code
            }) {
                if self.type != index {
                    self.type = index
                    self.crsProcessing()
                    // Đặt mặc định sau khi thay đổi lưới chiếu của hệ tọa độ người dùng định nghĩa
                    ellpParameters = ellpProcessing("WE")
                    datumParameters = datumProcessing("WGE")
                    
                    // Đặc biệt một số lưới chiếu fix sẵn ellipsoid
                    let coordinateType: CoordinateType = CoordinateType(rawValue: index)!
                    switch coordinateType {
                    case CoordinateType.newZealandMapGrid:
                        ellpParameters = ellpProcessing("IN")
//                        datumParameters = datumProcessing("9999")
//                        datumParameters.deltaX = 59.47
//                        datumParameters.deltaY =-5.04
//                        datumParameters.deltaZ = 187.44
//                        datumParameters.rotationX = 0.47
//                        datumParameters.rotationY =-0.1
//                        datumParameters.rotationZ = 1.024
//                        datumParameters.scaleFactor = -4.5993
                        break
                    case CoordinateType.britishNationalGrid:
                        ellpParameters = ellpProcessing("AA")
                        datumParameters = datumProcessing("OGB-7")
                        break
                    default:
                        break
                    }
                    
                    self.tableView.reloadData()
                }
            }
            
            break
        case .ellipsoid:
            ellpParameters = ellpProcessing(item.code)
            self.tableView.reloadData()
            break
        case .datumTransformation:
            datumParameters = datumProcessing(item.code)
            self.tableView.reloadData()
            break
        default:
            break
        }
    }
}

extension MapProjectionDetailViewController: InputViewControllerDelegate {
    func didFinishWithValue(_ value: Double, _ index: Int, _ type: SelectionType) {
        switch type {
        case .datumTransformation:
            switch index {
            case 2:
                datumParameters.deltaX = value
                break
            case 3:
                datumParameters.deltaY = value
                break
            case 4:
                datumParameters.deltaZ = value
                break
            case 5:
                datumParameters.rotationX = value
                break
            case 6:
                datumParameters.rotationY = value
                break
            case 7:
                datumParameters.rotationZ = value
                break
            case 8:
                datumParameters.scaleFactor = value
                break
            default:
                break
            }
            datumParameters.code = "9999"
            datumParameters.name = "TOWGS84"
            tableView.reloadData()
            break
        case .mapProjection:
            prjParamItems[index].value = value
            tableView.reloadData()
            break
        default:
            break
        }
    }
}
