//
//  AddEvent.swift
//  HealthMe
//
//  Created by Luis Isaac Maya on 2/25/19.
//  Copyright © 2019 Luis Isaac Maya. All rights reserved.
//

import Foundation
import EventKit

class AddEvent {
    //TODO: AGREGAR UN EVENTO AL CALENDARIO
    func addEventToCalendar(title: String, description: String?, startDate: Date, endDate: Date, completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        let eventStore = EKEventStore()
        
        eventStore.requestAccess(to: .event, completion: { (granted, error) in
            if (granted) && (error == nil) {
                let event = EKEvent(eventStore: eventStore)
                event.title = title
                event.startDate = startDate
                event.endDate = endDate
                event.notes = description
                event.calendar = eventStore.defaultCalendarForNewEvents
                do {
                    try eventStore.save(event, span: .thisEvent)
                } catch let e as NSError {
                    completion?(false, e)
                    return
                }
                print("Se agrego el evento")
                completion?(true, nil)
            } else {
                print("Error al agregar el evento")
                completion?(false, error as NSError?)
            }
        })
    }
}
