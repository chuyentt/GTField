//
//  GooglePlacePickerStub.swift
//  GTField
//
//  Local no-op stubs replacing the deprecated GooglePlacePicker SDK that the 1.4.11 (build 68)
//  source tree depends on. The original framework only ships device-arm64 + i386/x86_64 sim
//  slices so it cannot be linked against an Apple-Silicon iOS simulator. The picker UI is
//  therefore non-functional locally; callsites compile but presenting the controller shows
//  an empty screen that auto-dismisses.
//

import UIKit
import GoogleMaps
import GooglePlaces

// MARK: - Config

public final class GMSPlacePickerConfig {
    public let viewport: GMSCoordinateBounds?
    public init(viewport: GMSCoordinateBounds?) {
        self.viewport = viewport
    }
}

// MARK: - Delegate

public protocol GMSPlacePickerViewControllerDelegate: AnyObject {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace)
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error)
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController)
}

public extension GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {}
    func placePicker(_ viewController: GMSPlacePickerViewController, didFailWithError error: Error) {}
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {}
}

// MARK: - Controller

public final class GMSPlacePickerViewController: UIViewController {
    public weak var delegate: GMSPlacePickerViewControllerDelegate?
    public let config: GMSPlacePickerConfig

    public init(config: GMSPlacePickerConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported by the GMSPlacePickerViewController stub")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Place Picker is not available\n(GooglePlacePicker has been deprecated)"
        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 24),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -24),
        ])

        let close = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = close
    }

    @objc private func closeTapped() {
        delegate?.placePickerDidCancel(self)
        dismiss(animated: true, completion: nil)
    }
}
