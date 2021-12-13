//
//  SceneDelegate.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 26/11/2021.
//

import UIKit
import CoreData
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    // Load Data Model and Connect it to SQlite data store
    lazy var persistentContainer: NSPersistentContainer = {
               let container = NSPersistentContainer(name: "DataModel")
               container.loadPersistentStores { (storeDescription, error)
               in
                    if let error = error {
                                   fatalError("Could not load data store: \(error)")
                                        }
            }
                  return container
            }()
    lazy var managedObjectContext: NSManagedObjectContext = persistentContainer.viewContext
// passing the managedObjectContext to currentLocationVC
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        customizeAppearance()
            let tabController = window!.rootViewController as! UITabBarController
        
          if let tabViewControllers = tabController.viewControllers {
              // First tab
              var navController = tabViewControllers[0]
              as! UINavigationController
              let controller1 = navController.viewControllers.first
              as! CurrentLocationViewController
              controller1.managedObjectContext = managedObjectContext
              // Second tab
              navController = tabViewControllers[1]
              as! UINavigationController
              let controller2 = navController.viewControllers.first
              as! LocationsViewController
              controller2.managedObjectContext = managedObjectContext
              // Third tab
              navController = tabViewControllers[2] as! UINavigationController
              let controller3 = navController.viewControllers.first
              as! MapViewController
              controller3.managedObjectContext = managedObjectContext
              }
        //that the notification handler is registered with NotificationCenter
        listenForFatalCoreDataNotifications()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print(applicationDocumentsDirectory)
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    // MARK:- Helper methods
    func listenForFatalCoreDataNotifications() {
    // 1
             NotificationCenter.default.addObserver(forName: CoreDataSaveFailedNotification,object: nil, queue: OperationQueue.main,using: { notification in
    // 2
    let message = """
    There was a fatal error in the app and it cannot continue.
    Press OK to terminate the app. Sorry for the inconvenience.
    """
    // 3
    let alert = UIAlertController(title: "Internal Error", message: message,preferredStyle: .alert)
    // 4
    let action = UIAlertAction(title: "OK",style: .default) { _ in
    let exception = NSException(name: NSExceptionName.internalInconsistencyException,reason: "Fatal Core Data error", userInfo: nil)
    exception.raise()
    }
        alert.addAction(action)
        // 5
        let tabController = self.window!.rootViewController!
        tabController.present(alert, animated: true,
        completion: nil)
        })
        }
func customizeAppearance() {
    UINavigationBar.appearance().barTintColor = UIColor.black
    UINavigationBar.appearance().titleTextAttributes = [
    NSAttributedString.Key.foregroundColor:
    UIColor.white ]
    UITabBar.appearance().barTintColor = UIColor.black
    let tintColor = UIColor(red: 255/255.0, green: 238/255.0,
    blue: 136/255.0, alpha: 1.0)
    UITabBar.appearance().tintColor = tintColor
    }


}

