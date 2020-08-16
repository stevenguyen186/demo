//
//  TimesheetViewController.swift
//  VPBank
//
//  Created by Van Nguyen on 8/14/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import UIKit

class TimesheetViewController: UIViewController {
    // IBOutlet
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Constants
    private let timesheetCVCIdentifier = "TimesheetCollectionViewCell"
    private let timespanCVCIdentifier = "TimespanCollectionViewCell"
    private let employeeCVCIdentifier = "EmployeeCollectionViewCell"
    
    // datasource for CollectionView
    var data: [Any] = []
    
    // Layout for CollectionView
    let customLayout = CustomLayout()
    
    // Date Formatter
    let dateFormatter = DateFormatter()
    
    // Clone of Employees from DB
    var allEmployees: [MEmployee] = Array(Session.shared.employees.keys).map{Session.shared.employees[$0]!}.sorted { (employee1, employee2) -> Bool in
        return employee1.id < employee2.id
    }
    
    // Clone of Tasks from DB
    var allTasks: [MTask] = Array(Session.shared.tasks.keys).map{Session.shared.tasks[$0]!}
    
    // Total Tasks counter
    var totalTasks: [Int] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup CollectionView
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
        collectionView.dragInteractionEnabled = true
        
        // Setup CollectionViewLayout
        customLayout.delegate = self
        collectionView.collectionViewLayout = customLayout
        
        // Screen Title
        self.title = "Timesheet"
        
        // DateFormatter Config
        dateFormatter.dateFormat = "HH:mm"
        
        // ProcessData
        processData()
    }
}

// MARK: Util functions
extension TimesheetViewController {
    func processData() {
        // Add timeslot to data source || First Column
        self.data = []
        self.totalTasks = [0]
        self.data.append(Session.shared.timeslots)
        
        // Calculate Timeslots
        for employee in allEmployees {
            // Calculate Timeslots for each employee
            let tasksOfEmployee = allTasks.filter{ element in
                return element.assignedId == employee.id
            }
            // Generate timeslots from tasklist
            self.data.append(generateTimeslots(tasks: tasksOfEmployee))
            // Update tasks counter
            self.totalTasks.append(tasksOfEmployee.count)
        }
    }
    
    func generateTimeslots(tasks: [MTask]) -> [MTimeslot] {
        // All timeslots for the CollectionView
        var timeslots: [MTimeslot] = []
        
        // Config bounds of a timeslot
        let currentDateTime = Date()
        let startTime = Calendar.current.date(bySettingHour: START_WORKING_TIME, minute: 0, second: 0, of: currentDateTime)!
        let endTime = Calendar.current.date(bySettingHour: END_WORKING_TIME, minute: 0, second: 0, of: currentDateTime)!
        
        // Generate timeslot one by one (From start)
        var currentTimeslot: Date = startTime
        while currentTimeslot < endTime {
            let nextTimeslot = currentTimeslot.addingTimeInterval(TimeInterval(TIMESPAN))
            if (tasks.count == 0) {
                // There's no task -> add empty timeslot
                timeslots.append(MTimeslot(timeFrom: currentTimeslot, timeTo: nextTimeslot, task: nil))
                currentTimeslot = nextTimeslot
            } else {
                // This employee has task, check time overlap
                var foundTask: MTask? = nil
                for task in tasks {
                    if (currentTimeslot == task.timeFrom) {
                        foundTask = task
                    }
                }
                if ((foundTask) != nil) {
                    // Has Task on that timeslot
                    let timeslot = MTimeslot(timeFrom: currentTimeslot, timeTo: foundTask!.timeTo, task: foundTask)
                    timeslots.append(timeslot)
                    currentTimeslot = foundTask!.timeTo
                } else {
                    // No task on that timeslot
                    timeslots.append(MTimeslot(timeFrom: currentTimeslot, timeTo: nextTimeslot, task: nil))
                    currentTimeslot = nextTimeslot
                }
            }
        }
        //        print("========TIMESLOTS=======")
        //        print(timeslots)
        return timeslots
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: UICollectionViewDataSource
extension TimesheetViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let sectionArray = data[section] as? [Any] {
            return sectionArray.count + 1   // Should have one more row for the Column name
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if (indexPath.section == 0) {
            // Timeline
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: timespanCVCIdentifier, for: indexPath) as! TimespanCollectionViewCell
            if let sectionData = data[indexPath.section] as? [Date] {
                cell.updateTimelineForRow(text: indexPath.row > 0 ? dateFormatter.string(from: sectionData[indexPath.row - 1]) : "", forRow: indexPath.row)
            }
            return cell
        } else if (indexPath.row == 0) {
            // Employee name
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: employeeCVCIdentifier, for: indexPath) as! EmployeeCollectionViewCell
            let employee = allEmployees[indexPath.section - 1]
            cell.updateEmployee(name: employee.name, color: employee.color, taskCount: totalTasks[indexPath.section])
            return cell
        } else {
            // Taskcell
            let cell = collectionView
                .dequeueReusableCell(withReuseIdentifier: timesheetCVCIdentifier, for: indexPath) as! TimesheetCollectionViewCell
            let employee = allEmployees[indexPath.section - 1]
            if let sectionData = data[indexPath.section] as? [MTimeslot] {
                cell.updateTask(task: sectionData[indexPath.row - 1].task, color: employee.color)
            }
            return cell
        }
    }
}

