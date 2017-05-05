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

class AssignmentViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FUIIndexArrayDelegate {

    // UI
    let appBar = MDCAppBar()
    let headerView = AssignmentHeaderView()
    var collectionView: UICollectionView?
    let beaconButton = MDCRaisedButton()
    
    // Properties
    var slot: Slot
    var topic: Topic
    var assignment: Assignment?
    var members = [Profile]()
    
    // Database
    var memberSnapshots: FUIIndexArray?
    
    required init(slot: Slot, topic: Topic) {
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
        collectionView!.register(AssignmentMemberCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView!.register(AssignmentCollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        view.addSubview(collectionView!)
        collectionView!.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalTo(headerView.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: Internal
    
    internal func back() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    internal func fetchAssignment() {
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
        memberSnapshots = FUIIndexArray(
            index: FIRDatabase.database().reference(withPath: "assignments/\(slot.id)/\(topic.id)/members"),
            data: FIRDatabase.database().reference(withPath: "profiles"),
            delegate: self
        )
    }
    
    internal func showBeacon() {
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        guard let memberCell = cell as? AssignmentMemberCollectionViewCell else {
            return cell
        }
        
        memberCell.profile = members[indexPath.row]
        
        return memberCell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath)
        guard let assignmentHeader = view as? AssignmentCollectionViewHeader else {
            return view
        }
        
        var icon: UIImage?
        var topic: Topic?
        var title: String?
        
        switch indexPath.section {
        case TopicSectionNumber:
            icon = #imageLiteral(resourceName: "ic_subject")
            topic = Topic(data: ["id": "foo", "name": "Firebase"])
        case LocationSectionNumber:
            icon = #imageLiteral(resourceName: "ic_location_on")
            title = slot.location
        case MembersSectionNumber:
            icon = #imageLiteral(resourceName: "ic_people")
            if members.count == 0 {
                title = "Loading..."
            } else if members.count == 1 {
                title = "1 guest"
            } else {
                title = "\(members.count) guests"
            }
        default: break
        }
        
        assignmentHeader.icon = icon?.withRenderingMode(.alwaysTemplate)
        assignmentHeader.topic = topic
        assignmentHeader.title = title
        
        return assignmentHeader
    }
}
