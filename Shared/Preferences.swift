//
//  Preferences.swift
//  WorkTime
//
//  Created by Marco Boschi on 30/06/15.
//  Copyright (c) 2015 Marco Boschi. All rights reserved.
//

import Foundation
import MBLibrary

enum PreferenceKeys: String, KeyValueStoreKey {
	var description: String {
		return rawValue
	}
	
	case firstLaunchDone = "firstLaunchDone"
	case initialSyncDone = "initialSync"
	
	case transferLocal = "transferLocal"
	case deleteLocal = "deleteLocal"
	case saveRemote = "saveRemote"
	case deleteRemote = "deleteRemote"
	
	case runningWorkout = "runningWorkout"
	case runningWorkoutSource = "runningWorkoutSource"
	case runningWorkoutNeedsTransfer = "runningWorkoutNeedsTransfer"
	case currentStart = "currentStart"
	case currentExercize = "currentExercize"
	case currentPart = "currentPart"
	case currentRestEnd = "currentRestEnd"
	
	case authorized = "authorized"
	case authVersion = "authVersion"
	
	case useBackups = "useBackups"
	case lastBackup = "lastBackup"
	
}

enum RunningWorkoutSource: String {
	
	case watch = "watch"
	case phone = "phone"
	
	func isCurrentPlatform() -> Bool {
		switch self {
		case .watch:
			return iswatchOS
		case .phone:
			return isiOS
		}
	}
	
}

class Preferences {
	
	// MARK: - Initialization
	
	private static var pref: Preferences?
	
	private var local: KeyValueStore
	
	class func getPreferences() -> Preferences {
		return Preferences.pref ?? {
			let p = Preferences()
			Preferences.pref = p
			return p
		}()
	}
	
	class func activate() {
		let _ = getPreferences()
	}
	
	private init() {
		local = KeyValueStore(userDefaults: UserDefaults.standard)
		
		print("Preferences initialized")
	}
	
	// MARK: - Data
	
	var firstLaunchDone: Bool {
		get {
			return local.bool(forKey: PreferenceKeys.firstLaunchDone)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.firstLaunchDone)
			local.synchronize()
		}
	}
	
	var initialSyncDone: Bool {
		get {
			return local.bool(forKey: PreferenceKeys.initialSyncDone)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.initialSyncDone)
			local.synchronize()
		}
	}
	
	// MARK: - Local data not yet sent
	
	var transferLocal: [CDRecordID] {
		get {
			return CDRecordID.decodeArray(local.array(forKey: PreferenceKeys.transferLocal) as? [[String]] ?? [])
		}
		set {
			let key = PreferenceKeys.transferLocal
			if newValue.count > 0 {
				local.set(CDRecordID.encodeArray(newValue), forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	var deleteLocal: [CDRecordID] {
		get {
			return CDRecordID.decodeArray(local.array(forKey: PreferenceKeys.deleteLocal) as? [[String]] ?? [])
		}
		set {
			let key = PreferenceKeys.deleteLocal
			if newValue.count > 0 {
				local.set(CDRecordID.encodeArray(newValue), forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	// MARK: - Updates not persisted yet
	
	var saveRemote: [WCObject] {
		get {
			return WCObject.decodeArray(local.array(forKey: PreferenceKeys.saveRemote) as? [[String: Any]] ?? [])
		}
		set {
			let key = PreferenceKeys.saveRemote
			if newValue.count > 0 {
				local.set(WCObject.encodeArray(newValue), forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	var deleteRemote: [CDRecordID] {
		get {
			return CDRecordID.decodeArray(local.array(forKey: PreferenceKeys.deleteRemote) as? [[String]] ?? [])
		}
		set {
			let key = PreferenceKeys.deleteRemote
			if newValue.count > 0 {
				local.set(CDRecordID.encodeArray(newValue), forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	// MARK: - Running Workout data
	
	var runningWorkout: CDRecordID? {
		get {
			return CDRecordID(wcRepresentation: local.array(forKey: PreferenceKeys.runningWorkout) as? [String] ?? [])
		}
		set {
			let key = PreferenceKeys.runningWorkout
			if let data = newValue?.wcRepresentation {
				local.set(data, forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	var runningWorkoutSource: RunningWorkoutSource? {
		get {
			return RunningWorkoutSource(rawValue: local.string(forKey: PreferenceKeys.runningWorkoutSource) ?? "")
		}
		set {
			let key = PreferenceKeys.runningWorkoutSource
			if let data = newValue?.rawValue {
				local.set(data, forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	var runningWorkoutNeedsTransfer: Bool {
		get {
			return local.bool(forKey: PreferenceKeys.runningWorkoutNeedsTransfer)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.runningWorkoutNeedsTransfer)
			local.synchronize()
		}
	}
	
	var currentStart: Date {
		get {
			return local.object(forKey: PreferenceKeys.currentStart) as? Date ?? Date()
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.currentStart)
			local.synchronize()
		}
	}
	
	var currentExercize: Int {
		get {
			return local.integer(forKey: PreferenceKeys.currentExercize)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.currentExercize)
			local.synchronize()
		}
	}
	
	var currentPart: Int {
		get {
			return local.integer(forKey: PreferenceKeys.currentPart)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.currentPart)
			local.synchronize()
		}
	}
	
	var currentRestEnd: Date? {
		get {
			return local.object(forKey: PreferenceKeys.currentRestEnd) as? Date
		}
		set {
			let key = PreferenceKeys.currentRestEnd
			if let val = newValue {
				local.set(val, forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
	// MARK: - Health Access
	
	var authorized: Bool {
		get {
			return local.bool(forKey: PreferenceKeys.authorized)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.authorized)
			local.synchronize()
		}
	}
	
	var authVersion: Int {
		get {
			return local.integer(forKey: PreferenceKeys.authVersion)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.authVersion)
			local.synchronize()
		}
	}
	
	// MARK: - Backups
	
	var useBackups: Bool {
		get {
			return local.bool(forKey: PreferenceKeys.useBackups)
		}
		set {
			local.set(newValue, forKey: PreferenceKeys.useBackups)
			local.synchronize()
		}
	}
	
	var lastBackup: Date? {
		get {
			return local.object(forKey: PreferenceKeys.lastBackup) as? Date
		}
		set {
			let key = PreferenceKeys.lastBackup
			if let val = newValue {
				local.set(val, forKey: key)
			} else {
				local.removeObject(forKey: key)
			}
			local.synchronize()
		}
	}
	
}
