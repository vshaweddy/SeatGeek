//
//  NavigationController.swift
//  SeatGeek
//
//  Created by Vici Shaweddy on 3/2/21.
//

import UIKit

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .default
    }
}
