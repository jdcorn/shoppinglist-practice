//
//  ShoppingListTableViewController.swift
//  shoppinglist
//
//  Created by Jon Corn on 1/17/20.
//  Copyright © 2020 jdcorn. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController {

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        ItemController.shared.fetchedResultsController.delegate = self
    }
    
    // MARK: - Actions
    @IBAction func addButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add item", message: "Please add an item to your shopping list", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        // Create cancel button
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        // Create add button
        let addButton = UIAlertAction(title: "Add", style: .default) { (_) in
            guard let itemName = alert.textFields?[0].text, itemName != "" else { return }
            ItemController.shared.add(name: itemName)
        }
        // adding them to alertcontroller
        alert.addAction(cancelButton)
        alert.addAction(addButton)
        self.present(alert, animated: true)
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ItemController.shared.fetchedResultsController.fetchedObjects?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else { return UITableViewCell() }
        
        let item = ItemController.shared.fetchedResultsController.object(at: indexPath)
        cell.updateViews(item: item)
        cell.delegate = self
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let item = ItemController.shared.fetchedResultsController.fetchedObjects?[indexPath.row]
                else { return }
            ItemController.shared.delete(item: item)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension ShoppingListTableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        let indexSet = IndexSet(integer: sectionIndex)
        
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .fade)
        case .delete:
            tableView.deleteSections(indexSet, with: .fade)
            
        default: return
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath
                else { return }
            tableView.insertRows(at: [newIndexPath], with: .fade)
        case .delete:
            guard let indexPath = indexPath
                else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .update:
            guard let indexPath = indexPath
                else { return }
            tableView.reloadRows(at: [indexPath], with: .none)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath
                else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        @unknown default:
            fatalError("NSFetchedResultsChangeType has new unhandled cases")
        }
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension ShoppingListTableViewController: ItemTableViewCellDelegate {
    func isPurchasedToggled(_ sender: ItemTableViewCell) {
        guard let indexPath = tableView.indexPath(for: sender) else { return }
        let item = ItemController.shared.fetchedResultsController.object(at: indexPath)
        ItemController.shared.toggle(item: item)
        sender.updateViews(item: item)
    }
}

