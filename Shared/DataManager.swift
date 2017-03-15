//
//  DataManager.swift
//  Gym Tracker
//
//  Created by Marco Boschi on 12/03/17.
//  Copyright © 2017 Marco Boschi. All rights reserved.
//

import CoreData
import MBLibrary

func == (l: CDRecordID, r: CDRecordID) -> Bool {
	return l.hashValue == r.hashValue
}

struct CDRecordID: Hashable {
	
	let type: String
	let id: String
	
	var hashValue: Int {
		return (type+id).hashValue
	}
	
	init(obj: DataObject) {
		type = obj.objectType
		id = obj.id
	}
	
//	private init?(type: String, id: String) {
//		self.type = type
//		self.id = id
//		
//		if type == "" || id == "" {
//			return nil
//		}
//	}
	
	func getObject() -> DataObject? {
		if let objType = NSClassFromString(type) as? DataObject.Type {
			return objType.loadWithID(id)
		}
		
		return nil
	}
	
}

class DataObject: NSManagedObject {
	
	class var objectType: String {
		get {
			return "DataObject"
		}
	}
	var objectType: String {
		get {
			return type(of: self).objectType
		}
	}
	
	@NSManaged fileprivate var id: String
	@NSManaged fileprivate var modified: Date?
	@NSManaged fileprivate var created: Date?
	
	fileprivate var isNew: Bool {
		precondition(modified != nil && created != nil, "\(objectType) not saved")
		
		return created! == modified!
	}
	
	var recordID: CDRecordID {
		get {
			return CDRecordID(obj: self)
		}
	}
	
	class func loadWithID(_ id: String) -> DataObject? {
		return nil
	}
	
}

// MARK: - Delegate Protocol

protocol DataManagerDelegate: class {
	
	func refreshData()
	
}

// MARK: - Data Manager

class DataManager: NSObject {
	
	weak var delegate: DataManagerDelegate?
	
	fileprivate private(set) var localData: CoreDataStack
//	fileprivate private(set) var watchInterface: WatchInterface
	
	// MARK: - Initialization
	
	private static var manager: DataManager?
	
	class func getManager(withDelegate delegate: DataManagerDelegate?) -> DataManager {
		DataManager.manager?.delegate = delegate
		
		return DataManager.manager ?? {
			let m = DataManager(delegate: delegate)
			DataManager.manager = m
			return m
		}()
	}
	
	class func activate(withDelegate delegate: DataManagerDelegate?) {
		let _ = getManager(withDelegate: delegate)
	}
	
	override private convenience init() {
		self.init(delegate: nil)
	}
	
	private init(delegate: DataManagerDelegate?) {
		localData = CoreDataStack.getStack()
//		ckInterface = CloudKitInterface.getInterface()
		
		super.init()
		
		self.delegate = delegate
		localData.dataManager = self
//		ckInterface.dataManager = self
		
		// Use for cleanup during development
//		preferences.addFromLocal = []
//		preferences.updateFromLocal = []
//		preferences.deleteFromLocal = []

		print("Data Manager initialized")
	}
	

	// MARK: - Interaction

	func executeFetchRequest<T: NSFetchRequestResult>(_ request: NSFetchRequest<T>) -> [T]? {
		var result: [T]? = nil
		localData.managedObjectContext.performAndWait {
			do {
				result = try self.localData.managedObjectContext.fetch(request)
			} catch {}
		}
		
		return result
	}
	
	func newWorkout() -> Workout {
		let context = localData.managedObjectContext
		var newW: Workout!
		context.performAndWait {
			let e = NSEntityDescription.entity(forEntityName: Workout.objectType, in: context)!
			newW = Workout(entity: e, insertInto: context)
		}

		newW.id = newW.objectID.uriRepresentation().path
		
		return newW
	}
	
	func newExercize(for workout: Workout) -> Exercize {
		let context = localData.managedObjectContext
		var newE: Exercize!
		context.performAndWait {
			let e = NSEntityDescription.entity(forEntityName: Exercize.objectType, in: context)!
			newE = Exercize(entity: e, insertInto: context)
		}
		
		newE.id = newE.objectID.uriRepresentation().path
		newE.order = Int32(workout.exercizes.count)
		newE.workout = workout
		
		return newE
	}
	
