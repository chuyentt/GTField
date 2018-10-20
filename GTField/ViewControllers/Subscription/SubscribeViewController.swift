/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import StoreKit

private var formatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.formatterBehavior = .behavior10_4
    
    return formatter
}()

struct Subscription {
    let product: SKProduct
    let formattedPrice: String
    
    init(product: SKProduct) {
        self.product = product
        
        if formatter.locale != self.product.priceLocale {
            formatter.locale = self.product.priceLocale
        }
        
        formattedPrice = formatter.string(from: product.price) ?? "\(product.price)"
    }
}


enum RegisteredPurchase: String {
    case Unlimited
    case Yearly
    case Monthly
}

class SubscribeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var tableView: UITableView!
    
    // MARK: - Instance Properties
    
    var options: [Subscription]?
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    // MARK: - View Lifecycle
    @IBOutlet weak var inlineLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 99
        tableView.rowHeight = UITableView.automaticDimension
        options = SubscriptionService.shared.options
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOptionsLoaded(notification:)),
                                               name: SubscriptionService.optionsLoadedNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull(notification:)),
                                               name: SubscriptionService.purchaseSuccessfulNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handlePurchaseSuccessfull(notification:)),
                                               name: SubscriptionService.restoreSuccessfulNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleActive(notification:)),
                                               name: SubscriptionService.activeNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInactive(notification:)),
                                               name: SubscriptionService.inactiveNotification,
                                               object: nil)
        
        let shareItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItems = [shareItem]
        
        let btnAgree = UIBarButtonItem(title: NSLocalizedString("Terms of Use", comment: ""), style: .done, target: self, action: #selector(showTermOfUse))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [btnAgree, spacer]
        self.navigationController?.setToolbarHidden(false, animated: false)
        self.navigationController?.toolbar.barStyle = UIBarStyle.default
        self.navigationController?.toolbar.isTranslucent = true
        self.navigationController?.toolbar.barTintColor = BAR_TINT_COLOR_DEFAULT
    }
    
    @IBAction func close(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
    }
    
    @objc func showTermOfUse() {
        self.performSegue(withIdentifier: "segueTermsOfUse", sender: self)
    }
    
    @objc func handleActive(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.inlineLogo.image = #imageLiteral(resourceName: "Inline-Logo-Pro")
        }
    }
    
    @objc func handleInactive(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.inlineLogo.image = #imageLiteral(resourceName: "Inline-Logo")
        }
    }
    
    @objc func handleOptionsLoaded(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.options = SubscriptionService.shared.options
            self?.tableView.reloadData()
        }
    }
    
    @objc func handlePurchaseSuccessfull(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Actions
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier:String = segue.identifier!
        switch identifier {
        case "segueTermsOfUse":
            let nav: UINavigationController = segue.destination as! UINavigationController
            let vc: WebViewController = nav.viewControllers.first as! WebViewController
            let prefferedLanguage = Locale.preferredLanguages[0] as String
            let arr = prefferedLanguage.lowercased().components(separatedBy: "-")
            
            if arr.contains("vn") || arr.contains("vi") {
                vc.title = NSLocalizedString("Terms of Use", comment: "")
                vc.urlString = TERMS_OF_USE_VI_URL
                vc.webViewContent = .agreement
            } else {
                vc.title = NSLocalizedString("Terms of Use", comment: "")
                vc.urlString = TERMS_OF_USE_EN_URL
                vc.webViewContent = .agreement
            }
        default:
            break
        }
    }
}

class SubscriptionOptionTableViewCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var yourPlanLabel: UILabel!
    
    var isCurrentPlan: Bool = false {
        didSet {
            yourPlanLabel.isHidden = !isCurrentPlan
            yourPlanLabel.numberOfLines = 2
            yourPlanLabel.text = NSLocalizedString("You are on this plan!", comment: "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.1369239688, green: 0.1614148617, blue: 0.1697000265, alpha: 1)
        selectedBackgroundView = view
        yourPlanLabel.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        yourPlanLabel.isHidden = true
    }
}


// MARK: - UITableViewDataSource

extension SubscribeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("In-App Purchases & Subscribe", comment: "")
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        switch section {
        case 0:
            return NSLocalizedString("In-App Purchases & Subscribe Description", comment: "")
        default:
            return nil
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return options?.count ?? 0
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Option", for: indexPath) as! SubscriptionOptionTableViewCell
            guard let option = options?[indexPath.row] else { return cell }

            cell.nameLabel.text = option.product.localizedTitle
            cell.descriptionLabel.text = option.product.localizedDescription
            if option.product.productIdentifier.contains("Yearly") {
                cell.priceLabel.text = option.formattedPrice + "/" + NSLocalizedString("year", comment: "")
            } else if option.product.productIdentifier.contains("Monthly") {
                cell.priceLabel.text = option.formattedPrice + "/" + NSLocalizedString("month", comment: "")
            } else {
                cell.priceLabel.text = option.formattedPrice
            }
            if let currentSubscription = SubscriptionService.shared.currentSubscription {
                if option.product.productIdentifier == currentSubscription.productId,
                    currentSubscription.isActive {
                    cell.isCurrentPlan = true
                    if option.product.productIdentifier.contains("Unlimited") {

                    } else {
                        cell.yourPlanLabel.text = cell.yourPlanLabel.text! + "\n" + NSLocalizedString("Expiry date: ", comment: "") + currentSubscription.expiresDate.local
                    }
                }
                // Nếu đã đăng ký thì vô hiệu hóa hết các lựa chọn
                cell.isUserInteractionEnabled = false
                cell.nameLabel.isEnabled = false
                cell.descriptionLabel.isEnabled = false
                cell.priceLabel.isEnabled = false
                cell.alpha = 0.5
            }
            if getUnlimited() {
                if option.product.productIdentifier.contains("Unlimited") {
                    cell.isCurrentPlan = true
                }
                cell.isUserInteractionEnabled = false
                cell.nameLabel.isEnabled = false
                cell.descriptionLabel.isEnabled = false
                cell.priceLabel.isEnabled = false
                cell.alpha = 0.5
                if let currentSubscription = SubscriptionService.shared.currentSubscription {
                    print(NSLocalizedString("Expiry date: ", comment: "") + currentSubscription.expiresDate.local)
                }
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath)
            return cell
        }
    }
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.section == 0 {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Option", for: indexPath) as! SubscriptionOptionTableViewCell
//            guard let option = options?[indexPath.row] else { return cell }
//
//            cell.nameLabel.text = option.product.localizedTitle
//            cell.descriptionLabel.text = option.product.localizedDescription
//            cell.priceLabel.text = option.formattedPrice
//            cell.yourPlanLabel.text = NSLocalizedString("You are on this plan!", comment: "")
//
//            if let currentSubscription = SubscriptionService.shared.currentSubscription {
//                if option.product.productIdentifier == currentSubscription.productId {
//                    cell.isCurrentPlan = true
//                }
//            }
//            print(getProVersion())
//            print(cell.isCurrentPlan)
//            return cell
//        } else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "Button", for: indexPath)
//            return cell
//        }
//    }
}

// MARK: - UITableViewDelegate

extension SubscribeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            guard let option = options?[indexPath.row] else { return }
            SubscriptionService.shared.purchase(subscription: option)
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
            SubscriptionService.shared.restorePurchases()
        }
    }
}

