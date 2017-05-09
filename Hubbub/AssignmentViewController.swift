//
//  SlotDetailViewController.swift
//  Hubbub
//
//  Created by Justin Rosenthal on 5/4/17.
//  Copyright © 2017 All The Hubbub. All rights reserved.
//


import Firebase
import FirebaseDatabaseUI
import MaterialComponents
import MaterialComponents.MaterialPalettes
import SnapKit
import UIKit

private let TopicSectionNumber = 0
private let LocationSectionNumber = 1
private let MembersSectionNumber = 2

private let TopicHeaderReuseIdentifier = "TopicHeaderReuseIdentifier"
private let LocationHeaderReuseIdentifier = "LocationHeaderReuseIdentifier"
private let MembersHeaderReuseIdentifier = "MembersHeaderReuseIdentifier"
private let MembersReuseIdentifier = "MembersReuseIdentifier"
private let MembersFooterReuseIdentifier = "MembersFooterReuseIdentifier"

class AssignmentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FUIIndexArrayDelegate {

    // UI
    let appBar = MDCAppBar()
    let headerView = AssignmentHeaderView()
    var collectionView: UICollectionView?
    let beaconButton = MDCRaisedButton()
    
    // Properties
    var slot: Slot
    var topic: Topic?
    var assignment: Assignment?
    var members = [Profile]()
    
    // Database
    var memberSnapshots: FUIIndexArray?
    
    required init(slot: Slot, topic: Topic?) {
        self.slot = slot
        self.topic = topic
        
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(appBar.headerViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let indexArray = memberSnapshots {
            indexArray.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // App Bar
        appBar.addSubviewsToParent()
        appBar.headerViewController.headerView.backgroundColor = MDCPalette.blueGrey().tint800
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: #imageLiteral(resourceName: "ic_arrow_back_white"),
            style: .done,
            target: self,
            action: #selector(back)
        )
        
        // Header View
        headerView.slot = slot
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(appBar.headerViewController.headerView.snp.bottom)
        }

        // CollectionView
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.itemSize = CGSize(width: view.frame.width, height: 55)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView!.backgroundColor = #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
        collectionView!.delegate = self
        collectionView!.dataSource = self
        view.addSubview(collectionView!)
        collectionView!.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        // CollectionView Views
        collectionView!.register(
            AssignmentMemberCollectionViewCell.self,
            forCellWithReuseIdentifier: MembersReuseIdentifier
        )
        collectionView!.register(
            AssignmentTopicHeaderView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: TopicHeaderReuseIdentifier
        )
        collectionView!.register(
            AssignmentLocationHeaderView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: LocationHeaderReuseIdentifier
        )
        collectionView!.register(
            AssignmentMembersHeaderView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
            withReuseIdentifier: MembersHeaderReuseIdentifier
        )
        collectionView!.register(
            AssignmentMembersFooterView.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
            withReuseIdentifier: MembersFooterReuseIdentifier
        )
        
        if topic != nil {
            // Beacon Button
            beaconButton.setElevation(2, for: .normal)
            beaconButton.setTitle("Find your group", for: .normal)
            beaconButton.setBackgroundColor(ColorSecondary, for: .normal)
            beaconButton.setTitleColor(.white, for: .normal)
            beaconButton.sizeToFit()
            beaconButton.addTarget(self, action: #selector(showBeacon), for: UIControlEvents.touchUpInside)
            view.addSubview(beaconButton)
            beaconButton.snp.makeConstraints { (make) in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-30)
            }
            
            fetchAssignment()
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Internal
    
    internal func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    internal func fetchAssignment() {
        guard let topic = self.topic else { return }
        
        let ref = FIRDatabase.database().reference(withPath: "assignments/\(slot.id)/\(topic.id)")
        ref.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            guard let strongSelf = self else { return }
            
            if let assignment = Assignment(snapshot: snapshot) {
                strongSelf.assignment = assignment
                strongSelf.fetchMembers(for: assignment)
            }
        })
    }
    
    internal func fetchMembers(for assignment: Assignment) {
        guard let topic = self.topic else { return }
        
        memberSnapshots = FUIIndexArray(
            index: FIRDatabase.database().reference(withPath: "assignments/\(slot.id)/\(topic.id)/members"),
            data: FIRDatabase.database().reference(withPath: "profiles"),
            delegate: self
        )
    }
    
    internal func showBeacon() {
        guard let topic = self.topic else { return }
        
        let beaconVC = BeaconViewController(slot: slot, topic: topic)
        present(beaconVC, animated: true, completion: nil)
    }
    
    // MARK: FUIIndexArrayDelegate
    
    internal func array(_ array: FUIIndexArray, reference ref: FIRDatabaseReference, didLoadObject object: FIRDataSnapshot, at index: UInt) {
        if let profile = Profile(snapshot: object) {
            members.append(profile)
        }
        
        // Done loading all members?
        if members.count == assignment?.members.count {
            // Alphabetize
            members.sort(by: { (a, b) -> Bool in
                if let aName = a.name, let bName = b.name {
                    return aName < bName
                }
                return a.userID < b.userID
            })
            
            collectionView?.reloadData()
        }
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == TopicSectionNumber {
            return CGSize(width: collectionView.frame.size.width, height: 48)
        }
        return CGSize(width: collectionView.frame.size.width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if topic == nil && section == MembersSectionNumber {
            return CGSize(width: collectionView.frame.size.width, height: 80)
        }
        return .zero
    }
    
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == MembersSectionNumber {
            return members.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MembersReuseIdentifier, for: indexPath)
        guard let memberCell = cell as? AssignmentMemberCollectionViewCell else {
            return cell
        }
        
        memberCell.profile = members[indexPath.row]
        
        return memberCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var view: UICollectionReusableView?
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            switch indexPath.section {
            case TopicSectionNumber:
                view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TopicHeaderReuseIdentifier, for: indexPath)
                if let topicHeaderView = view as? AssignmentTopicHeaderView {
                    topicHeaderView.topic = self.topic
                }
            case LocationSectionNumber:
                view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: LocationHeaderReuseIdentifier, for: indexPath)
                if let locationHeaderView = view as? AssignmentLocationHeaderView {
                    locationHeaderView.title = slot.location
                }
            case MembersSectionNumber:
                view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MembersHeaderReuseIdentifier, for: indexPath)
                if let membersHeaderView = view as? AssignmentMembersHeaderView {
                    if topic == nil {
                        membersHeaderView.title = "Guests"
                    } else if members.count == 0 {
                        membersHeaderView.title = "Loading..."
                    } else if members.count == 1 {
                        membersHeaderView.title = "1 guest"
                    } else {
                        membersHeaderView.title = "\(members.count) guests"
                    }
                }
            default:
                break
            }
        case UICollectionElementKindSectionFooter:
            switch indexPath.section {
            case MembersSectionNumber:
                view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: MembersFooterReuseIdentifier, for: indexPath)
            default:
                break
            }
        default:
            break
        }
        
        return view ?? UICollectionReusableView()
    }
}
