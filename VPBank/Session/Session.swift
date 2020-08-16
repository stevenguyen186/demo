//
//  Session.swift
//  VPBank
//
//  Created by Van Nguyen on 8/15/20.
//  Copyright © 2020 Van Nguyen. All rights reserved.
//

import Foundation



class Session {
    static let shared = Session()
    
    // MARK: Props
    var employees: [Int: MEmployee]
    var tasks: [Int: MTask]
    var timeslots: [Date]

    // MARK: Initialization
    private init() {
        self.employees = [Int: MEmployee]()
        self.tasks = [Int: MTask]()
        self.timeslots = [Date]()
        
        // Mock employees
        for (index, item) in EMPLOYEE_NAMES.enumerated() {
            self.employees[index] = MEmployee(name: item, id: index, color: COLORS_PACK[index%10])
        }
//        print("===EMPLOYEES===")
//        print(self.employees)
        
        // Mock tasks
        let taskLength: Double = 900
        for (index, item) in IDIOMS.enumerated() {
            let testStartDate = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
            self.tasks[index] = MTask(name: item, id: index, timeFrom: testStartDate, timeTo: testStartDate.addingTimeInterval(taskLength), assignedId: index)
            let testStartDate2 = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
            self.tasks[index + IDIOMS.count * 2] = MTask(name: item, id: index + IDIOMS.count * 2, timeFrom: testStartDate2, timeTo: testStartDate2.addingTimeInterval(taskLength), assignedId: index)
        }
//        print("===TASKS===")
//        for task in tasks {
//            print(task)
//        }
        
//        // TODO: Remove later
//        let testStartDate = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
//        self.tasks[0] = MTask(name: IDIOMS[0], id: 0, timeFrom: testStartDate, timeTo: testStartDate.addingTimeInterval(taskLength), assignedId: 0)
//        // TODO: Remove later
        
        // Calculate timeslot
        let currentDateTime = Date()
        let startDate = Calendar.current.date(bySettingHour: START_WORKING_TIME, minute: 0, second: 0, of: currentDateTime)!
        let endDate = Calendar.current.date(bySettingHour: END_WORKING_TIME, minute: 0, second: 0, of: currentDateTime)!
        var timeslot: Date = startDate
        while timeslot < endDate {
            self.timeslots.append(timeslot)
            timeslot = timeslot.addingTimeInterval(TimeInterval(TIMESPAN))
        }
//        print("===TIME SLOT===")
//        for timeslot in timeslots {
//            print(timeslot.description(with: .current))
//        }
        
    }
}
