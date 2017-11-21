//
//  Random.swift
//  SingleRxSignal
//
//  Created by Alexander Cyon on 2017-11-09.
//  Copyright © 2017 Alexander Cyon. All rights reserved.
//

import Foundation


extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}


func randomName() -> String {
    return [
        "Patricia",
        "Jennifer",
        "Elizabeth",
        "Linda",
        "Barbara",
        "Susan",
        "Jessica",
        "Margaret",
        "Sarah",
        "Nancy",
        "Betty",
        "Lisa",
        "Dorothy",
        "Sandra",
        "Ashley",
        "Kimberly",
        "Donna",
        "Carol",
        "Michelle",
        "Emily",
        "Amanda",
        "Helen",
        "Melissa",
        "Deborah",
        "Stephanie",
        "Laura",
        "Rebecca",
        "Sharon",
        "Cynthia",
        "Kathleen",
        "Amy",
        "Shirley",
        "Anna",
        "Angela",
        "Ruth",
        "Brenda",
        "Pamela",
        "Nicole",
        "Katherine",
        "Virginia",
        "Catherine",
        "Christine",
        "Samantha",
        "Debra",
        "Janet",
        "Rachel",
        "Carolyn",
        "Emma",
        "Maria",
        "Heather",
        "Diane",
        "Julie",
        "Joyce",
        "Evelyn",
        "Frances",
        "Joan",
        "Kelly",
        "Victoria",
        "Lauren",
        "Martha",
        "Judith",
        "Cheryl",
        "Megan",
        "Andrea",
        "Ann",
        "Alice",
        "Christina",
        "Jean",
        "Doris",
        "Kathryn",
        "Olivia",
        "Gloria",
        "Marie",
        "Teresa",
        "Sara",
        "Janice",
        "Julia",
        "Grace",
        "Judy",
        "Rose",
        "Beverly",
        "Denise",
        "Marilyn",
        "Amber",
        "Madison",
        "Danielle",
        "Brittany",
        "Diana",
        "Abigail",
        "Jane",
        "Natalie",
        "Lori",
        "Tiffany",
        "Alexis",
        "Kayla",
        "Jacqueline"
        ].randomItem() ?? "Sajjon"
}
