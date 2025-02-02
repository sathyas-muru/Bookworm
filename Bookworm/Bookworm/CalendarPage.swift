
import UIKit
import EventKit
import EventKitUI
import CoreData

var eventList: [Events] = []
var goalsList: [Goals] = []

class Events {
    var title: String
    var date: Date
    var notes: String
    var id: UUID
    
    init(title: String, date: Date, notes: String, id: UUID) {
        self.title = title
        self.date = date
        self.notes = notes
        self.id = id
    }
}

class Goals {
    var content: String
    var checked: Bool
    
    init(content: String, checked: Bool) {
        self.content = content
        self.checked = checked
    }
}

class GoalTableViewCell: UITableViewCell {
    
    let label = UILabel()
    let checkbox = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        label.translatesAutoresizingMaskIntoConstraints = false
                contentView.addSubview(label)

                // Configure the checkbox button
                checkbox.translatesAutoresizingMaskIntoConstraints = false
                checkbox.image = UIImage(systemName: "square")
                contentView.addSubview(checkbox)

                // Add constraints
                NSLayoutConstraint.activate([
                    checkbox.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                            checkbox.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                            checkbox.widthAnchor.constraint(equalToConstant: 24),
                            checkbox.heightAnchor.constraint(equalToConstant: 24),

                            label.leadingAnchor.constraint(equalTo: checkbox.trailingAnchor, constant: 10),
                            label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15)
                    
                ])
            }
            required init?(coder: NSCoder) {
                    fatalError("init(coder:) has not been implemented")
                }
    }

class CalendarPage: UIViewController, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate, EKEventEditViewDelegate, UITableViewDelegate, UITableViewDataSource {

    var selectedDate: Date?
    var tableView: UITableView!
    var calendarView: UICalendarView!
    var addEventLabel: UILabel!
    var addGoalButton: UIButton!
    var eventStore = EKEventStore()

