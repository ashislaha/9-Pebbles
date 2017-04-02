//
//  OnlineViewController.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 01/12/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit
import Firebase

class OnlineViewController: UIViewController {

    // datasource 
    var openUsersDataSource = [User]()
    var lockedUsersDataSource = [User]()
    var filteredDataSource = [User]()
    
    private var openUsersChannel : FIRDatabaseReference!
    var requestChannel : FIRDatabaseReference!
    private var openUsersRefHandle: FIRDatabaseHandle?
    var searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.refreshControl = UIRefreshControl(frame: CGRect.zero)
        tableView.refreshControl?.addTarget(self, action: #selector(OnlineViewController.refresh), for: .allEvents)
        retrievOnlineUsers()
        
        // setup search controller
        
        searchController.dimsBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func refresh(){
        retrievOnlineUsers()
    }
    
    @IBAction func close(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func retrievOnlineUsers() {
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate {
            let onlineChannel = appDel.ref.child(DataBaseConstants.OnlineChannel)
            
            //retrieve open users
            openUsersChannel = onlineChannel.child(DataBaseConstants.OpenUsers)
            openUsersRefHandle = openUsersChannel.observe(.value, with: { (snapShot) in
                if let dictionary = snapShot.value as? [String : [String : String]]  {
                    self.openUsersDataSource = [User]()
                    self.tableView.refreshControl?.beginRefreshing()
                    for (key,value) in dictionary {
                        if key != appDel.loggedInUser?.userId { // add except you
                            let name = value[DataBaseConstants.name]
                            let email = value[DataBaseConstants.gmail]
                            if let name = name , let email = email {
                                self.openUsersDataSource.append(User(name:name , emailId: email, userId: key))
                            }
                        }
                    }
                    self.tableView.reloadData()
                    self.tableView.refreshControl?.endRefreshing()
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeAllObservers()
    }
    
    deinit {
        removeAllObservers()
    }
    private func removeAllObservers() {
        if let handler = openUsersRefHandle {
            openUsersChannel?.removeObserver(withHandle: handler)
        }
        requestChannel?.removeAllObservers()
    }
    
    //MARK:- Orientation
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .portrait
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return .landscape
        } else {
            return .landscape
        }
    }
    override var shouldAutorotate: Bool {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return false
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            return true
        } else {
            return true
        }
    }
}

//MARK:- SearchViewController Delegate 

extension OnlineViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filteredDataSource = openUsersDataSource.filter({ user in
            if let searchText = searchController.searchBar.text , searchText != "" {
                return user.name.lowercased().contains(searchText.lowercased())
            }
            return false
        })
        tableView.reloadData()
    }
}

//MARK:- TableView Delegate and DataSource

extension OnlineViewController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredDataSource.count
        }
       return self.openUsersDataSource.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "open")  {
            var user : User!
            if searchController.isActive && searchController.searchBar.text != "" {
                user = filteredDataSource[indexPath.row]
            } else {
                user = self.openUsersDataSource[indexPath.row]
            }
            cell.textLabel?.text = user.name
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell is selected : \(indexPath.row)")
        
        // update the online channel, add in "Sync" database and delete from "open" database for both user. Will do after "acknowledgement" of player
        // send request to the user
        
        if let appDel = UIApplication.shared.delegate as? AppDelegate, let uid = appDel.loggedInUser?.userId ,let name = appDel.loggedInUser?.name {
            let user = openUsersDataSource[indexPath.row]
            appDel.tempPlayingWith = user
            let onlineChannel = appDel.ref.child(DataBaseConstants.OnlineChannel)
            let child =  uid + "-" + user.userId
            requestChannel = onlineChannel.child(DataBaseConstants.RequestUsers+"/\(child)")
            let dict = ["from" : name, "to" : user.name]
            requestChannel.setValue(dict)
            
            // remove from open channel those 2 users
            let from = onlineChannel.child("/" + DataBaseConstants.OpenUsers + "/" + uid)
            let to = onlineChannel.child("/" + DataBaseConstants.OpenUsers + "/" + user.userId)
            from.removeValue()
            to.removeValue()
            
            // show alert that req send to the user
            if let toUserName = user.name {
                self.showAlertWithTimer(title: "Request Sent", message: "Wait for acknowledgement from : \(toUserName)", completionBlock: {
                    self.dismiss(animated: true, completion: nil)
                    PlayerManager.sharedInstance.isRequestSentByMe = true
                })
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Online Users"
    }

    
    func showAlertWithTimer(title : String, message : String, completionBlock : (()-> Void)? = nil ){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        present(alert, animated: true, completion: {
            // give a delay and then dismiss alert
            let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: { (timer) in
                alert.dismiss(animated: true, completion: {
                    completionBlock?()
                })
            })
        })
    }
}


