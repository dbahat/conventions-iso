//
//  Convention.swift
//  Conventions
//
//  Created by David Bahat on 2/1/16.
//  Copyright © 2016 Amai. All rights reserved.
//

import Foundation

class Convention {
    static let instance = Convention()
    static let date = NSDate.from(year: 2016, month: 8, day: 25)
    static let name = "Cami2016"
    static let displayName = "כאמ\"י 2016"
    static let mailbox = "dbahat@live.com"
    
    // The APNS token. Set during app init, and saved here in case the user wish to change his push
    // notifications topics (which requires re-registration)
    static var deviceToken = NSData()
    
    var halls: Array<Hall>
    var events: Events
    var updates = Updates()
    
    let eventsInputs = UserInputs.Events()
    
    let feedback = UserInputs.ConventionInputs()
    let feedbackQuestions: Array<FeedbackQuestion>
    
    var notificationCategories: Set<String>
 
    init() {
        halls = [
            Hall(name: "אולם ראשי", order: 1),
            Hall(name: "אודיטוריום שוורץ", order: 2),
            Hall(name: "אשכול 1", order: 3),
            Hall(name: "אשכול 2", order: 4),
            Hall(name: "אשכול 3", order: 5)
        ];
        
        events = Events(halls: halls)
        
        if let topics = NSUserDefaults.standardUserDefaults().stringArrayForKey(NotificationHubInfo.CATEGORIES_NSUSERDEFAULTS_KEY) {
            notificationCategories = Set(topics)
        } else {
            notificationCategories = Set(NotificationHubInfo.DEFAULT_CATEGORIES)
        }
        
        feedbackQuestions = [
            FeedbackQuestion(question:"גיל", answerType: .MultipleAnswer, answersToSelectFrom: [
                "פחות מ-12", "17-12", "25-18", "+25"
                ]),
            FeedbackQuestion(question:"עד כמה נהנית בכנס?", answerType: .Smiley),
            FeedbackQuestion(question:"האם המפה והשילוט היו ברורים ושימושיים?", answerType: .MultipleAnswer, answersToSelectFrom: [
                "כן", "לא"
                ]),
            FeedbackQuestion(question: "אם היה אירוע שרצית ללכת אילו ולא הלכת, מה הסיבה לכך?", answerType: .TableMultipleAnswer, answersToSelectFrom: [
                "האירוע התנגש עם אירוע אחר שהלכתי אילו",
                "לא הצלחתי למצא את החדר",
                "האירוע התרחש מוקדם או מאוחר מידי",
                "סיבה אחרת",
                ]),
            FeedbackQuestion(question: "הצעות לשיפור ודברים לשימור", answerType: .Text)
        ]
    }
    
    func findHallByName(name: String) -> Hall {
        if let hall = halls.filter({hall in hall.name == name}).first {
            return hall
        }
        print("Couldn't find hall ", name, ". Using default hall.");
        return Hall(name: "אירועים מיוחדים", order: 6)
    }
    
    func isFeedbackSendingTimeOver() -> Bool {
        return NSDate().compare(Convention.date.addDays(14)) == .OrderedDescending
    }
}

