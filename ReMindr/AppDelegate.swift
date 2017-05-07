//
//  AppDelegate.swift
//  ReMindr
//
//  Created by Priyanka Gopakumar on 26/3/17.
//  Copyright © 2017 Priyanka Gopakumar. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Firebase
import UserNotifications
import UserNotificationsUI


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    struct GlobalVariables {
        static var patientID = "Unknown"
    }
    
    var window: UIWindow?
    let locationManager = CLLocationManager()
    var ref: FIRDatabaseReference?
    var badgeCount: Int = 0

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
        
        application.beginBackgroundTask(withName: "patientPressedPanicButton", expirationHandler: nil)
        
        UNUserNotificationCenter.current().delegate = self
        // Enable local notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            // Enable or disable featusres based on authorization.
            guard error == nil else {
                //Display Error.. Handle Error.. etc..
                return
            }
            
            if granted {
                //Do stuff here..
                
                //Register for RemoteNotifications. Your Remote Notifications can display alerts now :)
                application.registerForRemoteNotifications()
            }
            else {
                //Handle user denying permissions..
            }
        }
        
        let turquoiseColor = UIColor(red: 38/255, green: 50/255, blue: 72/255, alpha: 1)
        // Override point for customization after application launch.
        //let navBar: UIImage = UIImage(named: "turquoise back")!
        // UINavigationBar.appearance().backgroundColor = turquoiseColor
        //setBackgroundImage(navBar, forBarMetrics: .Default)
        //UINavigationBar.appearance().barTintColor = turquoiseColor
        
        
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.lightContent
        
        UINavigationBar.appearance().setBackgroundImage(UIImage(named: "darkbluetexturedbackground")!.resizableImage(withCapInsets: UIEdgeInsets.zero, resizingMode: .tile), for: .default)
        
        let navBarItemsColor = UIColor.white
        
        //let blueColourUsed = UIColor(red: 45/255, green: 86/255, blue: 105/255, alpha: 1)
        //let navBarItemsColor = UIColor(red: 254/255, green: 218/255, blue: 2/255, alpha: 1)
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: navBarItemsColor]
        UIBarButtonItem.appearance().tintColor = navBarItemsColor
        UINavigationBar.appearance().tintColor = navBarItemsColor
        
        UITabBar.appearance().barTintColor = turquoiseColor

        
        FIRApp.configure()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        ref = FIRDatabase.database().reference()
        patientLeftGeofencingArea()
        patientPressedPanicButton()
        return true
    }
    
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationTableViewController().tableView.reloadData()
    }
    


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }
    
    

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
       
       
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        readUUIDFromDataPList()
        application.applicationIconBadgeNumber = 0
        self.ref?.child("panicked/testpatient/isPanicked").setValue("false")
        readUUIDFromDataPList()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "ReMindr")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered!")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
            print("I have entered \(region.identifier)")
            
            // Notify the user when they have entered a region
            let title = "ReMindr"
            let message = "You have a memory attached to this location : \(region.identifier)."
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                //self.present(alertController, animated: true, completion: nil)
            } else {
                // App is inactive, show a notification
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = message
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(notification)
            }

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
            print("Exited region \(region.identifier)")
            // Notify the user when they have entered a region
            let title = "ReMindr"
            let message = "You are leaving a location with an attached memory : \(region.identifier)."
            
            if UIApplication.shared.applicationState == .active {
                // App is active, show an alert
                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                //self.present(alertController, animated: true, completion: nil)
            } else {
                // App is inactive, show a notification
                let notification = UILocalNotification()
                notification.alertTitle = title
                notification.alertBody = message
                notification.soundName = UILocalNotificationDefaultSoundName
                UIApplication.shared.presentLocalNotificationNow(notification)
                
                
            }

        }
    }
    
    func patientLeftGeofencingArea()
    {
        self.ref?.child("geofencing").observe(.value, with: { (snapshot) in
            
            if let current = snapshot.childSnapshot(forPath: "testpatient") as? FIRDataSnapshot
            {
                let value = current.value as? NSDictionary
                if let locationName = value?["locationName"] as? String {
                    if let isViolated = value?["violated"] as? String {
                        if (isViolated == "true")
                        {
                            let title = "Patient outside Safe Zone"
                            let message = "Patient has left region: \(locationName)"
                            
                            if UIApplication.shared.applicationState == .active {
                                // App is active, show an alert
                                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                
                                let takeToScreenAction = UIAlertAction(title: "Take me to the map", style: .default, handler: { (action: UIAlertAction!) in
                                    
                                    self.ref?.child("panicked/testpatient/isPanicked").setValue("false")
                                    
                                    //let mainNav = self.window?.rootViewController as! MainNavigationController
//                                    let mainNav = UIApplication.shared.windows[0].rootViewController as! MainNavigationController
//                                    let mainPage = mainNav.topViewController!
//                                    mainPage.performSegue(withIdentifier: "ShowGeofencingMapSegue", sender: self)
                     
//                                    let VC1 = self.storyboard!.instantiateViewControllerWithIdentifier("MyViewController") as! ViewController
//                                    let navController = UINavigationController(rootViewController: VC1) // Creating a navigation controller with VC1 at the root of the navigation stack.
//                                    self.presentViewController(navController, animated:true, completion: nil)
                                    
                                    
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let mainNav = storyBoard.instantiateViewController(withIdentifier: "GeofencingViewController") as! GeofencingViewController
                                    
                                    let navController = UINavigationController(rootViewController: mainNav)
                                    //let mapController = mainNav.topViewController?.shouldPerformSegue(withIdentifier: <#T##String#>, sender: <#T##Any?#>)
                                    //navController.navigationItem.backBarButtonItem? = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(self.backAction))
                                   
                                    //self.window?.rootViewController?.navigationController?.pushViewController(mainNav, animated: true)
                                    self.window?.rootViewController?.present(navController, animated: true, completion: nil)
//                                    // If you want to push to new ViewController then use this
//                                    self.navigationController?.pushViewController(objSomeViewController, animated: true)
//                                    
//                                    let nav = self.window?.rootViewController?.storyboard?.instantiateViewController(withIdentifier: "MainNavigationController") as! MainNavigationController
//                                    let mainPage = nav.topViewController!
//                                    mainPage.performSegue(withIdentifier: "ShowGeofencingMapSegue", sender: self)
                                })
                                
                                alertController.addAction(alertAction)
                                alertController.addAction(takeToScreenAction)

                                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                                //self.present(alertController, animated: true, completion: nil)
                            } else {
                                // App is inactive, show a notification
                                if #available(iOS 10.0, *) {
                                    self.generateLocalNotification()
                                }
                                else
                                 {
                                    let notification = UILocalNotification()
                                    notification.alertTitle = title
                                    notification.alertBody = message
                                    notification.soundName = UILocalNotificationDefaultSoundName
                                    UIApplication.shared.presentLocalNotificationNow(notification)

                                }
                            }
                            
                        }
                        else
                        {
                            let title = "Patient in Safe Zone"
                            let message = "Patient has returned to region: \(locationName)"
                            
                            if UIApplication.shared.applicationState == .active {
                                // App is active, show an alert
                                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                alertController.addAction(alertAction)
                                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                                //self.present(alertController, animated: true, completion: nil)
                            } else {
//                                // App is inactive, show a notification
                                if #available(iOS 10.0, *) {
                                    self.generateNotificationWithNoActions()
                                }
                                else
                                {
                                    let notification = UILocalNotification()
                                    notification.alertTitle = title
                                    notification.alertBody = message
                                    notification.soundName = UILocalNotificationDefaultSoundName
                                    UIApplication.shared.presentLocalNotificationNow(notification)
                                }
                            }

                        }
                    }
                }
            }
        })
    }
    
    func backAction()
    {
        self.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    func setupNotificationSettings() {

        // Specify the notification actions.
        let justInformAction = UIMutableUserNotificationAction()
        justInformAction.identifier = "justInform"
        justInformAction.title = "OK, got it"
        justInformAction.activationMode = UIUserNotificationActivationMode.background
        justInformAction.isDestructive = false
        justInformAction.isAuthenticationRequired = false
        
        var modifyListAction = UIMutableUserNotificationAction()
        modifyListAction.identifier = "editList"
        modifyListAction.title = "Edit list"
        modifyListAction.activationMode = UIUserNotificationActivationMode.foreground
        modifyListAction.isDestructive = false
        modifyListAction.isAuthenticationRequired = true
        
        var trashAction = UIMutableUserNotificationAction()
        trashAction.identifier = "trashAction"
        trashAction.title = "Delete list"
        trashAction.activationMode = UIUserNotificationActivationMode.background
        trashAction.isDestructive = true
        trashAction.isAuthenticationRequired = true
        
    }
    
    func generateLocalNotification() {
        
        badgeCount += 1
        
        // App is inactive, show a notification
        //let justInformAction = UNNotificationAction(identifier: "justInform", title: "Okay, got it", options: [.destructive, .authenticationRequired, .foreground])
        let justInformAction = UNNotificationAction(identifier: "justInform", title: "Okay, got it", options: [])
        let showPatientAction = UNNotificationAction(identifier: "showPatient", title: "Take me to the map", options: [.foreground, .destructive, .authenticationRequired] )
        //let callPatientAction = UNNotificationAction(identifier: "callPatient", title: "Call my patient", options: [.destructive, .foreground, .authenticationRequired] )
        
        let actionsArray = NSArray(objects: justInformAction, showPatientAction) //, callPatientAction)
        //let actionsArrayMinimal = NSArray(objects: showPatientAction, callPatientAction)
        
        let geofencingNotificationCategory = UNNotificationCategory(identifier: "geofencingNotificationCategory", actions: actionsArray as! [UNNotificationAction], intentIdentifiers: [], options: [])
        
        let content = UNMutableNotificationContent()
        content.title = "Patient has left safe zone"
        content.body = "Your patient has wandered away from the safe zone"
        content.sound = UNNotificationSound.default()
        content.badge = badgeCount as NSNumber
        content.categoryIdentifier = "geofencingNotificationCategory"
        content.launchImageName = "home"
        
        guard let path = Bundle.main.path(forResource: "patientLeftIcon", ofType: "png") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "notificationImage", url: url, options: nil)
            content.attachments = [attachment]
        }
        catch
        {
            print ("An error occurred while trying to attach an image to the notification")
        }
        