// MARK: UICollectionViewDragDelegate
extension TimesheetViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        // Don't allow drag Timeline or Employee name
        if (indexPath.section == 0 || indexPath.row == 0) {
            return []
        }
        
        // get data item -> return drag item
        if let sectionData = data[indexPath.section] as? [MTimeslot] {
            let timeslot = sectionData[indexPath.row - 1]
            if let task = timeslot.task {
                let itemProvider = NSItemProvider(object: "\(task.id)" as NSString)
                let dragItem = UIDragItem(itemProvider: itemProvider)
                dragItem.localObject = timeslot
                return [dragItem]
            }
        }
        
        return []
    }
}

// MARK: UICollectionViewDropDelegate
extension TimesheetViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool
    {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        // Check destination indexpath
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }
        
        // Check drag item
        guard coordinator.items.count > 0 else {
            return
        }
        
        let currentItem = coordinator.items[0]
        
        // Check source indexpath
        guard let sourceIndexPath = currentItem.sourceIndexPath else {
            return
        }
        
        switch coordinator.proposal.operation
        {
        case .move:
            let itemProvider = currentItem.dragItem.itemProvider
            itemProvider.loadObject(ofClass: NSString.self) { string, error in
                if let _ = string as? String {
                    // Same employee -> change time
                    if (destinationIndexPath.section == sourceIndexPath.section) {
                        print("Moving in the same section")
                        // Get current section
                        guard let sourceDestSection = self.data[sourceIndexPath.section] as? [MTimeslot] else {
                            return
                        }
                        // Source timeslot
                        let sourceItem = sourceDestSection[sourceIndexPath.row - 1]
                        // Destination timeslot
                        let destItem = sourceDestSection[destinationIndexPath.row - 1]
                        let taskDuration = sourceItem.timeTo.timeIntervalSince(sourceItem.timeFrom)
                        let newEndTime = destItem.timeFrom.addingTimeInterval(taskDuration)
                        let tomorrowDate = Date().addingTimeInterval(86400)
                        let endOfToday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrowDate)!
                        
                        // Make sure task endTime < end of day
                        guard newEndTime < endOfToday  else {
                            self.showAlert(message: "Task must be finished in the same day")
                            return
                        }
                        // Check if drag/drop correct item
                        guard var localObject = currentItem.dragItem.localObject as? MTimeslot else {
                            return
                        }
                        // Update current timeslot to new value
                        localObject.task?.timeFrom = destItem.timeFrom
                        localObject.task?.timeTo = newEndTime
                        
                        // Update task to DB
                        Session.shared.tasks[localObject.task!.id] = localObject.task
                        
                        // Re-generate timeslot from updated tasklist
                        let newAllTasks = Array(Session.shared.tasks.keys).map{Session.shared.tasks[$0]!}
                        let employeeId = sourceIndexPath.section - 1
                        let tasksOfEmployee = newAllTasks.filter{ element in
                            return element.assignedId == employeeId
                        }
                        
                        // Generate timeslot
                        self.data[sourceIndexPath.section] = self.generateTimeslots(tasks: tasksOfEmployee)
                        
                        // Update tasks counter
                        self.totalTasks[sourceIndexPath.section] = tasksOfEmployee.count
                        DispatchQueue.main.async {
                            self.collectionView.reloadSections(IndexSet(integer: sourceIndexPath.section))
                        }
                    } else {
                        print("Moving from this section to a new section")
                        // Assign from this employee to another employee
                        
                        // Get source section, destination section
                        guard let sourceSection = self.data[sourceIndexPath.section] as? [MTimeslot], let destinationSection = self.data[destinationIndexPath.section] as? [MTimeslot] else {
                            return
                        }
                        
                        // source timeslot
                        let sourceItem = sourceSection[sourceIndexPath.row - 1]
                        // destination timeslot
                        let destItem = destinationSection[destinationIndexPath.row - 1]
                        let taskDuration = sourceItem.timeTo.timeIntervalSince(sourceItem.timeFrom)
                        let newEndTime = destItem.timeFrom.addingTimeInterval(taskDuration)
                        let tomorrowDate = Date().addingTimeInterval(86400)
                        let endOfToday = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: tomorrowDate)!
                        
                        // Make sure task end time < end of day
                        guard newEndTime < endOfToday  else {
                            self.showAlert(message: "Task must be finished in the same day")
                            return
                        }
                        // Check if drag/drop correct item
                        guard var localObject = currentItem.dragItem.localObject as? MTimeslot else {
                            return
                        }
                        // Update task to new timeFrom, timeTo, update assigned employee id
                        localObject.task?.timeFrom = destItem.timeFrom
                        localObject.task?.timeTo = newEndTime
                        let newEmployeeId = destinationIndexPath.section - 1
                        localObject.task?.assignedId = newEmployeeId
                        
                        // Update tasklist to DB
                        Session.shared.tasks[localObject.task!.id] = localObject.task
                        
                        // Re-generate timeslot from updated tasklist
                        let newAllTasks = Array(Session.shared.tasks.keys).map{Session.shared.tasks[$0]!}
                        let oldEmployeeId = sourceIndexPath.section - 1
                        let tasksOfOldEmployee = newAllTasks.filter{ element in
                            return element.assignedId == oldEmployeeId
                        }
                        let tasksOfNewEmployee = newAllTasks.filter{ element in
                            return element.assignedId == newEmployeeId
                        }
                        // Generate timeslot
                        self.data[sourceIndexPath.section] = self.generateTimeslots(tasks: tasksOfOldEmployee)
                        self.data[destinationIndexPath.section] = self.generateTimeslots(tasks: tasksOfNewEmployee)
                        // Update tasks counter
                        self.totalTasks[sourceIndexPath.section] = tasksOfOldEmployee.count
                        self.totalTasks[destinationIndexPath.section] = tasksOfNewEmployee.count
                        // Reload section
                        DispatchQueue.main.async {
                            self.collectionView.reloadSections(IndexSet(arrayLiteral: sourceIndexPath.section, destinationIndexPath.section))
                        }
                    }
                }
            }
            break
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        // MARK: UIKit has a bug with destination indexpath -> have to recalculate the indexpath my self
        // Calculating location in view
        let location = session.location(in: collectionView)
        var correctDestination: IndexPath?
        
        // Calculate index inside performUsingPresentationValues
        collectionView.performUsingPresentationValues {
            correctDestination = collectionView.indexPathForItem(at: location)
        }
        
        guard let destination = correctDestination else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        // Make sure it's local drag session
        guard session.localDragSession != nil else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        // Make sure destination >< Column Name or Row Name
        guard (destination.section > 0 && destination.row > 0) else {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        // Check if has task already
        if let sectionData = data[destination.section] as? [MTimeslot], let _ = sectionData[destination.row - 1].task {
            return UICollectionViewDropProposal(operation: .forbidden)
        }
        
        // Allow moving
        return UICollectionViewDropProposal(
            operation: .move,
            intent: .insertAtDestinationIndexPath)
    }
}

// MARK: CustomLayoutDelegate
extension TimesheetViewController: CustomLayoutDelegate {
    func sizeForItemAtIndexPath(indexPath: IndexPath) -> CGSize {
        if (indexPath.section == 0 || indexPath.row == 0) {
            return CGSize(width: CELL_WIDTH_BASE, height: CELL_HEIGHT_BASE)
        } else {
            if let sectionData = data[indexPath.section] as? [MTimeslot], let task = sectionData[indexPath.row - 1].task {
                return CGSize(width: CELL_WIDTH_BASE, height: CELL_HEIGHT_BASE * task.timeTo.timeIntervalSince(task.timeFrom)/TIMESPAN)
            }
            
            return CGSize(width: CELL_WIDTH_BASE, height: CELL_HEIGHT_BASE)
        }
    }
}
