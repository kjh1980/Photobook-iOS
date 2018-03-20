//
//  ReceiptTableViewController.swift
//  Photobook
//
//  Created by Konstadinos Karayannis on 29/01/2018.
//  Copyright © 2018 Kite.ly. All rights reserved.
//

import UIKit
import PassKit

struct ReceiptNotificationName {
    static let receiptWillDismiss = Notification.Name("receiptWillDismissNotificationName")
}

class ReceiptTableViewController: UITableViewController {
    
    private struct Constants {
        static let infoTitleCompleted = NSLocalizedString("ReceiptTableViewController/InfoTitleCompleted", value: "Ready to Print", comment: "Status title if order has been completed and product is ready to print")
        static let infoDescriptionCompleted = NSLocalizedString("ReceiptTableViewController/InfoDescriptionCompleted", value: "We have received your photos and we will begin processing your photobook shortly", comment: "Info text when order has been completed")
        static let infoTitleError = NSLocalizedString("ReceiptTableViewController/InfoTitleError", value: "Something Went Wrong!", comment: "Status title if order couldn't be completed")
        static let infoDescriptionError = NSLocalizedString("ReceiptTableViewController/InfoDescriptionError", value: "Something happened and we can't receive your photos at this point. You can retry or cancel and be refunded", comment: "Info text when order couldn't be completed")
        static let infoTitleCancelled = NSLocalizedString("ReceiptTableViewController/InfoTitleCancelled", value: "Order Cancelled", comment: "Status title if was cancelled")
        static let infoDescriptionCancelled = NSLocalizedString("ReceiptTableViewController/InfoDescriptionCancelled", value: "Something happened and we can't receive your photos at this point but we haven't charged you anything", comment: "Info text when order couldn't be completed")
        static let infoTitlePaymentFailed = NSLocalizedString("ReceiptTableViewController/InfoTitlePaymentFailed", value: "Your Payment Method Failed", comment: "Payment has failed")
        static let infoDescriptionPaymentFailed = NSLocalizedString("ReceiptTableViewController/InfoDescriptionPaymentFailed", value: "The charge for your book was declined.\nYou can retry with another method", comment: "Info text when payment method has failed")
        
        static let loadingPaymentText = NSLocalizedString("Controllers/ReceiptTableViewController/PaymentLoadingText",
                                                          value: "Preparing Payment",
                                                          comment: "Info text displayed while preparing for payment service")
        static let loadingFinishingOrderText = NSLocalizedString("Controllers/ReceiptTableViewController/loadingFinishingOrderText",
                                                                 value: "Finishing order",
                                                                 comment: "Info text displayed while finishing order")
        
        static let infoButtonTitleRetry = NSLocalizedString("ReceiptTableViewController/InfoButtonRetry", value: "Retry", comment: "Info button text when order couldn't be completed")
        static let infoButtonTitleOK = NSLocalizedString("ReceiptTableViewController/InfoButtonCancelled", value: "OK", comment: "Info button when order was cancelled")
        static let infoButtonTitleUpdate = NSLocalizedString("ReceiptTableViewController/InfoButtonPaymentFailed", value: "Update", comment: "Info button when payment has failed and payment method can be updated")
    }
    
    private enum Section: Int {
        case header, progress, info, details, lineItems, footer
    }
    
    private enum State: Int {
        case uploading
        case error
        case completed
        case cancelled
        case paymentFailed
        case paymentRetry
        
        func configure(headerCell cell:ReceiptHeaderTableViewCell) {
            switch self {
            case .uploading:
                cell.titleLabel.text = NSLocalizedString("ReceiptTableViewController/TitleUploading", value: "Processing Order", comment: "Receipt sceen title when uploading images")
            case .completed:
                cell.titleLabel.text = NSLocalizedString("ReceiptTableViewController/TitleCompleted", value: "Order Complete", comment: "Receipt sceen title when successfully completed uploading images and order is confirmed")
            case .error:
                cell.titleLabel.text = NSLocalizedString("ReceiptTableViewController/TitleError", value: "Upload Failed", comment: "Receipt sceen title when uploading images fails")
            case .cancelled:
                cell.titleLabel.text = NSLocalizedString("ReceiptTableViewController/TitleCancelled", value: "Order Cancelled", comment: "Receipt sceen title if order had to be cancelled because of unresolvable technical problems")
            case .paymentFailed, .paymentRetry:
                cell.titleLabel.text = NSLocalizedString("ReceiptTableViewController/TitlePaymentFailed", value: "Payment Failed", comment: "Receipt sceen title if payment fails and payment method has to be updated")
            }
        }
        
