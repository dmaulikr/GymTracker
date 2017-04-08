//
//  AppDelegate.swift
//  Gym Tracker
//
//  Created by Marco Boschi on 14/11/2016.
//  Copyright © 2016 Marco Boschi. All rights reserved.
//

import UIKit
import HealthKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, DataManagerDelegate {

	var window: UIWindow?
	weak var tabController: TabBarController!
	weak var workoutList: WorkoutListTableViewController!
	weak var currentWorkout: CurrentWorkoutViewController! {
		didSet {
			if currentWorkout != nil {
				DispatchQueue.main.async {
					for b in self.mirrorUpdates {
						b()
					}
					
					self.mirrorUpdates = []
				}
			}
		}
	}
	weak var settings: SettingsViewController!

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		dataManager.delegate = self
		
		do {
			let view = UIView.appearance()
			view.tintColor = #colorLiteral(red: 0.7568627451, green: 0.9215686275, blue: 0.2, alpha: 1)
			DestructiveButton.appearance().tintColor = .red
			
			let table = UITableView.appearance()
			table.backgroundColor = .black
			table.separatorColor = #colorLiteral(red: 0.2243117094, green: 0.2243117094, blue: 0.2243117094, alpha: 1)
			
			let cell = UITableViewCell.appearance()
			cell.backgroundColor = #colorLiteral(red: 0.0393620953, green: 0.0393620953, blue: 0.0393620953, alpha: 1)
			cell.selectionStyle = .gray
			
			let textColor = #colorLiteral(red: 0.9198423028, green: 0.9198423028, blue: 0.9198423028, alpha: 1)
			UILabel.appearance().textColor = textColor
			UILabel.appearance(whenContainedInInstancesOf: [UITableViewHeaderFooterView.self]).textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
			HeartLabel.appearance().textColor = #colorLiteral(red: 1, green: 0.1882352941, blue: 0, alpha: 1)
			
			let textField = UITextField.appearance()
			textField.textColor = textColor
			textField.keyboardAppearance = .dark
		}
		
		tabController = self.window!.rootViewController as! TabBarController
		tabController.delegate = tabController
//		tabController.tabBar.items![0].selectedImage =
//		tabController.tabBar.items![1].selectedImage =
		tabController.tabBar.items![2].selectedImage = #imageLiteral(resourceName: "Settings Active")
		
		return true
	}
	
	func authorizeHealthAccess() {
		healthStore.requestAuthorization(toShare: healthWriteData, read: healthReadData) { success, _ in
			if success {
				preferences.authorized = true
				preferences.authVersion = authRequired
			}
		}
	}
	
	func applicationShouldRequestHealthAuthorization(_ application: UIApplication) {
		healthStore.handleAuthorizationForExtension { success, _ in
			if success {
				preferences.authorized = true
				preferences.authVersion = authRequired
			}
		}
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
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	// MARK: - Data Manager Delegate
	
	func refreshData() {
		DispatchQueue.main.async {
			self.workoutList.refreshData()
		}
	}
	
	func enableEdit() {
		DispatchQueue.main.async {
			self.workoutList.enableEdit(true)
		}
	}
	
	func cancelAndDisableEdit() {
		DispatchQueue.main.async {
			self.workoutList.enableEdit(false)
		}
	}
	
	private var mirrorUpdates = [() -> Void]()
	
	func updateMirroredWorkout(withCurrentExercize exercize: Int, part: Int, andTime date: Date) {
		let block: () -> Void = {
			self.currentWorkout?.updateMirroredWorkout(withCurrentExercize: exercize, part: part, andTime: date)
		}
		
		if self.currentWorkout != nil {
			DispatchQueue.main.async(execute: block)
		} else {
			mirrorUpdates.append(block)
		}
	}
	
	func mirroredWorkoutHasEnded() {
		let block: () -> Void = {
			self.currentWorkout?.mirroredWorkoutHasEnded()
		}
		
		if self.currentWorkout != nil {
			DispatchQueue.main.async(execute: block)
		} else {
			mirrorUpdates.append(block)
		}
	}

}

