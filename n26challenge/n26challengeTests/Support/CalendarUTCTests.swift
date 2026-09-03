import Foundation
import Testing
@testable import n26challenge

struct CalendarUTCTests {
    @Test func utcCalendarUsesGMTTimezone() {
        #expect(Calendar.utc.timeZone.secondsFromGMT() == 0)
    }

    @Test func endOfDayReturnsLastSecondOfDay() {
        let date = requiredAPIDate("03-09-2026").addingTimeInterval(3_600)

        let endOfDay = Calendar.utc.endOfDay(for: date)

        #expect(DateFormatter.apiDayString(from: endOfDay) == "03-09-2026")
        #expect(Calendar.utc.component(.hour, from: endOfDay) == 23)
        #expect(Calendar.utc.component(.minute, from: endOfDay) == 59)
        #expect(Calendar.utc.component(.second, from: endOfDay) == 59)
    }
}
