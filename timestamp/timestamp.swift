//
//  main.swift
//  timestamp
//
//  Created by Ian Hocking on 03/01/2023.
//

import Foundation
import ArgumentParser
import Cocoa

// First version drafted 23003:725

// @main only works if the filename for the code is not `main`. [https://stackoverflow.com/q/73431031]

@main
struct TimeStamp: ParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Creates a code representing the current date and time.", discussion: """
As an example, a stamp might be "21308;456". When this is created, it is copied to the clipboard.

This means:
- 21st year (of century)
- 308th day of the year
- ; = Thursday
- 0.456 is the metric time of the day in GMT

Sunday to Saturday are represented by: /.:,;'\\
""",
    version: "1.0a")

    @Flag(name: .shortAndLong, help: "Hide year.")
    var yearHidden = false

    @Flag(name: .shortAndLong, help: "Hide day.")
    var dayHidden = false

    @Flag(name: .shortAndLong, help: "Hide weekday.")
    var weekDayHidden = false

    @Flag(name: .shortAndLong, help: "Hide time.")
    var timeHidden = false

    @Flag(name: .shortAndLong, help: "Do not copy to clipboard.")
    var clipboardNotUsed = false


    @Option(name: .shortAndLong, help: "Parse a (full) timestamp.")
    var stamp: String?

    mutating func run() throws {

        if let stamp {
            do {
                try print(parseDate(from: stamp))
                return
            } catch let error {
                print(error.localizedDescription)
                return
            }
        }

        var stamp = ""

        if !yearHidden {
            stamp += getYearStamplet()
        }

        if !dayHidden {
            stamp += getDayStamplet()
        }

        if !weekDayHidden {
            stamp += getWeekdayStamplet()
        }

        if !timeHidden {
            stamp += getTimeStamplet()
        }
        
        print(stamp)

        if !clipboardNotUsed {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(stamp, forType: .string)
        }
    }

    func getYearStamplet() -> String {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: Date())
        let lastTwoDigits = String(format: "%02d", year % 100)

        return lastTwoDigits
    }

    func getDayStamplet() -> String {
        let calendar = Calendar.current
        let date = Date()

        if let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) {
            return String(format: "%03d", dayOfYear % 1000)
        } else {
            return ""
        }
    }

    func getWeekdayStamplet() -> String {
        let calendar = Calendar.current
        let date = Date()

        let weekday = calendar.component(.weekday, from: date)
        let weekdays = ["/", ".", ":", ",", ";", "'", "\""]
        let weekdayChar = weekdays[weekday - 1]

        return weekdayChar
    }

    func getTimeStamplet() -> String {
        let calendar = Calendar.current
        let date = Date()

        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let second = calendar.component(.second, from: date)

        let timeFraction = Double(hour) / 24 + Double(minute) / (24 * 60) + Double(second) / (24 * 60 * 60)

        return String(String(format: "%.3f", timeFraction).dropFirst(2))
    }

    func parseDate(from input: String) throws -> String {
        guard input.count == 9 else {
            throw ParseError.invalidLength
        }

        // First two digits represent the year
        guard
            let year = Int(input[input.startIndex..<input.index(input.startIndex, offsetBy: 2)])
        else {
            throw ParseError.generalError
        }

        guard year > -1 && year < 100 else {
            throw ParseError.invalidYear
        }

        // Next three digits represent the day of the year
        guard
            let dayOfYear = Int(input[input.index(input.startIndex, offsetBy: 2)..<input.index(input.startIndex, offsetBy: 5)])
        else {
            throw ParseError.generalError
        }

        guard dayOfYear > 0 && dayOfYear < 366 else {
            throw ParseError.invalidDayOfYear
        }

        // Last three digits represent the percent of time taken during the day
        let percentOfDay = Double(input[input.index(input.startIndex, offsetBy: 6)...])! / 1000.0

        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents(calendar: calendar, day: dayOfYear, hour: 0, minute: 0, second: 0)
        dateComponents.year = 2000 + year

        let secondsInADay = Double(calendar.maximumRange(of: .second)!.count) * 60 * 24
        let seconds = secondsInADay * percentOfDay
        dateComponents.second = Int(seconds)

        let date = calendar.date(from: dateComponents)!

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM, yyyy, 'at' h:mma"
        let formattedDate = dateFormatter.string(from: date)

        return formattedDate
    }
}

enum ParseError: Error {
    case invalidLength
    case invalidDayOfYear
    case invalidYear
    case generalError
}

extension ParseError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .invalidLength:
                return "Wrong length."
            case .invalidDayOfYear:
                return "Day of year is out of bounds."
            case .invalidYear:
                return "Year is out of bounds."
            case .generalError:
                return "General error."
        }
    }
}
