//
//  HomeViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 4/18/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//

import Firebase
import FirebaseDatabaseUI
import MaterialComponents
import SnapKit
import UIKit

class HomeViewController: UIViewController, UITableViewDelegate {

    // UI
    let appBar = MDCAppBar()
    let headerView = HomeHeaderView()
    let slotsTableView = UITableView(frame: .zero, style: .plain)
    let slotsTableFooterView = EmptyStateTableFooterView(insets: UIEdgeInsetsMake(22, 66, 22, 66))

    // Properties
    var user: FIRUser

    // Database
    internal var profileRef: FIRDatabaseReference?
    internal var profileHandle: UInt?
    internal var slotsQuery: FIRDatabaseQuery?
    internal var slotsDatasource: FUITableViewDataSource?

    required init(user: FIRUser) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        addChildViewController(appBar.headerViewController)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let ref = profileRef, let handle = profileHandle {
            ref.removeObserver(withHandle: handle)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appBar.addSubviewsToParent()
        appBar.headerViewController.headerView.backgroundColor = ColorPrimary
        appBar.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
        ]

        // Nav Bar
        navigationItem.title = "Hubbub"
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_more_vert_white"), style: .plain, target: self, action: #selector(showActionMenu))

        // Header
        headerView.setElevation(points: 2)
        view.insertSubview(headerView, at: 0)
        headerView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(appBar.headerViewController.headerView.snp.bottom)
        }

        // Slots
        slotsTableView.delegate = self
        slotsTableView.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        slotsTableView.separatorInset = .zero
        slotsTableView.tableHeaderView = HomeSlotsTableHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: 60))
        view.insertSubview(slotsTableView, at: 0)
        slotsTableView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        slotsTableView.register(AccountSlotTableViewCell.self, forCellReuseIdentifier: "slotsCell")

        // Slots Footer
        slotsTableFooterView.loading = false
        slotsTableFooterView.message = "Add an event to hangout with people that share your interests!"
        slotsTableView.tableFooterView = slotsTableFooterView

        // Join Button
        let joinButton = MDCFloatingButton(shape: .default)
        joinButton.setImage(#imageLiteral(resourceName: "ic_add_white"), for: .normal)
        joinButton.setBackgroundColor(ColorSecondary, for: .normal)
        joinButton.addTarget(self, action: #selector(presentSlots), for: .touchUpInside)
        view.addSubview(joinButton)
        joinButton.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-20)
        }

        bindSlots()
        bindProfile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let indexPath = slotsTableView.indexPathForSelectedRow {
            slotsTableView.deselectRow(at: indexPath, animated: animated)
        }
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // MARK: Internal

    internal func showActionMenu() {
        let title = (UIApplication.shared.delegate as? AppDelegate)?.appVersionString
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let logout = UIAlertAction(title: "Sign out", style: .destructive) { [unowned self] _ in
            self.doLogout()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(logout)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }

    internal func presentSlots() {
        let slotsVC = SlotsViewController(user: user)
        navigationController?.pushViewController(slotsVC, animated: true)
    }

    internal func doLogout() {
        try? FIRAuth.auth()?.signOut()
    }

    internal func bindSlots() {
        // Fetch the next 10 slots this user has joined
        slotsQuery = FIRDatabase.database().reference(withPath: "accounts/\(user.uid)/events")
            .queryOrdered(byChild: "endAt")
            .queryStarting(atValue: Date().timeIntervalSince1970)
            .queryLimited(toFirst: 10)

        slotsDatasource = slotsTableView.bind(to: slotsQuery!, populateCell: { (tableView, indexPath, snapshot) -> UITableViewCell in
            let cell = tableView.dequeueReusableCell(withIdentifier: "slotsCell", for: indexPath)
            if let slot = Slot(snapshot: snapshot) {
                (cell as! AccountSlotTableViewCell).slot = slot
            }
            return cell
        })
    }

    internal func bindProfile() {
        profileRef = FIRDatabase.database().reference(withPath: "profiles/\(user.uid)")
        profileHandle = profileRef!.observe(.value, with: { [weak self] snapshot in
            guard let strongSelf = self else { return }

            strongSelf.headerView.profile = Profile(snapshot: snapshot)
        })
    }

    internal func manageFooterView() {
        if slotsDatasource?.count == 0 {
            slotsTableView.tableFooterView = slotsTableFooterView
        } else {
            slotsTableView.tableFooterView = nil
        }
    }

    // MARK: UITableViewDelegate

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        return 75
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let snapshot = slotsDatasource?.snapshot(at: indexPath.row), let slot = Slot(snapshot: snapshot) {
            let assignmentVC = AssignmentViewController(slot: slot, topic: slot.topic)
            navigationController?.pushViewController(assignmentVC, animated: true)
        }
    }

    func tableView(_: UITableView, willDisplay _: UITableViewCell, forRowAt _: IndexPath) {
        manageFooterView()
    }

    func tableView(_: UITableView, didEndDisplaying _: UITableViewCell, forRowAt _: IndexPath) {
        manageFooterView()
    }
}
