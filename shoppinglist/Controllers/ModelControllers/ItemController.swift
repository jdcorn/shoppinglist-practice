//
//  ItemController.swift
//  shoppinglist
//
//  Created by Jon Corn on 1/16/20.
//  Copyright © 2020 jdcorn. All rights reserved.
//

import Foundation
import CoreData

class ItemController {
    
    // MARK: - Properties
    static let shared = ItemController()
    
    // MARK: - FetchedResultsController
    var fetchedResultsController: NSFetchedResultsController<Item>
    init() {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        let resultsController: NSFetchedResultsController<Item> = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataStack.context, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController = resultsController
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("There was an error performing the fetch: \(error.localizedDescription)")
        }
    }
    
    // MARK: - CRUD Functions
    func add(name: String) {
        _ = Item(name: name)
        saveToPersistence()
    }
    
    func delete(item: Item) {
        CoreDataStack.context.delete(item)
        saveToPersistence()
    }
    
    func toggle(item: Item) {
        item.isPurchased.toggle()
        saveToPersistence()
    }
    
    func saveToPersistence() {
        do {
            try CoreDataStack.context.save()
        } catch let error {
            print("error saving \(error.localizedDescription)")
        }
    }
}
