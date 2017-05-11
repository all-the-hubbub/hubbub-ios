//
//  SlotsViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 4/30/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Alamofire
import Firebase
import MaterialComponents
import MaterialComponents.MaterialSnackbar
import SnapKit
import UIKit

class SlotsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ToggleSlotTableViewCellDelegate {

    // UI
    let appBar = MDCAppBar()
    let slotsTableView: UITableView = UITableView(frame: .zero, style: .plain)
    let slotsTableFooterView = EmptyStateTableFooterView(insets: UIEdgeInsetsMake(40, 66, 40, 66))

    // Properties
    var user: FIRUser

    // Internal Properties
    internal var slots: [Slot] = [Slot]()
    internal var accountSlotIds: Set<String> = Set<String>()

    // Database
    internal var slotsQuery: FIRDatabaseQuery?
    internal var accountSlotsQuery: FIRDatabaseQuery?
    internal var accountSlotsHandles = [UInt]()

    required init(user: FIRUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        addChildViewController(appBar.headerViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let query = accountSlotsQuery {
            for handle in accountSlotsHandles {
                query.removeObserver(withHandle: handle)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        appBar.addSubviewsToParent()
        appBar.headerViewController.headerView.backgroundColor = ColorPrimary
        appBar.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
        ]
        if let navShadowLayer = appBar.headerViewController.headerView.shadowLayer as? MDCShadowLayer {
            navShadowLayer.elevation = 3
        }

        // Nav Bar
        navigationItem.title = "Join an event"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_arrow_back_white"),
            style: .done,
            target: self,
            action: #selector(back)
        )

        // Slots
        slotsTableView.delegate = self
        slotsTableView.dataSource = self
        slotsTableView.allowsSelection = false
        slotsTableView.backgroundColor = .white
        view.insertSubview(slotsTableView, at: 0)
        slotsTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(appBar.headerViewController.headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        slotsTableView.register(ToggleSlotTableViewCell.self, forCellReuseIdentifier: "slotsCell")

        // Slots Footer
        slotsTableFooterView.loading = true
        slotsTableFooterView.message = "There are currently no upcoming events, be sure to check back later!"
        slotsTableView.tableFooterView = slotsTableFooterView

        let now = Date().timeIntervalSince1970
        fetchSlots(startAt: now, limit: 10)
        bindAccountSlots(startAt: now, limit: 10)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Internal

    internal func back() {
        _ = navigationController?.popViewController(animated: true)
    }

    internal func fetchSlots(startAt: TimeInterval, limit: UInt) {
        slotsQuery = FIRDatabase.database().reference(withPath: "events")
            .queryOrdered(byChild: "startAt")
            .queryStarting(atValue: startAt)
            .queryLimited(toFirst: limit)

        slotsQuery!.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }

            var newSlots = [Slot]()
            for child in snapshot.children {
                if let slotSnapshot = child as? FIRDataSnapshot, let slot = Slot(snapshot: slotSnapshot) {
                    if slot.state == "open" {
                        newSlots.append(slot)
                    }
                }
            }

            strongSelf.slots = newSlots
            strongSelf.slotsTableView.reloadData()
            strongSelf.slotsTableFooterView.loading = false
            if newSlots.count > 0 {
                strongSelf.slotsTableView.tableFooterView = nil
            }
        })
    }

    internal func bindAccountSlots(startAt: TimeInterval, limit: UInt) {
        accountSlotsQuery = FIRDatabase.database().reference(withPath: "accounts/\(user.uid)/events")
            .queryOrdered(byChild: "startAt")
            .queryStarting(atValue: startAt)
            .queryLimited(toFirst: limit)

        var handle = accountSlotsQuery!.observe(.childAdded, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }

            let id = snapshot.key
            strongSelf.accountSlotIds.insert(id)
            strongSelf.reloadCellFor(slotId: id)
        })
        accountSlotsHandles.append(handle)

        handle = accountSlotsQuery!.observe(.childRemoved, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }

            let id = snapshot.key
            strongSelf.accountSlotIds.remove(id)
            strongSelf.reloadCellFor(slotId: id)
        })
        accountSlotsHandles.append(handle)
    }

    internal func reloadCellFor(slotId: String) {
        for (i, slot) in slots.enumerated() {
            if slot.id == slotId {
                let indexPath = IndexPath(row: i, section: 0)
                slotsTableView.reloadRows(at: [indexPath], with: .none)
                return
            }
        }
    }
    
    internal func showConfirmationFor(slot: Slot) {
        var message: String = ""
        if let startDate = slot.startDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d 'at' h:mm a"
            message = "Will you show up at \(slot.location!) on \(formatter.string(from: startDate))?\n\nOther Hubbubs will be waiting for you!"
        }
        
        let alert = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] _ in
            self?.rsvpFor(slot: slot, willAttend: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.reloadCellFor(slotId: slot.id)
        }))
        present(alert, animated: true)
    }
    
    internal func rsvpFor(slot: Slot, willAttend: Bool) {
        let params: Parameters = [
            "id": slot.id,
            "userId": user.uid,
            ]
        let call = willAttend ? "joinEvent" : "leaveEvent"
        let url = "https://\(Config.FunctionsHost)/\(call)"
        
        user.getTokenWithCompletion { token, err in
            if err != nil {
                print("Error getting user token: \(err)")
                return
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(token!)",
            ]
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers)
                .validate(statusCode: 200 ..< 300)
                .responseData { [weak self] response in
                    guard case let .failure(err) = response.result else { return }
                    print("API Error: \(err)")
                    
                    let message = MDCSnackbarMessage()
                    message.text = willAttend ? "Failed to join event" : "Failed to leave event"
                    MDCSnackbarManager.show(message)
                    
                    self?.reloadCellFor(slotId: slot.id)
            }
        }
    }

    // MARK: UITableViewDataSource

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return slots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "slotsCell", for: indexPath)
        if let toggleSlotCell = cell as? ToggleSlotTableViewCell {
            let slot = slots[indexPath.row]
            toggleSlotCell.delegate = self
            toggleSlotCell.slot = slot
            toggleSlotCell.checkBox.isChecked = accountSlotIds.contains(slot.id)
        }
        return cell
    }

    // MARK: UITableViewDelegate

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 75
    }

    // MARK: ToggleSlotTableViewCellDelegate

    func toggleSlotTableViewCell(_ cell: ToggleSlotTableViewCell, didSetToggleTo value: Bool) {
        guard let slot = cell.slot else { return }
        
        if value {
            showConfirmationFor(slot: slot)
        } else {
            rsvpFor(slot: slot, willAttend: false)
        }
    }
}