	func newSet(for exercize: Exercize) -> RepsSet {
		let context = localData.managedObjectContext
		var newS: RepsSet!
		context.performAndWait {
			let e = NSEntityDescription.entity(forEntityName: RepsSet.objectType, in: context)!
			newS = RepsSet(entity: e, insertInto: context)
		}
		
		newS.id = newS.objectID.uriRepresentation().path
		newS.order = Int32(exercize.sets.count)
		newS.exercize = exercize
		
		return newS
	}
	
//	
//	func newTask() -> Task {
//		let context = localData.managedObjectContext
//		var res: Task!
//		
//		context.performAndWait {
//			let e = NSEntityDescription.entity(forEntityName: Task.objectType, in: context)!
//			res = Task(entity: e, insertInto: context)
//		}
//		
//		return res
//	}
//	func createTaskWithName(_ name: String, forProject p: Project) -> Task? {
//		var name = name
//		name = name.trimmingCharacters(in: .whitespacesAndNewlines)
//		if name == "" {
//			return nil
//		}
//		
//		let context = localData.managedObjectContext
//		let task = newTask()
//		
//		task.id = task.objectID.uriRepresentation().path
//		task.created = Date().timeIntervalSince1970
//		
//		task.name = name
//		task.project = p
//		
//		do {
//			try context.save()
//			
//			if preferences.canUseiCloud {
//				preferences.localObjectsToBeAdded(task)
//				sync()
//			}
//			
//			return task
//		} catch {
//			return nil
//		}
//	}
//	
//	func newSession() -> Session {
//		let context = localData.managedObjectContext
//		var res: Session!
//		
//		context.performAndWait {
//			let e = NSEntityDescription.entity(forEntityName: Session.objectType, in: context)!
//			res = Session(entity: e, insertInto: context)
//		}
//		
//		return res
//	}
//	func createSessionStartingAt(_ start: TimeInterval, endingAt end: TimeInterval, forTask t: Task) -> Session? {
//		if t.project.getActiveTask() != t || end <= start {
//			return nil
//		}
//		
//		let context = localData.managedObjectContext
//		let sess = newSession()
//		
//		sess.id = sess.objectID.uriRepresentation().path
//		
//		sess.start = start
//		sess.end = end
//		
//		sess.task = t
//		
//		do {
//			try context.save()
//			
//			if preferences.canUseiCloud {
//				preferences.localObjectsToBeAdded(sess)
//				sync()
//			}
//			
//			return sess
//		} catch {
//			return nil
//		}
//	}
	
	func discardAllChanges() {
		localData.managedObjectContext.rollback()
	}
	
	func persistChangesForObjects(_ obj: DataObject...) -> Bool { return persistChangesForObjects(obj) }
	func persistChangesForObjects(_ obj: [DataObject]...) -> Bool {
		let data = obj.reduce([DataObject]()) { $0 + $1 }
		if data.count == 0 {
			return true
		}
		
		// TODO: set modified date to now and created date (if nil)
		
		do {
			try localData.managedObjectContext.save()
			
			// TODO: send saved data to watch interface
			
			return true
		} catch {
			return false
		}
	}
	
	func deleteObjects(_ obj: DataObject...) -> Bool { return deleteObjects(obj) }
	func deleteObjects(_ obj: [DataObject]...) -> Bool {
		let data = obj.reduce([DataObject]()) { $0 + $1 }
		if data.count == 0 {
			return true
		}
		
		let context = localData.managedObjectContext
		let removedIDs = data.map { (r) -> CDRecordID in
			let id = r.recordID
			context.delete(r)
			return id
		}
		
		do {
			try localData.managedObjectContext.save()
			
			// TODO: send removed data to watch interface
			
			return true
		} catch {
			return false
		}
	}

	// MARK: - Synchronization methods

	fileprivate func persistCounterPartChanges(_ changes: Any) -> Bool {
		return false
	}

}

// MARK: - Core Data Stack

private class CoreDataStack {
	
	let storeName = "GymTracker"
	
	weak var dataManager: DataManager!
	
	// MARK: - Initialization
	
	private static var stack: CoreDataStack?
	
	class func getStack() -> CoreDataStack {
		return CoreDataStack.stack ?? {
			let s = CoreDataStack()
			CoreDataStack.stack = s
			return s
		}()
	}
	