        func configure(infoCell cell:ReceiptInfoTableViewCell) {
            switch self {
            case .completed:
                cell.iconLabel.text = "👍"
                cell.titleLabel.text = Constants.infoTitleCompleted.uppercased()
                cell.descriptionLabel.text = Constants.infoDescriptionCompleted
                cell.setActionButtonsHidden(true)
            case .error:
                cell.iconLabel.text = "😰"
                cell.titleLabel.text = Constants.infoTitleError.uppercased()
                cell.descriptionLabel.text = Constants.infoDescriptionError
                cell.primaryActionButton.setTitle(Constants.infoButtonTitleRetry.uppercased(), for: .normal)
                cell.setActionButtonsHidden(false)
            case .cancelled:
                cell.iconLabel.text = "😵"
                cell.titleLabel.text = Constants.infoTitleCancelled.uppercased()
                cell.descriptionLabel.text = Constants.infoDescriptionCancelled
                cell.primaryActionButton.setTitle(Constants.infoButtonTitleOK.uppercased(), for: .normal)
                cell.setActionButtonsHidden(true)
            case .paymentFailed, .paymentRetry:
                cell.iconLabel.text = "😔"
                cell.titleLabel.text = Constants.infoTitlePaymentFailed.uppercased()
                cell.descriptionLabel.text = Constants.infoDescriptionPaymentFailed
                cell.primaryActionButton.setTitle(Constants.infoButtonTitleUpdate.uppercased(), for: .normal)
                cell.setActionButtonsHidden(false)
            default: break
            }
            
            if self == .paymentRetry {
                cell.setSecondaryActionButtonHidden(false)
                cell.primaryActionButton.setTitle(Constants.infoButtonTitleRetry.uppercased(), for: .normal)
                cell.secondaryActionButton.setTitle(Constants.infoButtonTitleUpdate.uppercased(), for: .normal)
            } else {
                cell.setSecondaryActionButtonHidden(true)
            }
        }
        
        func configure(dismissButton barButtonItem:UIBarButtonItem) {
            let successString = NSLocalizedString("ReceiptTableViewController/DismissButtonSuccess", value: "Continue", comment: "Button displayed after order was placed successfully")
            let failString = NSLocalizedString("ReceiptTableViewController/DismissButtonFail", value: "Cancel", comment: "Button displayed when something has gone wrong and order couldn't be placed. This gives the user the option to cancel the upload and purchase")
            switch self {
            case .uploading:
                barButtonItem.isEnabled = false
                barButtonItem.tintColor = .clear
            case .completed:
                barButtonItem.isEnabled = true
                barButtonItem.tintColor = nil
                barButtonItem.title = successString
            case .error:
                barButtonItem.isEnabled = true
                barButtonItem.tintColor = nil
                barButtonItem.title = failString
            case .cancelled:
                barButtonItem.isEnabled = true
                barButtonItem.tintColor = nil
                barButtonItem.title = failString
            case .paymentFailed, .paymentRetry:
                barButtonItem.isEnabled = true
                barButtonItem.tintColor = nil
                barButtonItem.title = failString
            }
        }
    }
    
    private var cost: Cost? {
        return OrderManager.shared.cachedCost
    }
    
    private var state:State = .uploading {
        didSet {
            if state != oldValue {
                updateViews()
            }
        }
    }
    private var lastProcessingError:OrderProcessingError?
    
    @IBOutlet weak var dismissBarButtonItem: UIBarButtonItem!
    var dismissClosure:(() -> Void)?
    
    private var modalPresentationDismissedGroup = DispatchGroup()
    private lazy var paymentManager: PaymentAuthorizationManager = {
        let manager = PaymentAuthorizationManager()
        manager.delegate = self
        return manager
    }()
    
    private lazy var emptyScreenViewController: EmptyScreenViewController = {
        return EmptyScreenViewController.emptyScreen(parent: self)
    }()
    
    private lazy var progressOverlayViewController: ProgressOverlayViewController = {
        return ProgressOverlayViewController.progressOverlay(parent: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Analytics.shared.trackScreenViewed(Analytics.ScreenName.receipt)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem()
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    
        OrderManager.shared.loadCheckoutDetails()
        updateViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(orderProcessingCompleted), name: OrderProcessingManager.Notifications.completed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orderProcessingFailed(_:)), name: OrderProcessingManager.Notifications.failed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pendingUploadsChanged), name: OrderProcessingManager.Notifications.pendingUploadStatusUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(orderProcessingWillFinish), name: OrderProcessingManager.Notifications.willFinishOrder, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loadingString = NSLocalizedString("ReceiptTableViewController/LoadingData", value: "Loading info...", comment: "description for a loading indicator")
        emptyScreenViewController.show(message: loadingString, activity: true)
        
