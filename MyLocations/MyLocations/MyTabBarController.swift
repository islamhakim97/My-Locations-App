//
//  MyTabBarController.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 12/12/2021.
//

import UIKit
class MyTabBarController: UITabBarController {
override var preferredStatusBarStyle: UIStatusBarStyle {
return .lightContent
}
override var childForStatusBarStyle: UIViewController? {
return nil
}
}