	private init() {
		print("Local store initialized")
	}
	
	// MARK: - Core Data objects
	
	lazy var managedObjectModel: NSManagedObjectModel = {
		// The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
		let modelURL = Bundle.main.url(forResource: self.storeName, withExtension: "momd")!
		return NSManagedObjectModel(contentsOf: modelURL)!
	}()
	
	lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
		// The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
		// Create the coordinator and store
		let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
		
		let failureReason = "There was an error creating or loading the application's saved data."
		let url = applicationDocumentsDirectory.appendingPathComponent("\(self.storeName).sqlite")
		let options: [AnyHashable : Any] = [
			NSMigratePersistentStoresAutomaticallyOption: true,
			NSInferMappingModelAutomaticallyOption: true
		]
		
		do {
			try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
		} catch {
			// Report any error we got.
			var dict = [String: Any]()
			dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
			dict[NSLocalizedFailureReasonErrorKey] = failureReason
			
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

}

//// MARK: - CloudKit Interface
//
//private class CloudKitInterface {
//	
//	weak var dataManager: DataManager!
//	
//	let container: CKContainer
//	let database: CKDatabase
//	
//	// MARK: - Initialization
//	
//	private static var interface: CloudKitInterface?
//	
//	class func getInterface() -> CloudKitInterface {
//		return CloudKitInterface.interface ?? {
//			let i = CloudKitInterface()
//			CloudKitInterface.interface = i
//			return i
//		}()
//	}
//	
//	private init() {
//		container = CKContainer(identifier: iCloudContainer)
//		database = container.privateCloudDatabase
//		
//		print("CloudKit interface initialized")
//	}
//	
//	enum CKInterfaceError: Error {
//		case localObjectRemoved
//		case remoteObjectRemoved
//		case genericError
//	}
//	
//	// MARK: - Interaction
//	
//	func retrieveRecordForObject(_ obj: DataObject, callback: @escaping (CKRecord?, CKInterfaceError?) -> Void) {
//		database.fetch(withRecordID: obj.remoteRecordID!) { (r, err) in
//			if let err = err as NSError? {
//				if err.code == CKError.Code.unknownItem.rawValue && err.localizedDescription.range(of: "not found") != nil {
//					callback(nil, .remoteObjectRemoved)
//				}
//			} else {
//				callback(r, nil)
//			}
//		}
//	}
//	func retrieveRecordForObject(_ obj: CDRecordID, callback: @escaping (CKRecord?, CKInterfaceError?) -> Void) {
//		let idFilter = NSPredicate(format: "id == %@", obj.id)
//		let query = CKQuery(recordType: obj.type, predicate: idFilter)
//		
//		database.perform(query, inZoneWith: nil) { (records, err) in
//			if let _ = err {
//				callback(nil, .genericError)
//			} else if let res = records?.first {
//				callback(res, nil)
//			} else {
//				callback(nil, .remoteObjectRemoved)
//			}
//		}
//	}
//	
//	///- returns: A `CKRecord` for the passed Core Data object with up-to-date information; if `create` is set to false `nil` will be returned if no record exists remotly.
//	func recordForObject(_ obj: DataObject, createNew create: Bool, callback: @escaping (CKRecord?, CKInterfaceError?) -> Void) {
//		let fillRecord = { (r: CKRecord) in
//			if let filledRecord = obj.setDataForCloud(r) {
//				callback(filledRecord, nil)
//			} else {
//				callback(nil, .genericError)
//			}
//		}
//		
//		if create {
//			let r = CKRecord(recordType: obj.objectType)
//			fillRecord(r)
//		} else {
//			retrieveRecordForObject(obj) { (r, err) in
//				if let r = r {
//					fillRecord(r)
//				} else {
//					callback(nil, err)
//				}
//			}
//		}
//	}
//	///- returns: A `CKRecord` for the passed Core Data Record ID with up-to-date information; if `create` is set to false `nil` will be returned if no record exists remotly.
//	func recordForObject(_ obj: CDRecordID, createNew create: Bool, callback: @escaping (CKRecord?, CKInterfaceError?) -> Void) {
//		if let obj = obj.getObject() {
//			recordForObject(obj, createNew: create, callback: callback)
//		} else {
//			callback(nil, .localObjectRemoved)
//		}
//	}
//	
//}