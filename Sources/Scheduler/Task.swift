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
    public var step: Int = 0
    var priority: Int
    let work: (SchedulerTask) -> Void
    var cyclesExecuted: UInt64 = 0 // for metrics

    public init(pid: Int, priority: Int, work: @escaping (SchedulerTask) -> Void) {
        self.pid = pid
        self.state = .ready
        self.priority = priority
        self.work = work
    }

    open func isBlocked() -> Bool {
        false
    }

    public func run() {
        guard state == .ready else { return }
        state = .running
        let start: UInt64 = mach_absolute_time()
        work(self)
        let end: UInt64 = mach_absolute_time()

        var info: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        cyclesExecuted += (end - start) * UInt64(info.numer) / UInt64(info.denom)
        if state == .running {
            state = .ready
        }
    }

    public func finish() {
        state = .finished
    }

    public func incrementStep() {
        step += 1
    }

    public func unblock() {
        state = .ready
    }
}

public class TimedSchedulerTask : SchedulerTask {
    var wakeUpAt: TimeInterval?

    public init(pid: Int, priority: Int, timedWork: @escaping (TimedSchedulerTask) -> Void) {
        super.init(pid: pid, priority: priority) { task in
            guard let timedTask = task as? TimedSchedulerTask else { return }
            timedWork(timedTask)
        }
    }

    public func sleep(seconds: TimeInterval) {
        wakeUpAt = Date().timeIntervalSinceReferenceDate + seconds
        state = .blocked
    }

    override public func isBlocked() -> Bool {
        guard let wake: TimeInterval = wakeUpAt else { return false }
        let blocked: Bool = Date().timeIntervalSinceReferenceDate < wake
        if !blocked {
            state = .ready
        }
        return blocked
    }
}
