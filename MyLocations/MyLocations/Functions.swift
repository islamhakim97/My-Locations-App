//
//  Functions.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 30/11/2021.
//

import Foundation
// pass a closure in a function as ()->void || ()->() ||@escaping () -> Void)

let applicationDocumentsDirectory: URL = {
          let paths = FileManager.default.urls(for: .documentDirectory,
                        in: .userDomainMask)
          return paths[0]
        }()

//Alerting the user about crashes
let CoreDataSaveFailedNotification = Notification.Name("CoreDataSaveFailedNotification")
//a new global function for handling fatal Core Data errors.
func fatalCoreDataError(_ error: Error) {
            print("*** Fatal error: \(error)")
   NotificationCenter.default.post(name: CoreDataSaveFailedNotification, object: nil)
}
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds,
    execute: run)
    }

