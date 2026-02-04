import Foundation
import CShims

public enum TaskState {
    case ready
    case running
    case blocked
    case finished
}

// each task is in a "goroutine" lightweight task that yields to other tasks 
public class SchedulerTask {
    let pid: Int
    var state: TaskState
    var priority: Int
    let work: () -> Void

    public init(pid: Int, priority: Int, work: @escaping () -> Void) {
        self.pid = pid
        self.state = .ready
        self.priority = priority
        self.work = work
    }

    public func run() {
        guard state == .ready else { return }
        state = .running
        work()
        state = .finished
    }
}