        if OrderProcessingManager.shared.isProcessingOrder {
            if state == .paymentFailed {
                //re entered screen from payment methods screen
                state = .paymentRetry
                emptyScreenViewController.hide(animated: true)
                return
            }
            
            //re entered app, load and resume upload
            ProductManager.shared.loadUserPhotobook()
            emptyScreenViewController.hide(animated: true)
        } else {
            //start processing
            OrderProcessingManager.shared.startProcessing()
            emptyScreenViewController.hide(animated: true)
        }

    }
    
    //MARK: Population
    
    private func updateViews() {
        tableView.reloadData()
        state.configure(dismissButton: dismissBarButtonItem)
    }
    
    //MARK: Actions
    
    @IBAction private func primaryActionButtonTapped(_ sender: UIBarButtonItem) {
        switch state {
        case .error:
            if let lastProcessingError = lastProcessingError {
                switch lastProcessingError {
                case .upload:
                    OrderProcessingManager.shared.startPhotobookUpload()
                    self.state = .uploading
                case .pdf, .submission:
                    OrderProcessingManager.shared.finishOrder()
                default: break
                }
            }
        case .paymentFailed:
            showPaymentMethods()
        case .paymentRetry:
            //re authorize payment and submit order again
            pay()
            break
        case .cancelled:
            dismiss()
        default: break
        }
    }
    
    @IBAction private func secondaryActionButtonTapped(_ sender: UIBarButtonItem) {
        if state == .paymentRetry {
            showPaymentMethods()
        }
    }

    @IBAction private func continueTapped(_ sender: UIBarButtonItem) {
        if state != .completed {
            let title = NSLocalizedString("ReceiptTableViewController/DismissAlertTitle", value: "Cancel Order?", comment: "Alert title when the user wants to close the upload/receipt screen")
            let message = NSLocalizedString("ReceiptTableViewController/DismissAlertMessage", value: "You have not been charged yet. Please note, if you cancel your design will be lost.", comment: "Alert message when the user wants to close the upload/receipt screen")
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: CommonLocalizedStrings.no, style: .default, handler:nil))
            alertController.addAction(UIAlertAction(title: CommonLocalizedStrings.yes, style: .destructive, handler: { [weak welf = self] (_) in
                welf?.dismiss()
            }))
            
            present(alertController, animated: true, completion: nil)
        } else {
            dismiss()
        }
    }
    
    private func dismiss() {
        OrderProcessingManager.shared.cancelProcessing { [weak welf = self] in
            ProductManager.shared.reset()
            OrderManager.shared.reset()
            NotificationCenter.default.post(name: ReceiptNotificationName.receiptWillDismiss, object: nil)
            welf?.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
            welf?.navigationController?.popToRootViewController(animated: true)
            welf?.dismissClosure?()
        }
    }
    
    private func pay() {
        guard let cost = cost else {
            return
        }
        
        if OrderManager.shared.paymentMethod == .applePay {
            modalPresentationDismissedGroup.enter()
        }
        
        guard let paymentMethod = OrderManager.shared.paymentMethod else { return }
        
        progressOverlayViewController.show(message: Constants.loadingPaymentText)
        paymentManager.authorizePayment(cost: cost, method: paymentMethod)
    }
    
    private func showPaymentMethods() {
        let paymentViewController = storyboard?.instantiateViewController(withIdentifier: "PaymentMethodsViewController") as! PaymentMethodsViewController
        navigationController?.pushViewController(paymentViewController, animated: true)
    }
    
    //MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case Section.header.rawValue:
            return 1
        case Section.progress.rawValue:
            return state == .uploading ? 1 : 0
        case Section.info.rawValue:
            return state == .uploading ? 0 : 1
        case Section.details.rawValue:
            if state == .cancelled { return 0 }
            return 1
        case Section.lineItems.rawValue:
            if state == .cancelled { return 0 }
            return cost?.lineItems?.count ?? 0
        case Section.footer.rawValue:
            if state == .cancelled { return 0 }
            return 1
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case Section.header.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptHeaderTableViewCell.reuseIdentifier, for: indexPath) as! ReceiptHeaderTableViewCell
            
            state.configure(headerCell: cell)
            
            return cell
        case Section.progress.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptProgressTableViewCell.reuseIdentifier, for: indexPath) as! ReceiptProgressTableViewCell
            
            cell.updateProgress(pendingUploads: ProductManager.shared.pendingUploads, totalUploads: ProductManager.shared.totalUploads)
            cell.startProgressAnimation()
            
            return cell
        case Section.info.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptInfoTableViewCell.reuseIdentifier, for: indexPath) as! ReceiptInfoTableViewCell
            
            state.configure(infoCell: cell)
            cell.primaryActionButton.addTarget(self, action: #selector(primaryActionButtonTapped(_:)), for: .touchUpInside)
            cell.secondaryActionButton.addTarget(self, action: #selector(secondaryActionButtonTapped(_:)), for: .touchUpInside)
            
            return cell
        case Section.details.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptDetailsTableViewCell.reuseIdentifier, for: indexPath) as! ReceiptDetailsTableViewCell
            cell.shippingMethodLabel.text = cost?.shippingMethod(id: OrderManager.shared.shippingMethod)?.name
            
            cell.orderNumberLabel.alpha = 0.35
            switch state {
            case .uploading:
                cell.orderNumberLabel.text = NSLocalizedString("ReceiptTableViewController/OrderNumberPending", value: "Pending", comment: "Placeholder for order number while images are being uploaded")
            case .completed:
                if let orderId = OrderManager.shared.orderId {
                    cell.orderNumberLabel.text = "#\(orderId)"
                    cell.orderNumberLabel.alpha = 1
                } else {
                    cell.orderNumberLabel.text = NSLocalizedString("ReceiptTableViewController/OrderNumberUnknown", value: "N/A", comment: "Placeholder for order number in the unlikely case when there is none")
                }
            case .error, .cancelled, .paymentFailed, .paymentRetry:
                cell.orderNumberLabel.text = NSLocalizedString("ReceiptTableViewController/OrderNumberFailed", value: "Failed", comment: "Placeholder for order number when image upload has failed")
            }
            
            let deliveryDetails = OrderManager.shared.deliveryDetails
            var addressString = ""
            if let name = deliveryDetails?.fullName, !name.isEmpty { addressString += "\(name)\n"}
            if let line1 = deliveryDetails?.address?.line1, !line1.isEmpty { addressString += "\(line1)\n"}
            if let line2 = deliveryDetails?.address?.line2, !line2.isEmpty { addressString += "\(line2)\n"}
            if let city = deliveryDetails?.address?.city, !city.isEmpty { addressString += "\(city) "}
            if let postCode = deliveryDetails?.address?.zipOrPostcode, !postCode.isEmpty { addressString += "\(postCode)\n"}
            if let countryName = deliveryDetails?.address?.country.name, !countryName.isEmpty { addressString += "\(countryName)\n"}
            cell.shippingAddressLabel.text = addressString
            
            return cell
        case Section.lineItems.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptLineItemTableViewCell.reuseIdentifier, for: indexPath) as! ReceiptLineItemTableViewCell
            cell.lineItemNameLabel.text = cost?.lineItems?[indexPath.row].name
            cell.lineItemCostLabel.text = cost?.lineItems?[indexPath.row].formattedCost
            return cell
        case Section.footer.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReceiptFooterTableViewCell.reuseIdentifier, for: indexPath) as! ReceiptFooterTableViewCell
            cell.totalCostLabel.text = cost?.shippingMethod(id: OrderManager.shared.shippingMethod)?.totalCostFormatted
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    //MARK: - Order Processing
    
    @objc func pendingUploadsChanged() {
        tableView.reloadData()
    }
    
    @objc func orderProcessingCompleted() {
        progressOverlayViewController.hide()
        state = .completed
    }

    @objc func orderProcessingFailed(_ notification: NSNotification) {
        if let error = notification.userInfo?["error"] as? OrderProcessingError {
            switch error {
            case .payment:
                state = .paymentFailed
            default: break
            }
            lastProcessingError = error
        }
        state = .error
        progressOverlayViewController.hide()
    }
    
    @objc func orderProcessingWillFinish() {
        progressOverlayViewController.show(message: Constants.loadingFinishingOrderText)
    }
    
}

extension ReceiptTableViewController : PaymentAuthorizationManagerDelegate {
    
    func costUpdated() {
        updateViews()
    }
    
    func modalPresentationWillBegin() {
        progressOverlayViewController.hide()
    }
    
    func paymentAuthorizationDidFinish(token: String?, error: Error?, completionHandler: ((PKPaymentAuthorizationStatus) -> Void)?) {
        if let errorMessage = ErrorMessage(error) {
            progressOverlayViewController.hide()
            self.present(UIAlertController(errorMessage: errorMessage), animated: true)
            return
        }
        
        OrderManager.shared.paymentToken = token
        
        OrderProcessingManager.shared.finishOrder()
    }
    
    func modalPresentationDidFinish() {
        modalPresentationDismissedGroup.leave()
    }
    
}