    override func viewDidLoad() {
        super.viewDidLoad()
        Theme.setTheme(to: self, theme: themeSelector)
        createCalendar()
        createTable()
        
        // checklist example:
        var exampleGoal = Goals(content: "Finish reading Six of Crows", checked: false)
        goalsList.append(exampleGoal)
        
        // Load events from Core data
        let fetchedEvents = getSavedEvents()
        for event in fetchedEvents {
            if let title = event.value(forKey: "title") as? String,
               let notes = event.value(forKey: "note") as? String,
               let id = event.value(forKey: "id") as? UUID,
               let date = event.value(forKey: "date") as? Date {
                var savedEvent = Events(title: title, date: date, notes: notes, id: id)
                eventList.append(savedEvent)
            }
        }

    }
    
    
    func createCalendar() {
        calendarView = UICalendarView()
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        // set up calendar view
        calendarView.calendar = .current
        calendarView.locale = .current
        calendarView.fontDesign = .rounded
        calendarView.delegate = self
        calendarView.backgroundColor = bubbleColor
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendarView.selectionBehavior = selection
        
        view.addSubview(calendarView)
        
        // Set constraints
        NSLayoutConstraint.activate([
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:15),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
            calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -35),
            calendarView.heightAnchor.constraint(equalToConstant: 450)
        ])
        
        // delete button
        let deleteEventButton = UIButton(type: .system)
        deleteEventButton.setTitle("Delete Event", for: .normal)
        deleteEventButton.backgroundColor = fillColor
        deleteEventButton.layer.cornerRadius = 10
        deleteEventButton.addTarget(self, action: #selector(deleteEventButtonTapped), for: .touchUpInside)
        deleteEventButton.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(deleteEventButton)
                
                NSLayoutConstraint.activate([
                deleteEventButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -485),
                    deleteEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
                ])
        
        // create add event button
        let addEventButton = UIButton(type: .system)
        addEventButton.setTitle("Add Event", for: .normal)
        addEventButton.backgroundColor = fillColor
        addEventButton.layer.cornerRadius = 10
        addEventButton.addTarget(self, action: #selector(addEventButtonTapped), for: .touchUpInside)
        addEventButton.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(addEventButton)
                
                NSLayoutConstraint.activate([
                    addEventButton.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -485),
                    addEventButton.trailingAnchor.constraint(equalTo: deleteEventButton.leadingAnchor, constant: -5)
                ])
        
        // Add label
        addEventLabel = UILabel()
                addEventLabel.text = "Add goals to calendar"
                addEventLabel.font = UIFont(name: "Noteworthy-Bold", size: 20) // Bold Noteworthy font
                addEventLabel.translatesAutoresizingMaskIntoConstraints = false
                addEventLabel.textColor = .black // You can set this to your theme color
                view.addSubview(addEventLabel)
                NSLayoutConstraint.activate([
                    addEventLabel.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -485),
                    addEventLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10)
                ])
    }
    
    func createTable() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        // tableView.backgroundColor = bubbleColor
        tableView.register(GoalTableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        
        // Adding constraints:
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 150),
            tableView.bottomAnchor.constraint(equalTo: addEventLabel.topAnchor, constant: -10),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor,constant: -15)
        ])
        
        // add button
        addGoalButton = UIButton(type: .system)
        addGoalButton.setTitle("+", for: .normal)
        addGoalButton.layer.cornerRadius = 10
        addGoalButton.backgroundColor = fillColor
        addGoalButton.addTarget(self, action: #selector(addGoalButtonTapped), for: .touchUpInside)
        addGoalButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addGoalButton)
        
        NSLayoutConstraint.activate([
            addGoalButton.bottomAnchor.constraint(equalTo: tableView.topAnchor, constant: -15),
            addGoalButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
        ])
        
        // load sved goals from core data
        let fetchedGoals = getSavedGoals()
        for goal in fetchedGoals {
            if let content = goal.value(forKey: "content") as? String,
               let checked = goal.value(forKey: "checked") as? Bool {
                var savedGoal = Goals(content: content, checked: checked)
                goalsList.append(savedGoal)
            }
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GoalTableViewCell
        
        let goal = goalsList[indexPath.row]
            cell.label.text = goal.content
            cell.label.numberOfLines = 0
            cell.label.lineBreakMode = .byWordWrapping
            cell.backgroundColor = bubbleColor
            cell.label.textColor = .black
            cell.label.font = UIFont.systemFont(ofSize: 12)

        
        if goal.checked == true {
            cell.checkbox.image = UIImage(systemName: "checkmark.square.fill")
            cell.checkbox.tintColor = fillColor
            cell.checkbox.layer.borderColor = UIColor.black.cgColor
        } else {
            // cell.checkbox.setImage(UIImage(systemName: "square"), for: .normal)
            cell.checkbox.image = UIImage(systemName: "square")
        }

            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! GoalTableViewCell
        let goal = goalsList[indexPath.row]
        
        
            // Toggle the checkbox image when the cell is selected
            if cell.checkbox.image == UIImage(systemName: "square") {
                cell.checkbox.image = UIImage(systemName: "checkmark.square.fill")
                cell.checkbox.tintColor = fillColor
                cell.checkbox.layer.borderColor = UIColor.black.cgColor
                goal.checked = true
                updateGoalInCoreData(goal: goal)
            } else {
                // cell.checkbox.setImage(UIImage(systemName: "square"), for: .normal) // Unchecked image
                cell.checkbox.image = UIImage(systemName: "square")
                goal.checked = false
                updateGoalInCoreData(goal: goal)
            }
            
            // Deselect the cell after tapping
            tableView.deselectRow(at: indexPath, animated: true)
        }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteGoal(goal: goalsList[indexPath.row])
            goalsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    @objc func addGoalButtonTapped() {
        // present alert
        
        let alert = UIAlertController(
            title: "Create new goal", message: "Enter goal:", preferredStyle: .alert
        )
        
        // alert.overrideUserInterfaceStyle = .light
        alert.addTextField() { goal in
            goal.placeholder = "Enter goal"}
        let saveAction  = UIAlertAction(title: "Save", style: .default) {_ in
            guard let title = alert.textFields?[0].text, !title.isEmpty else {return}
            
            // add goal to goalList
            var newGoal = Goals(content: title, checked: false)
            goalsList.append(newGoal)
            print("Added to goal list")
            print(goalsList.count)
            self.tableView.reloadData()
            
            // add goal to core data
            self.saveNewGoal(goal: newGoal)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Theme.setTheme(to: self, theme: themeSelector)
        addEventLabel.textColor = textColor
        addGoalButton.backgroundColor = fillColor
        
        if let addEventButton = view.subviews.first(where: { $0 is UIButton && ($0 as! UIButton).title(for: .normal) == "Add Event" }) as? UIButton {
            addEventButton.backgroundColor = fillColor
        }
        
        if let deleteEventButton = view.subviews.first(where: { $0 is UIButton && ($0 as! UIButton).title(for: .normal) == "Delete Event" }) as? UIButton {
            deleteEventButton.backgroundColor = fillColor
                    // addEventLabel.textColor = textColor
                }
    }
    
    @objc func addEventButtonTapped() {
        // check if date is selceted, if not set it to today's date
        if selectedDate == nil {
                selectedDate = Date() // Set to current date
            }
        
        
        let alert = UIAlertController(
                   title: "Add Event", message: "Enter event details:", preferredStyle: .alert
               )

            // alert.overrideUserInterfaceStyle = .light
               alert.addTextField() { tfEventTitle in
                   tfEventTitle.placeholder = "Enter event title"}
               alert.addTextField() {tfdescription in tfdescription.placeholder = "Enter event description"}
        let saveAction  = UIAlertAction(title: "Save", style: .default) { [self]_ in
            guard let title = alert.textFields?[0].text, !title.isEmpty,
                  let notes = alert.textFields?[1].text else {return}
            
            // create event here
            var newEvent = Events(title: title, date: selectedDate!, notes: notes, id: UUID())
            // Save new event to core data
            eventList.append(newEvent)
            saveNewEvent(event: newEvent)
            
            self.updateCalendarViewDecorations()
            self.addEventToCalendarApp(event: newEvent)
            
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
              alert.addAction(saveAction)
              alert.addAction(cancelAction)
              present(alert, animated: true)
    }
    
    
    @objc func deleteEventButtonTapped() {
        
        if selectedDate == nil {
            selectedDate = Date()
        }
        
        // Fetch all events for the selected date
        let request = NSFetchRequest<NSManagedObject>(entityName: "SavedEvents")
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate!)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        do {
                let events = try context.fetch(request)

                // Check if there are any events on the selected date
                guard !events.isEmpty else {
                    print("No events found on the selected date.")
                    return
                }
            
        let alert = UIAlertController(title: "Delete Events", message: "All events on this date will be deleted", preferredStyle: .alert)
            
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        let deleteAction = UIAlertAction(title: "OK", style: .default) {_ in
            for event in events {
                context.delete(event)
            
            // remove from list
            if let eventDate = event.value(forKey: "date") as? Date,
                               let title = event.value(forKey: "title") as? String,
                               let notes = event.value(forKey: "note") as? String,
                               let id = event.value(forKey: "id") as? UUID {
                                print("event deleted from event list")
                                // Filter out the event from the eventList array
                                eventList.removeAll { $0.date == eventDate && $0.title == title && $0.id == id }
                            }
                            // Also delete the event from the actual calendar
                            self.deleteEventFromCalendar(eventDate: event.value(forKey: "date") as! Date)
                        }
            // delete from calendar view
            let calendar = Calendar.current
            let eventDate = self.selectedDate! // Assuming `event.date` is a `Date` object
                    let dateComponents = calendar.dateComponents([.year, .month, .day], from: eventDate)
            self.calendarView.reloadDecorations(forDateComponents: [dateComponents], animated: true)
            
            self.saveContext()

            }
            alert.addAction(deleteAction)
            present(alert,animated: true )
        
            
        } catch {
            print("No events found")
            print(EKEventStore.authorizationStatus(for: .event)
                  )
                  }
    
    }
    
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
                     let date = Calendar.current.date(from: dateComponents) else {
                   selectedDate = nil
                   return
               }
               selectedDate = date
    }
    
    func deleteEventFromCalendar(eventDate: Date) {
        let calendar = eventStore
        let startDate = eventDate
        let endDate = eventDate.addingTimeInterval(3600) // Assuming a default duration of 1 hour for the event

        // Search for the event in the calendar
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate)

        for event in events {
            do {
                // Remove the event from the calendar
                try eventStore.remove(event, span: .thisEvent)
                print("Event deleted from calendar.")
            } catch {
                print("Error deleting event from calendar: \(error)")
            }
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true)
    }
    

    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        
        // Filter events for the specific date
        let eventsOnDate = eventList.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
        
        // If no events, return nil (no decoration)
        guard !eventsOnDate.isEmpty else { return nil }

        let eventSummary = eventsOnDate.count > 1 ? "\(eventsOnDate.count) Events" : eventsOnDate.first?.title ?? "Event"
        
        // Create a decoration with the title
        return .customView {
            let label = UILabel()
            label.text = eventSummary
            label.font = UIFont.systemFont(ofSize: 10, weight: .medium)
            label.textColor = .black
            label.backgroundColor = aqua
            label.textAlignment = .left
            label.numberOfLines = 0
            return label
        }
    }

    
    // Update calendar view decorations
    func updateCalendarViewDecorations() {
        let calendar = Calendar.current
            let uniqueDateComponents = Set(eventList.map { calendar.dateComponents([.year, .month, .day], from: $0.date) })

            // Reload decorations for those date components
            calendarView.reloadDecorations(forDateComponents: Array(uniqueDateComponents), animated: true)
    }

    
    // Add event to calendar
    func addEventToCalendarApp(event: Events) {
        if (EKEventStore.authorizationStatus(for:.event)) != .fullAccess {
            eventStore.requestFullAccessToEvents() {
                (granted, error) in
                if granted {
                    
                    let ekEvent = EKEvent(eventStore: self.eventStore)
                    ekEvent.title = event.title
                    ekEvent.startDate = event.date
                    ekEvent.endDate = event.date.addingTimeInterval(3600) // Default to 1-hour duration
                    ekEvent.notes = event.notes
                    ekEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                    
                    do {
                        try self.eventStore.save(ekEvent, span: .thisEvent)
                        print("Event saved to calendar")
                    } catch {
                        print("Failed to save event to calendar: \(error)")
                    }
                }
            }
        } else {
            print("No calendar access")
            print(EKEventStore.authorizationStatus(for: .event))
        }
}
    
    // Save new events to core data function
    func saveNewEvent(event: Events) {
        
        let coreEvent = NSEntityDescription.insertNewObject(forEntityName: "SavedEvents", into: context)
        coreEvent.setValue(event.title, forKey: "title")
        coreEvent.setValue(event.date, forKey: "date")
        coreEvent.setValue(event.notes, forKey: "note")
        coreEvent.setValue(event.id, forKey: "id")
        
        do {
            try saveContext()
        } catch {
            print("Could not save event to core data")
        }
        
    }
    
    func deleteGoal(goal: Goals) {
        let request =  NSFetchRequest<NSManagedObject>(entityName: "SavedGoals")
        request.predicate = NSPredicate(format: "content == %@", goal.content)
        
        do {
            let results = try context.fetch(request)
            if let coreDataGoal = results.first {
                context.delete(coreDataGoal)
                try context.save()
            }
        } catch {
            print("Failed to update goal in Core Data: \(error)")
        }
    }
    
    // Save new goals to core data function
    func saveNewGoal(goal: Goals) {
        
        let coreEvent = NSEntityDescription.insertNewObject(forEntityName: "SavedGoals", into: context)
        coreEvent.setValue(goal.content, forKey: "content")
        coreEvent.setValue(goal.checked, forKey: "checked")
        
        do {
            try saveContext()
        } catch {
            print("Could not save event to core data")
        }
        
    }

    // retrieve from core data function
    func getSavedEvents() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedEvents")
        var fetchedResults: [NSManagedObject]?
        
        do {
                try fetchedResults = context.fetch(request) as? [NSManagedObject]
                } catch {
                    print("Error occured while retrieving obejct")
                    return []
                }
            return fetchedResults!
        }
    
    func updateGoalInCoreData(goal: Goals) {
        
        // Fetch the corresponding Goal entity from Core Data
        let request =  NSFetchRequest<NSManagedObject>(entityName: "SavedGoals")
        request.predicate = NSPredicate(format: "content == %@", goal.content)
        
        do {
            let results = try context.fetch(request)
            if let coreDataGoal = results.first {
                coreDataGoal.setValue(goal.checked, forKey: "checked")
                try context.save()
            }
        } catch {
            print("Failed to update goal in Core Data: \(error)")
        }
    }
    
    func getSavedGoals() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedGoals")
        var fetchedResults: [NSManagedObject]?
        
        do {
                try fetchedResults = context.fetch(request) as? [NSManagedObject]
                } catch {
                    print("Error occured while retrieving obejct")
                    return []
                }
            return fetchedResults!
        }
    
    func saveContext () {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        }
}



