//
//  CategoryPickerViewController.swift
//  MyLocations
//
//  Created by Islam Abd El Hakim on 30/11/2021.
//

import UIKit

class CategoryPickerViewController: UITableViewController{
    
    var selectedCategoryName = "" // u will pass it from DetailViewController
    var selectedIndexpath = IndexPath()
    let categories = [
    "No Category",
    "Apple Store",
    "Bar",
    "Bookstore",
    "Club",
    "Grocery Store",
    "Historic Building",
    "House",
    "Icecream Vendor",
    "Landmark",
    "Park"]
    override func viewDidLoad() {
        super.viewDidLoad()
       
   //Find The selectedIndexPath
        for i in 0..<categories.count
        {
            if categories[i] == selectedCategoryName
            {
                selectedIndexpath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let categoryName = categories[indexPath.row]
       
        cell.textLabel?.text = categoryName
        if categoryName == selectedCategoryName
        {
            cell.accessoryType = .checkmark
        }else
        {
            cell.accessoryType = .none
        }
        
        let selection = UIView(frame: CGRect.zero)
        selection.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        cell.selectedBackgroundView = selection
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let newCell = tableView.cellForRow(at: indexPath)
        {
            newCell.accessoryType = .checkmark
        }
       if  let oldCell = tableView.cellForRow(at: selectedIndexpath)
        {
           oldCell.accessoryType = .none
        }
        selectedIndexpath = indexPath
        
    }
    /*MARK:- You need some kind of mechanism that is invoked when the unwind segue is
     triggered
   prepare(for:sender:), of course! This
    works for segues in both directions
     at which point you can fill in the selectedCategoryName based on the row
     that was tapped.*/
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickedCategory"
        {
            let cell = sender as! UITableViewCell
            if let indexpath=tableView.indexPath(for: cell)
            {
                selectedCategoryName=categories[indexpath.row]
            }
        }
    }
    
    

}
