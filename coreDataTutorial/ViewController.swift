//
//  ViewController.swift
//  coreDataTutorial
//
//  Created by Justin Lazarski on 8/14/16.
//  Copyright © 2016 Justin Lazarski. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var nameTableView: UITableView!
    // You’ll be storing Person entities rather than just names, so you rename the Array that serves as the table view’s data model to people. It now holds instances of NSManagedObject rather than simple Swift strings.
    var people = [NSManagedObject]()
    // Fetching from Core Data
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        //1 As mentioned in the previous section, before you can do anything with Core Data, you need a managed object context. Fetching is no different! You pull up the application delegate and grab a reference to its managed object context.

        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let managedContext = appDelegate?.managedObjectContext
        //2 As the name suggests, NSFetchRequest is the class responsible for fetching from Core Data. Fetch requests are both powerful and flexible. You can use requests to fetch a set of objects that meet particular criteria (e.g., “give me all employees that live in Wisconsin and have been with the company at least three years”), individual values (e.g., “give me the longest name in the database”) and more.Fetch requests have several qualifiers that refine the set of results they return. For now, you should know that NSEntityDescription is one of these qualifiers (one that is required!).Setting a fetch request’s entity property, or alternatively initializing it with init(entityName:), fetches all objects of a particular entity. This is what you do here to fetch all Person entities.

        let fetchRequest = NSFetchRequest(entityName: "Person")
        //3 You hand the fetch request over to the managed object context to do the heavy lifting. executeFetchRequest() returns an array of managed objects that meets the criteria specified by the fetch request.

        do {
            let results = try managedContext?.executeFetchRequest(fetchRequest)
            
            people = results as! [NSManagedObject]
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "\"The List\""
        nameTableView.registerClass(UITableViewCell.self,
                                    forCellReuseIdentifier: "Cell")
    }
    
    @IBAction func addName(sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .Alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .Default,
                                       handler: { (action:UIAlertAction) -> Void in
                                        
                                        let textField = alert.textFields!.first
                                        self.saveName(textField!.text!)
                                        self.nameTableView.reloadData()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .Default) { (action: UIAlertAction) -> Void in
        }
        
        alert.addTextFieldWithConfigurationHandler {
            (textField: UITextField) -> Void in
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert,
                              animated: true,
                              completion: nil)
    }
    // MARK: UITableViewDataSource
    // Since you’re changing the table view’s model, you must also replace both data source methods you implemented earlier with the following to reflect these changes:
    func tableView(tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(tableView: UITableView,
                   cellForRowAtIndexPath
        indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell =
            tableView.dequeueReusableCellWithIdentifier("Cell")
        let person = people[indexPath.row]
        
        cell!.textLabel!.text = person.valueForKey("name") as? String
        
        return cell!
    }
    //THIS IS WHERE CORE DATA REALLY GOES DOWN
    func saveName(name: String) {
        //1: Before you can save or retrieve anything from your Core Data store, you first need to get your hands on an NSManagedObjectContext. You can think of a managed object context as an in-memory “scratchpad” for working with managed objects.Think of saving a new managed object to Core Data as a two-step process: first, you insert a new managed object into a managed object context; then, after you’re happy with your shiny new managed object, you “commit” the changes in your managed object context to save it to disk.Xcode has already generated a managed object context as part of the new project’s template – remember, this only happens if you check the Use Core Data checkbox at the beginning. This default managed object context lives as a property of the application delegate. To access it, you first get a reference to the app delegate.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        //2: You create a new managed object and insert it into the managed object context. You can do this in one step with NSManagedObject’s designated initializer: init(entity:insertIntoManagedObjectContext:).You may be wondering what an NSEntityDescription is all about. Recall that earlier, I called NSManagedObject a “shape-shifter” class because it can represent any entity. An entity description is the piece that links the entity definition from your data model with an instance of NSManagedObject at runtime.
        
        let entity = NSEntityDescription.entityForName("Person", inManagedObjectContext: managedContext)
        let person = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext)
        //3: With an NSManagedObject in hand, you set the name attribute using key-value coding. You have to spell the KVC key (“name” in this case) exactly as it appears on your data model, otherwise your app will crash at runtime.
        person.setValue(name, forKey: "name")
        //4: You commit your changes to person and save to disk by calling save on the managed object context. Note that save can throw an error, which is why you call it using the try keyword and within a do block.
        do {
            try managedContext.save()
            //5: You commit your changes to person and save to disk by calling save on the managed object context. Note that save can throw an error, which is why you call it using the try keyword and within a do block.
            people.append(person)
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

