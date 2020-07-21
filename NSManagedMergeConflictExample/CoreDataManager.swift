//
//  CoreDataManager.swift
//  NSManagedMergeConflictExample
//
//  Created by Kevin Yu on 1/29/19.
//  Copyright © 2019 Kevin Yu. All rights reserved.
//

import Foundation
import CoreData

/// Adapter for interacting with Merge Policy options
enum MergePolicyAdapter: Int {
    case errorMergePolicyType = 0
    case mergeByPropertyObjectTrumpMergePolicyType
    case mergeByPropertyStoreTrumpMergePolicyType
    case overwriteMergePolicyType
    case rollbackMergePolicyType
}

final class CoreDataManager {
    var foo1: Foo!
    var foo2: Foo!
    var context1: NSManagedObjectContext
    var context2: NSManagedObjectContext
    var controlContext: NSManagedObjectContext  // control context, for main label
    
    init() {
        controlContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context1 = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context2 = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        controlContext.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        context1.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
        context2.persistentStoreCoordinator = self.persistentContainer.persistentStoreCoordinator
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "NSManagedMergeConflictExample")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /// onetime setup, gets initial values for UI
    func setup() -> (String, String, String) {
        let request = NSFetchRequest<Foo>(entityName: "Foo")
        var results = (try? controlContext.fetch(request)) ?? []
        if results.count == 0 {
            let newFoo = Foo(context: controlContext)
            newFoo.val = "Steve"
            controlContext.insert(newFoo)
            try? controlContext.save()
            results = try! controlContext.fetch(request)
        }
        let controlFoo = results.first!
        
        foo1 = try! context1.fetch(request).first!
        foo2 = try! context2.fetch(request).first!
        
        return (controlFoo.val!, foo1.val!, foo2.val!)
    }

    /// change merge policy for contexts
    func setMergePolicy(_ policy: MergePolicyAdapter) {
        var mergePolicy = NSMergePolicy(merge: .errorMergePolicyType)
        
        switch policy {
        case .errorMergePolicyType:
            break
        case .mergeByPropertyObjectTrumpMergePolicyType:
            mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        case .mergeByPropertyStoreTrumpMergePolicyType:
            mergePolicy = NSMergePolicy(merge: .mergeByPropertyStoreTrumpMergePolicyType)
        case .overwriteMergePolicyType:
            mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        case .rollbackMergePolicyType:
            mergePolicy = NSMergePolicy(merge: .rollbackMergePolicyType)
        }
        
        context1.mergePolicy = mergePolicy
        context2.mergePolicy = mergePolicy
    }
    
    func saveToContext1(_ str: String) {
        foo1.val = str
        context1.performAndWait {
            do {
                try context1.save()
            }
            catch {
                print("Context 1 Save Error:")
                print(error)
            }
        }
    }
    
    func saveToContext2(_ str: String) {
        foo2.val = str
        context2.performAndWait {
            do {
                try context2.save()
            }
            catch {
                print("Context 2 Save Error:")
                print(error)
            }
        }
        
    }
    
    /// updates UI, could only get proper update with performAndWait method
    /// was not responding otherwise, had to reset app to propogate changes
    func updateControl(_ completion: @escaping (String)->Void) {
        controlContext.performAndWait {
            do {
                let request = NSFetchRequest<Foo>(entityName: "Foo")
                let controlFoo = try controlContext.fetch(request).first!
                print("Returning: \(controlFoo.val!)")
                completion(controlFoo.val!)
            }
            catch {
                print(error)
                completion("Core Data Error")
            }
        }
    }
}
