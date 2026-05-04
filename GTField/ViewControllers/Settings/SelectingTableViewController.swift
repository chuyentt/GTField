//
//  SelectingTableViewController.swift
//  GTField
//
//  Created by Chuyen Trung Tran on 8/13/17.
//  Copyright © 2017 Tran Trung Chuyen. All rights reserved.
//

import UIKit
import GeoTrans

enum SelectionType: Int {
    case distanceUnit = 0
    case areaUnit = 1
    case latLngFormat = 2
    case coordinateSystem = 3
    case datumTransformation = 4
    case ellipsoid = 5
    case mapProjection = 6
    case mapGridFormat = 7
}

protocol SelectingTableViewControllerDelegate: class {
    func didSelectItem(_ item: ListItem, _ selectionType: SelectionType)
}

extension SelectingTableViewController: MapProjectionDetailViewControllerDelegate {
    func didSave() {
        self.setSelect(0)
    }
}

class SelectingTableViewController: UITableViewController {
    
    weak var delegate: SelectingTableViewControllerDelegate?
    
    var selectionType: SelectionType = .areaUnit
    var textLabel: UILabel?
    
    var items = [ListItem]()
    
    var crsIndex = 0
    var ellipsoidIndex = 0
    var datumIndex = 0
    var projectionIndex = 0
    var mapGridIndex = 0

    var filteredItems = [ListItem]()
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectionType == .coordinateSystem {
            if crsItems.count == 0 {
                DispatchQueue.main.async {
                    self.view?.showLoading()
                }
            } else {
                items = crsItems
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if selectionType == .coordinateSystem {
            if crsItems.count == 0 {
                crsItems = loadCrs()
                items = crsItems
                DispatchQueue.main.async() {
                    self.view?.hideLoading()
                }
                tableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let shareItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close(_:)))
        
        self.navigationItem.leftBarButtonItems = [shareItem]
        
        // Setup the Search Controller
        searchController.searchResultsUpdater = self
        tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        searchController.dimsBackgroundDuringPresentation = false
        
        // Setup the Scope Bar
        searchController.searchBar.delegate = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func close(_ sender: UIBarButtonItem) {
        self.searchController.isActive = false
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    func loadCrs() -> [ListItem] {
        typealias ListItems = [ListItem]
        var _crsItems = [ListItem]()
        do {
            // RIPR: Bundle.main.url(forResource:) trả nil nếu plist bị xoá khỏi
            // bundle (vd. khi Asset bị strip nhầm). Force-unwrap → crash.
            guard let url = Bundle.main.url(forResource: "crs", withExtension: "plist") else {
                return _crsItems
            }
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            _crsItems = try decoder.decode(ListItems.self, from: data)
        } catch {
            // Handle error
            print(error)
        }
        return _crsItems
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredItems.count
        } else {
            return items.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "Cell")
        let item: ListItem
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        //cell.textLabel?.numberOfLines = 0
        //cell.detailTextLabel?.numberOfLines = 0
        let text = item.name
        cell.textLabel?.text = text
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        //cell.detailTextLabel?.text = item.value
        cell.detailTextLabel?.adjustsFontSizeToFitWidth = true
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
        case .mapGridFormat:
            index = getMapGridFormat()
            break
        case .coordinateSystem:
            index = crsIndex
            break
        case .datumTransformation:
            index = datumIndex
            break
        case .ellipsoid:
            index = ellipsoidIndex
            break
        case .mapProjection:
            index = projectionIndex
            break
        }
        if indexPath.row == index && !isFiltering() {
            cell.accessoryType = .checkmark
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item: ListItem
        if isFiltering() {
            item = filteredItems[indexPath.row]
        } else {
            item = items[indexPath.row]
        }
        let index = items.firstIndex(where: { (_item) -> Bool in
            (_item.name == item.name) && (_item.code == item.code)
        })
        
        if selectionType == .coordinateSystem {
            let alert = UIAlertController(
                title: NSLocalizedString("Select option", comment: ""),
                message: nil,
                preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Set as default", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    self.setSelect(index!)
                    self.close(UIBarButtonItem())
            }))
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("Detail", comment: ""),
                style: .default,
                handler: { (action: UIAlertAction!) in
                    let vc: MapProjectionDetailViewController = MapProjectionDetailViewController()
                    vc.delegate = self
                    vc.editable = (item.code == "0")
                    if vc.editable {
                        vc.proj4String = getCustomCrsProj4String()
                    } else {
                        vc.proj4String = item.value
                    }
                    vc.title = item.name
                    let nav: UINavigationController = UINavigationController(rootViewController: vc)
                    self.present(nav, animated: true, completion: {
                        
                    })
            }))
            present(alert, animated: true, completion: nil)
        } else {
            self.setSelect(index!)
            self.close(UIBarButtonItem())
        }
    }
    
    func setSelect(_ index: Int) {
        let text = items[index].name
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
        case .mapGridFormat:
            setMapGridFormat(index)
            self.close(UIBarButtonItem())
            break
        case .coordinateSystem:
            setCrsIndex(index);
            setCrsCode(items[index].code)
            setCrsName(items[index].name)
            
            //TODO: Tách xâu lấy các tham số trong value
            if index == 0 { // User-defined (Custom)
                crsProcessing(items[index].name, getCustomCrsProj4String()) // Lấy proj4String User-defined (Custom)
            } else {
                crsProcessing(items[index].name, items[index].value) // Xử lý để chọn
            }
            
            self.close(UIBarButtonItem())
            break
        case .datumTransformation:
//            setDatumIndex(index)
//            setDatumCode(items[index].code)
//            setDatumName(items[index].name)
            delegate?.didSelectItem(items[index], .datumTransformation)
            self.close(UIBarButtonItem())
            break
        case .ellipsoid:
//            setEllipsoidIndex(index)
//            setEllipsoidCode(items[index].code)
//            setEllipsoidName(items[index].name)
            delegate?.didSelectItem(items[index], .ellipsoid)
            self.close(UIBarButtonItem())
            break
        case .mapProjection:
//            setCoordinateType(index)
//            setMapProjectionCode(items[index].code)
//            setMapProjectionName(items[index].name)
            setCustomMapProjectionType(index)
            delegate?.didSelectItem(items[index], .mapProjection)
            self.close(UIBarButtonItem())
            break
        }
    }

    // MARK: - Private instance methods
    
    func filterContentForSearchText(_ searchText: String) {
        filteredItems = items.filter({( item : ListItem) -> Bool in
            return item.name.lowercased().contains(searchText.lowercased()) || item.value.lowercased().contains(searchText.lowercased()) || item.value.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}



extension SelectingTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!)
    }
}

extension SelectingTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
