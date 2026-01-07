import Foundation

/// Detects changes between cached and newly fetched NOTAMs
final class NOTAMChangeDetector {
    static let shared = NOTAMChangeDetector()

    /// Compares previous and current NOTAMs to detect changes
    func detectChanges(
        previous: [String: [NOTAM]],
        current: [String: [NOTAM]]
    ) -> [NOTAMChange] {
        var changes: [NOTAMChange] = []

        // Get all FIRs from both sets
        let allFIRs = Set(previous.keys).union(Set(current.keys))

        for fir in allFIRs {
            let prevNotams = previous[fir] ?? []
            let currNotams = current[fir] ?? []

            let firChanges = detectChangesForFIR(previous: prevNotams, current: currNotams)
            changes.append(contentsOf: firChanges)
        }

        return changes.sorted { $0.detectedAt > $1.detectedAt }
    }

    private func detectChangesForFIR(previous: [NOTAM], current: [NOTAM]) -> [NOTAMChange] {
        var changes: [NOTAMChange] = []

        let prevById = Dictionary(grouping: previous, by: { $0.id }).mapValues { $0.first! }
        let currById = Dictionary(grouping: current, by: { $0.id }).mapValues { $0.first! }

        let prevIds = Set(prevById.keys)
        let currIds = Set(currById.keys)

        // New NOTAMs (in current but not in previous)
        for id in currIds.subtracting(prevIds) {
            if let notam = currById[id] {
                changes.append(NOTAMChange(
                    changeType: .new,
                    notam: notam
                ))
            }
        }

        // Expired/Removed NOTAMs (in previous but not in current)
        for id in prevIds.subtracting(currIds) {
            if let notam = prevById[id] {
                // Check if it's a cancellation type
                let changeType: ChangeType = notam.type == .cancellation ? .cancelled : .expired
                changes.append(NOTAMChange(
                    changeType: changeType,
                    notam: notam
                ))
            }
        }

        // Modified NOTAMs (in both but different)
        for id in prevIds.intersection(currIds) {
            guard let prevNotam = prevById[id],
                  let currNotam = currById[id] else { continue }

            if hasSignificantChanges(previous: prevNotam, current: currNotam) {
                changes.append(NOTAMChange(
                    changeType: .modified,
                    notam: currNotam,
                    previousNotam: prevNotam
                ))
            }
        }

        return changes
    }

    /// Determines if two NOTAMs have significant differences
    private func hasSignificantChanges(previous: NOTAM, current: NOTAM) -> Bool {
        // Check text content
        if previous.text != current.text {
            return true
        }

        // Check effective dates
        if previous.effectiveStart != current.effectiveStart {
            return true
        }

        if previous.effectiveEnd != current.effectiveEnd {
            return true
        }

        // Check type changes
        if previous.type != current.type {
            return true
        }

        // Check scope/altitude changes
        if previous.minimumFL != current.minimumFL ||
           previous.maximumFL != current.maximumFL {
            return true
        }

        return false
    }
}
