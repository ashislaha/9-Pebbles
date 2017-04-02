//
//  AppDelegate.swift
//  9 Pebbles
//
//  Created by Ashis Laha on 21/05/16.
//  Copyright © 2016 Ashis Laha. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuth
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate , GIDSignInDelegate {

    var window: UIWindow?
    var ref : FIRDatabaseReference!
    var loggedInUser : User?
    var playingWith : User?
    var tempPlayingWith : User? // save the data for clearing the back-end if required, before receiving the acknowledgement.

    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    
    //MARK:- Google Sign In Delegate 
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            // Sign in error 
            print("SIGN IN ERROR : \(error.localizedDescription)")
            
            return
        }
        
        let authentication = user.authentication
        if let idToken = authentication?.idToken, let accessToken = authentication?.accessToken {
            let credential = FIRGoogleAuthProvider.credential(withIDToken:idToken , accessToken:accessToken)
            FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
                // You got user data , do what ever you want to.
                if let error = error {
                    print("Some autherntication error while logging in : \(error.localizedDescription) ")
                    if let controller = self.window?.rootViewController as? BaseViewController {
                        if let presentedController = controller.presentedViewController as? GoogleSignInViewController {
                            presentedController.showAlertWithTimerInSignInPage(title: "Error", message: error.localizedDescription, completionBlock: nil)
                        }
                    }
                    return
                }
                if let name = user?.displayName, let email = user?.email , let userId = user?.uid {
                    self.loggedInUser = User(name: name, emailId: email, userId: userId)
                    
                    // if google sign in page present, remove it
                    if let controller = self.window?.rootViewController as? BaseViewController {
                        if let presentedController = controller.presentedViewController as? GoogleSignInViewController {
                            presentedController.close(UIButton())
                        }
                    }
                }
            })
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // when user disconnect the app / sign out , do what ever the required here 
      
    }
    
    //MARK:- Application Delegate methods
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // configure firebase
        FIRApp.configure()
        ref = FIRDatabase.database().reference()
        
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.clearAllDataRelatedWithLoggedInUser()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
        clearAllDataRelatedWithLoggedInUser()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ALaha.__Pebbles" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "__Pebbles", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK:- Clear the data when user Sign out or close the app from Back-end
    
    func clearAllDataRelatedWithLoggedInUser(){
        
            clearOpenChannel()
            clearRequestChannel()
            clearLockChannel()
            clearChatChannel()
            
            try? FIRAuth.auth()?.signOut()
            self.loggedInUser = nil
            self.playingWith = nil
            self.tempPlayingWith = nil
            PlayerManager.sharedInstance.isRequestSentByMe = false
    }
    
    func clearRequestChannel() {
        // check "request" channel
        if let uid = self.loggedInUser?.userId , let playingWithUserID = self.tempPlayingWith?.userId {
            let requestChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.RequestUsers)
            if PlayerManager.sharedInstance.isRequestSentByMe {
                let childRef = requestChannel.child("\(uid)-\(playingWithUserID)")
                childRef.removeValue()
            } else {
                let childRef = requestChannel.child("\(playingWithUserID)-\(uid)")
                childRef.removeValue()
            }
        } else {
            // check the "request" channel
            if let uid = self.loggedInUser?.userId {
                let requestChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.RequestUsers)
                requestChannel.observe(.value, with: { (snapShot) in
                    if let dict = snapShot.value as? [String : Any] {
                        for (key,_) in dict {
                            if key.contains(uid) {
                                requestChannel.child("\(key)").removeValue()
                                break
                            }
                        }
                    }
                })
            }
        }
    }
    
    func clearLockChannel() {
        // check "lock" channel
        if let uid = self.loggedInUser?.userId , let playingWithUserID = self.tempPlayingWith?.userId {
            let lockChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers)
            if PlayerManager.sharedInstance.isRequestSentByMe {
                let childRef = lockChannel.child("\(uid)-\(playingWithUserID)")
                childRef.removeValue()
            } else {
                let childRef = lockChannel.child("\(playingWithUserID)-\(uid)")
                childRef.removeValue()
            }
        } else {
            // check the "Lock" channel
            if let uid = self.loggedInUser?.userId {
                let lockChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.LockedUsers)
                lockChannel.observe(.value, with: { (snapShot) in
                    if let dict = snapShot.value as? [String : Any] {
                        for (key,_) in dict {
                            if key.contains(uid) {
                                lockChannel.child("\(key)").removeValue()
                                break
                            }
                        }
                    }
                })
            }
        }
    }
    
    func clearChatChannel() {
        // check "common-chats" channel
        if let uid = self.loggedInUser?.userId , let playingWithUserID = self.tempPlayingWith?.userId {
            let commonChatChannel = self.ref.child(DataBaseConstants.CommonChat)
            if PlayerManager.sharedInstance.isRequestSentByMe {
                let childRef = commonChatChannel.child("\(uid)-\(playingWithUserID)")
                childRef.removeValue()
            } else {
                let childRef = commonChatChannel.child("\(playingWithUserID)-\(uid)")
                childRef.removeValue()
            }
        } else {
            // check the "common-chats" channel 
            if let uid = self.loggedInUser?.userId {
                let commonChatChannel = self.ref.child(DataBaseConstants.CommonChat)
                commonChatChannel.observe(.value, with: { (snapShot) in
                    if let dict = snapShot.value as? [String : Any] {
                        for (key,_) in dict {
                            if key.contains(uid) {
                                commonChatChannel.child("\(key)").removeValue()
                                break
                            }
                        }
                    }
                })
            }
        }
    }
    
    func clearOpenChannel() {
        // check "open" channel first
        if let uid = self.loggedInUser?.userId {
            let openChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/" + "\(uid)")
            openChannel.removeValue()
        }
    }
    
    //MARK:- Add to open channel
    
    func moveToOpenChannelAfterChat() {
        addLoggedInUserToOpenChannel()
        addThePlayingWithUserToOpenChannelAfterChat()
    }
    
    func moveToOpenChannelBeforeChat() {
        addLoggedInUserToOpenChannel()
        addThePlayingWithUserToOpenChannelBeforeChat()
    }
    
    func addLoggedInUserToOpenChannel() {
        if let uid = self.loggedInUser?.userId {
            let openChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/" + "\(uid)")
            openChannel.setValue([DataBaseConstants.name : self.loggedInUser?.name ?? "Unknown" , DataBaseConstants.gmail : self.loggedInUser?.emailId ?? ""])
        }
    }
    
    func addThePlayingWithUserToOpenChannelBeforeChat() {
        if let uid = self.tempPlayingWith?.userId {
            let openChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/" + "\(uid)")
            openChannel.setValue([DataBaseConstants.name : self.playingWith?.name ?? "Unknown" , DataBaseConstants.gmail : self.playingWith?.emailId ?? ""])
        }
    }
    
    func addThePlayingWithUserToOpenChannelAfterChat() {
        if let uid = self.playingWith?.userId {
            let openChannel = self.ref.child(DataBaseConstants.OnlineChannel + "/" + DataBaseConstants.OpenUsers + "/" + "\(uid)")
            openChannel.setValue([DataBaseConstants.name : self.playingWith?.name ?? "Unknown" , DataBaseConstants.gmail : self.playingWith?.emailId ?? ""])
        }
    }
}