//        
//        //let imagePath = URL(fileReferenceLiteralResourceName: "home")
//        let imagePath = URL(string: "https://firebasestorage.googleapis.com/v0/b/remindr-be120.appspot.com/o/pizza.jpg?alt=media&token=e5831bb2-eec7-4b1f-bdef-3f975cf0e7b5")
//        if let attachment =  try? UNNotificationAttachment(identifier: "notificationImage", url: imagePath!, options: nil) {
//            content.attachments.append(attachment)
//        }
//        
    
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest.init(identifier: "geofenceNotification", content: content, trigger: trigger)
        
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([geofencingNotificationCategory])
        center.removeAllPendingNotificationRequests()
        
        center.add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        })

    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
        
        switch response.actionIdentifier {
            case "justInform":
                print ("cancelled")
            
            case "informContacts":
                print ("call function to SMS emergency contacts")
                badgeCount = 0
                let mainNav = self.window?.rootViewController as! UINavigationController
                let mainPage = mainNav.topViewController!
                let sb = UIStoryboard(name: "Main", bundle: nil)
                mainPage.performSegue(withIdentifier: "ShowPanicMapSegue", sender: self)
            
//                let otherVC = sb.instantiateViewController(withIdentifier: "PanicMapViewController") as! PanicMapViewController
//                window?.rootViewController = otherVC;
            
            case "showPatient":
                print ("must show patient here")
                badgeCount = 0
                let mainNav = self.window?.rootViewController as! UINavigationController
                let mainPage = mainNav.topViewController!
                let sb = UIStoryboard(name: "Main", bundle: nil)
                mainPage.performSegue(withIdentifier: "ShowGeofencingMapSegue", sender: self)

            default:
                print ("default action")
        }
        completionHandler()
    }
    
    func generateNotificationWithNoActions()
    {
        badgeCount += 1
        // App is inactive, show a notification
        let content = UNMutableNotificationContent()
        content.title = "Patient has returned to safe zone"
        content.body = "Your patient is back inside the safe zone"
        content.sound = UNNotificationSound.default()
        content.badge = badgeCount as NSNumber
        content.launchImageName = "home"
        
        guard let path = Bundle.main.path(forResource: "patientBackIcon", ofType: "png") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "notificationImage", url: url, options: nil)
            content.attachments = [attachment]
        }
        catch
        {
            print ("An error occurred while trying to attach an image to the notification")
        }
        
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest.init(identifier: "OtherNotification", content: content, trigger: trigger)
        
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
        
        center.add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        })

    }
    
    func patientPressedPanicButton()
    {
        
        self.ref?.child("panicked").observe(.value, with: { (snapshot) in
            
            print("Changed happen")
            if let current = snapshot.childSnapshot(forPath: "testpatient") as? FIRDataSnapshot
            {
                let value = current.value as? NSDictionary
                if let isPanicked = value?["isPanicked"] as? String {
                    if (isPanicked == "true")
                    {
                            let title = "Patient needs help"
                            let message = "Your patient has pressed the panic button and requires your help"
                            
                            if UIApplication.shared.applicationState == .active {
                                // App is active, show an alert
                                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
                                
                                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                let takeToScreenAction = UIAlertAction(title: "Take me to the map", style: .default, handler: { (action: UIAlertAction!) in
                                    
                                    self.ref?.child("panicked/testpatient/isPanicked").setValue("false")
//                                    let mainNav = self.window?.rootViewController as! UINavigationController
//                                    let mainPage = mainNav.topViewController!
//                                    mainPage.performSegue(withIdentifier: "ShowPanicMapSegue", sender: self)
                                    
                                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                                    let mainNav = storyBoard.instantiateViewController(withIdentifier: "PanicMapViewController") as! PanicMapViewController
                                    
                                    let navController = UINavigationController(rootViewController: mainNav)
                                    self.window?.rootViewController?.present(navController, animated: true, completion: nil)
                                })
                                
                                alertController.addAction(alertAction)
                                alertController.addAction(takeToScreenAction)
                                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                                //self.present(alertController, animated: true, completion: nil)
                            } else {
                                // App is inactive, show a notification
                                
                                let center = UNUserNotificationCenter.current()
                                center.removeAllDeliveredNotifications() // To remove all delivered notifications
                                center.removeAllPendingNotificationRequests()
                                
                                if #available(iOS 10.0, *) {
                                    self.generatePanicLocalNotification()
                                }
                                else
                                {
                                    let notification = UILocalNotification()
                                    notification.alertTitle = title
                                    notification.alertBody = message
                                    notification.soundName = UILocalNotificationDefaultSoundName
                                    UIApplication.shared.presentLocalNotificationNow(notification)
                                    
                                }
                            }
                    }
                }
            }
        })
    }
    
    
    func generatePanicLocalNotification() {
        
        badgeCount += 1
        
        // App is inactive, show a notification
        //let justInformAction = UNNotificationAction(identifier: "justInform", title: "Okay, got it", options: [.destructive, .authenticationRequired, .foreground])
        let justInformAction = UNNotificationAction(identifier: "justInform", title: "Okay, got it", options: [])
        let informContacts = UNNotificationAction(identifier: "informContacts", title: "Inform Emergency Contacts", options: [.foreground, .destructive])
//        let showPatientAction = UNNotificationAction(identifier: "showPatient", title: "Take me to the app", options: [.foreground, .destructive, .authenticationRequired] )
        //let callPatientAction = UNNotificationAction(identifier: "callPatient", title: "Call my patient", options: [.destructive, .foreground, .authenticationRequired] )
        
        let actionsArray = NSArray(objects: justInformAction, informContacts)//, showPatientAction) //, callPatientAction)
        //let actionsArrayMinimal = NSArray(objects: showPatientAction, callPatientAction)
        
        let geofencingNotificationCategory = UNNotificationCategory(identifier: "panicNotificationCategory", actions: actionsArray as! [UNNotificationAction], intentIdentifiers: [], options: [])
        
        let content = UNMutableNotificationContent()
        
        content.title = "Patient needs help"
        content.body = "Your patient has pressed the panic button and requires your help"
        content.sound = UNNotificationSound.default()
        content.badge = badgeCount as NSNumber
        content.categoryIdentifier = "panicNotificationCategory"
        content.launchImageName = "home"
        content.userInfo = ["Type": "PanicNotification"]
        
        guard let path = Bundle.main.path(forResource: "redalert", ofType: "png") else { return }
        let url = URL(fileURLWithPath: path)
        
        do {
            let attachment = try UNNotificationAttachment(identifier: "notificationImage", url: url, options: nil)
            content.attachments = [attachment]
        }
        catch
        {
            print ("An error occurred while trying to attach an image to the notification")
        }
        
        //
        //        //let imagePath = URL(fileReferenceLiteralResourceName: "home")
        //        let imagePath = URL(string: "https://firebasestorage.googleapis.com/v0/b/remindr-be120.appspot.com/o/pizza.jpg?alt=media&token=e5831bb2-eec7-4b1f-bdef-3f975cf0e7b5")
        //        if let attachment =  try? UNNotificationAttachment(identifier: "notificationImage", url: imagePath!, options: nil) {
        //            content.attachments.append(attachment)
        //        }
        //
        
        // Deliver the notification in five seconds.
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        let request = UNNotificationRequest.init(identifier: "panicNotification", content: content, trigger: trigger)
        
        
        // Schedule the notification.
        let center = UNUserNotificationCenter.current()
        center.setNotificationCategories([geofencingNotificationCategory])
        center.removeAllPendingNotificationRequests()
        
        center.add(request, withCompletionHandler: {(error) in
            if let error = error {
                print("Uh oh! We had an error: \(error)")
            }
        })
        
    }
    
    func readUUIDFromDataPList()
    {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let path = paths.appending("/data.plist")
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path)))
        {
            let bundle: NSString = Bundle.main.path(forResource: "data", ofType: "plist")! as NSString
            do{
                try fileManager.copyItem(atPath: bundle as String, toPath: path)
            }catch{
                print("copy failure.")
            }
        }
        let plistData : NSMutableDictionary = NSMutableDictionary(contentsOfFile: path)!
            
        let patientDeviceUUID: String = plistData["patientDeviceUUID"] as! String
        print("Device UUID read from data.plist is \(plistData["patientDeviceUUID"] as! String)")
        
        GlobalVariables.patientID = patientDeviceUUID
        if (patientDeviceUUID == "Unknown")
        {
            let alertController = UIAlertController(title: "Device not linked", message: "Please go to settings and scan the QR code to link your device", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
            if shortcutItem.type == "search"
            {

                let rootNavigationViewController = window!.rootViewController as? MainNavigationController
                let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
                
//                
//                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
//                let vc = storyBoard.instantiateViewController(withIdentifier: "GeofencingViewController") as! GeofencingViewController
//                
//                
//                rootNavigationViewController?.pushViewController(vc, animated: true)
                rootNavigationViewController?.popToRootViewController(animated: false)
                rootViewController?.performSegue(withIdentifier: "ShowPanicMapSegue", sender: nil)
            }
            if shortcutItem.type == "reminder"
        {
            
            let rootNavigationViewController = window!.rootViewController as? MainNavigationController
            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            
            //
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let vc = storyBoard.instantiateViewController(withIdentifier: "GeofencingViewController") as! GeofencingViewController
            //
            //
            //                rootNavigationViewController?.pushViewController(vc, animated: true)
            rootNavigationViewController?.popToRootViewController(animated: false)
            rootViewController?.performSegue(withIdentifier: "toReminderList", sender: nil)
        }
        if shortcutItem.type == "photo"
        {
            
            let rootNavigationViewController = window!.rootViewController as? MainNavigationController
            let rootViewController = rootNavigationViewController?.viewControllers.first as UIViewController?
            
            //
            //                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //                let vc = storyBoard.instantiateViewController(withIdentifier: "GeofencingViewController") as! GeofencingViewController
            //
            //
            //                rootNavigationViewController?.pushViewController(vc, animated: true)
            rootNavigationViewController?.popToRootViewController(animated: false)
            rootViewController?.performSegue(withIdentifier: "showPhotos", sender: nil)
        }
        
            
    }
}

