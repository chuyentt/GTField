//
//  FeatureDetailViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 2/10/18.
//  Copyright © 2018 Tran Trung Chuyen. All rights reserved.
//

import UIKit

protocol FeatureDetailViewControllerDelegate: AnyObject {
    func didDeleteFeature()
    func didSaveFeature(_ feature: CFeature)
}

class FeatureDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: FeatureDetailViewControllerDelegate?
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var headerView: UIView!
    
    /////////////////////
    var feature: CFeature!
    
    let filterProperties:[String] = [CPropMember.name.rawValue,
                           CPropMember.desc.rawValue,
                           CPropMember.title.rawValue]
    let filterStyle:[String] = [CPropMember.stroke.rawValue,
                                CPropMember.strokeOpacity.rawValue,
                                CPropMember.strokeWidth.rawValue,
                                CPropMember.fill.rawValue,
                                CPropMember.fillOpacity.rawValue,
                                CPropMember.markerColor.rawValue,
                                CPropMember.markerSize.rawValue,
                                CPropMember.markerSymbol.rawValue]
    
    //var points:[String] = []
    //var lengths:[String] = []
    var filteredProperties:[String : Any] = [:]
    var path: GMSPath?
    var prevPoint: CLLocationCoordinate2D?
    
    /////////////////////
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = NSLocalizedString("Feature Detail", comment: "")
        
        // Do any additional setup after loading the view.
        setupParallaxHeader()
        featureDetail()
        //headerView = mapView
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.toolbar.barStyle = UIBarStyle.default
        self.navigationController?.toolbar.isTranslucent = true
        self.navigationController?.toolbar.barTintColor = BAR_TINT_COLOR_DEFAULT
        
        let btnDelete = UIBarButtonItem(title: NSLocalizedString("Delete", comment: ""), style: .plain, target: self, action: #selector(deleteFeatureAction))
        let btnSave = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(saveFeatureAction))
        self.toolbarItems = [btnDelete, spacer, btnSave]
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil {
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func setupParallaxHeader() {
        guard mapView != nil else {
            return
        }
        headerView = mapView.snapshotView(afterScreenUpdates: true)
        headerView.contentMode = .scaleAspectFill
        tableView.parallaxHeader.view = headerView
        tableView.parallaxHeader.height = 320
        tableView.parallaxHeader.minimumHeight = 0
        tableView.parallaxHeader.mode = .topFill
        tableView.parallaxHeader.parallaxHeaderDidScrollHandler = { parallaxHeader in
            print(parallaxHeader.progress)
        }
        tableView.tableHeaderView = segmentedControl
    }
    
    // Xem lại chỗ này, nên tính khi duyệt đến cell thì sẽ nhẹ hơn
    private func featureDetail() {
        switch feature.geometry.type {
        case .point:
            break
        case .lineString:
            path = (feature.geometry as! CLineString).path
            prevPoint = path?.coordinate(at: 0)
//            for i in 0..<Int((path?.count())!) {
//                let pt = path?.coordinate(at: UInt(i))
//                lengths.append(Double((pt?.distance(from: prevPoint!))!).distanceUnit())
//                points.append((pt!.localCoordinate(true)))
//                prevPoint = pt
//            }
        case .polygon:
            path = (feature.geometry as! CPolygon).path?.closed()
            prevPoint = path?.coordinate(at: 0)
//            for i in 0..<Int((path?.count())!) {
//                let pt = path?.coordinate(at: UInt(i))
//                lengths.append(Double((pt?.distance(from: prevPoint!))!).distanceUnit())
//                points.append((path?.coordinate(at: UInt(i)).localCoordinate(true))!)
//                prevPoint = pt
//            }
        default:
            break
        }
        
    }
    
    @objc func deleteFeatureAction() {
        switch feature.geometry.type {
        case .point:
            (feature.geometry as! CPoint).visibleMode = .normal
        case .lineString:
            (feature.geometry as! CLineString).visibleMode = .normal
        case .polygon:
            (feature.geometry as! CPolygon).visibleMode = .normal
        case .multiPoint:
            break
        case .multiLineString:
            break
        case .multiPolygon:
            break
        case .geometryCollection:
            break
        }
        feature.delete()
        delegate?.didDeleteFeature()
        self.navigationController?.popViewController(animated: true)
        // Cần thiết lập delegate, visibleMode,... cho MultiPoint,... để quản lý tốt hơn
    }
    
    @objc func saveFeatureAction() {
        switch feature.geometry.type {
        case .point:
            break
            //(feature.geometry as! CPoint).visibleMode = .normal
        case .lineString:
            break
            //(feature.geometry as! CLineString).visibleMode = .normal
        case .polygon:
            break
            //(feature.geometry as! CPolygon).visibleMode = .normal
        case .multiPoint:
            break
        case .multiLineString:
            break
        case .multiPolygon:
            break
        case .geometryCollection:
            break
        }
        delegate?.didSaveFeature(feature)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func detailChanged(_ sender: Any) {
        tableView.reloadData()
    }
    
    /*
     * UITableViewDataSource
     */
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Properties
            filteredProperties = (feature.properties?.filter { !filterProperties.contains($0.key) })!
            filteredProperties = filteredProperties.filter { !filterStyle.contains($0.key) }
            return 2 + filteredProperties.count
        case 1: // Info
            switch feature.geometry.type {
            case .point:
                return 3
            case .lineString:
                return 3 + Int(((feature.geometry as! CLineString).path?.count())!)
            case .polygon:
                return 3 + Int(((feature.geometry as! CPolygon).path?.closed().count())!)
            case .multiPoint:
                return 1
            case .multiLineString:
                return 1
            case .multiPolygon:
                return 1
            case .geometryCollection:
                return 1
            }
        case 2: // Style
            switch feature.geometry.type {
            case .point:
                return 3
            case .lineString:
                return 3
            case .polygon:
                return 5
            default:
                return 0
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Properties
            if indexPath.row == 0 {
                cell.textLabel?.text = "Name"
                cell.detailTextLabel?.text = feature.properties?[CPropMember.name.rawValue] as? String
            } else if indexPath.row == 1 {
                cell.textLabel?.text = "Desc"
                cell.detailTextLabel?.text = feature.properties?[CPropMember.desc.rawValue] as? String
            } else {
                cell.textLabel?.text = filteredProperties.compactMap(){ $0.0 } [indexPath.row - 2]
                cell.detailTextLabel?.text = filteredProperties.compactMap(){ $0.1 } [indexPath.row - 2] as? String
            }
            break
        case 1: // Info
            switch feature.geometry.type {
            case .point:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CPoint).type.rawValue
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Geo coords"
                    cell.detailTextLabel?.text = (feature.geometry as! CPoint).position.latLngFormated(withTarget: false)
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = "Grid coords"
                    cell.detailTextLabel?.text = (feature.geometry as! CPoint).position.localCoordinate(true)
                }
            case .lineString:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CLineString).type.rawValue
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Total length"
                    cell.detailTextLabel?.text = (feature.geometry as! CLineString).path?.length(of: GMSLengthKind.geodesic).distanceUnit()
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = "Closed area"
                    cell.detailTextLabel?.text = GMSGeometryArea(((feature.geometry as! CLineString).path?.closed())!).areaUnit()
                } else {
                    //            for i in 0..<Int((path?.count())!) {
                    //                let pt = path?.coordinate(at: UInt(i))
                    //                lengths.append(Double((pt?.distance(from: prevPoint!))!).distanceUnit())
                    //                points.append((path?.coordinate(at: UInt(i)).localCoordinate(true))!)
                    //                prevPoint = pt
                    //            }
                    let index = indexPath.row - 3
                    let pt = path?.coordinate(at: UInt(index))
                    cell.textLabel?.text = "(\(index+1)) \(Double((pt?.distance(from: prevPoint!))!).distanceUnit())"
                    cell.detailTextLabel?.text = path?.coordinate(at: UInt(index)).localCoordinate(true)
                    prevPoint = pt
                }
            case .polygon:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CPolygon).type.rawValue
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = "Total length"
                    cell.detailTextLabel?.text = (feature.geometry as! CPolygon).path?.length(of: GMSLengthKind.geodesic).distanceUnit()
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = "Closed area"
                    cell.detailTextLabel?.text = GMSGeometryArea((feature.geometry as! CPolygon).path!).areaUnit()
                } else {
                    let index = indexPath.row - 3
                    let pt = path?.coordinate(at: UInt(index))
                    cell.textLabel?.text = "(\(index+1)) \(Double((pt?.distance(from: prevPoint!))!).distanceUnit())"
                    cell.detailTextLabel?.text = path?.coordinate(at: UInt(index)).localCoordinate(true)
                    prevPoint = pt
                }
            case .multiPoint:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CMultiPoint).type.rawValue
                }
            case .multiLineString:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CMultiLineString).type.rawValue
                }
            case .multiPolygon:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CMultiPolygon).type.rawValue
                }
            case .geometryCollection:
                if indexPath.row == 0 {
                    cell.textLabel?.text = "Feature type"
                    cell.detailTextLabel?.text = (feature.geometry as! CGeometryCollection).type.rawValue
                }
            }
            
        case 2: // Style
            switch feature.geometry.type {
            case .point:
                if indexPath.row == 0 {
                    cell.textLabel?.text = CPropMember.markerColor.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.markerColor.rawValue] as? String
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = CPropMember.markerSize.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.markerSize.rawValue] as? String
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = CPropMember.markerSymbol.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.markerSymbol.rawValue] as? String
                }
            case .lineString:
                if indexPath.row == 0 {
                    cell.textLabel?.text = CPropMember.stroke.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.stroke.rawValue] as? String
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = CPropMember.strokeWidth.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.strokeWidth.rawValue] as? String
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = CPropMember.strokeOpacity.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.strokeOpacity.rawValue] as? String
                }
            case .polygon:
                if indexPath.row == 0 {
                    cell.textLabel?.text = CPropMember.stroke.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.stroke.rawValue] as? String
                } else if indexPath.row == 1 {
                    cell.textLabel?.text = CPropMember.strokeWidth.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.strokeWidth.rawValue] as? String
                } else if indexPath.row == 2 {
                    cell.textLabel?.text = CPropMember.strokeOpacity.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.strokeOpacity.rawValue] as? String
                } else if indexPath.row == 3 {
                    cell.textLabel?.text = CPropMember.fill.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.fill.rawValue] as? String
                } else if indexPath.row == 4 {
                    cell.textLabel?.text = CPropMember.fillOpacity.rawValue
                    cell.detailTextLabel?.text = feature.properties?[CPropMember.fillOpacity.rawValue] as? String
                }
            default:
                break
            }
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: // Properties
            if indexPath.row == 0 {
                let alertController = UIAlertController(title: NSLocalizedString("Feature name", comment: ""), message: "", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {
                    alert -> Void in
                    let textField = alertController.textFields![0] as UITextField
                    self.feature.properties![CPropMember.name.rawValue] = textField.text
                    tableView.reloadData()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                    textField.placeholder = NSLocalizedString("Type feature name", comment: "")
                    textField.autocapitalizationType = .sentences
                })
                
                self.present(alertController, animated: true, completion: nil)
            } else if indexPath.row == 1 {
                let alertController = UIAlertController(title: NSLocalizedString("Feature desc", comment: ""), message: "", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: NSLocalizedString("Save", comment: ""), style: .default, handler: {
                    alert -> Void in
                    let textField = alertController.textFields![0] as UITextField
                    self.feature.properties![CPropMember.desc.rawValue] = textField.text
                    tableView.reloadData()
                }))
                alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                
                alertController.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                    textField.placeholder = NSLocalizedString("Type feature desc", comment: "")
                    textField.autocapitalizationType = .sentences
                })
                
                self.present(alertController, animated: true, completion: nil)
            }
            break
        default:
            break
        }
    }
}
