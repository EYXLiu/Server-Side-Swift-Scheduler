import Foundation
import CShims

public enum TaskState {
    case ready
    case running
    case blocked
    case finished
}

// each task is in a "goroutine" lightweight task that yields to other tasks 
// i know unchecked sendable is unsafe but otherwise the scheduler code wouldn't allow run to be called as it might mutate and cause data races
public class SchedulerTask: @unchecked Sendable {
    // guarantee that all mutations happen inside Scheduler actor
    // no references to other threads
    // actor isolation guarantees sequential access
    let pid: Int
    var state: TaskState
    public var step: Int = 0
    var priority: Int
    let work: (SchedulerTask) async -> Void
    var cyclesExecuted: UInt64 = 0 // for metrics

    public init( priority: Int, work: @escaping (SchedulerTask) async -> Void) async {
        self.pid = await Scheduler.shared.allocatePid()
        self.state = .ready
        self.priority = priority
        self.work = work
    }

    open func isBlocked() -> Bool {
        false
    }

    public func run() async {
        guard state == .ready else { return }
        state = .running
        let start: UInt64 = mach_absolute_time()
        await work(self)
        let end: UInt64 = mach_absolute_time()

        var info: mach_timebase_info_data_t = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        cyclesExecuted += (end - start) * UInt64(info.numer) / UInt64(info.denom)

        incrementStep()
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

    public func getPid() -> Int {
        return pid
    }
}

public class TimedSchedulerTask : SchedulerTask, @unchecked Sendable {
    var wakeUpAt: TimeInterval?

    public init(priority: Int, timedWork: @escaping (TimedSchedulerTask) async -> Void) async {
        await super.init(priority: priority) { task in
            guard let timedTask = task as? TimedSchedulerTask else { return }
            await timedWork(timedTask)
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

public class InterruptSchedulerTask : SchedulerTask, @unchecked Sendable {
    private var interrupt: Bool = false

    public init(priority: Int, interruptWork: @escaping (InterruptSchedulerTask) async -> Void) async {
        await super.init(priority: priority) { task in
            guard let timedTask = task as? InterruptSchedulerTask else { return }
            await interruptWork(timedTask)
        }
    }

    public func waitInterrupt() {
        state = .blocked
    }

    public func signalInterrupt() {
        print("Interrupt received")
        interrupt = true
    }

    override public func isBlocked() -> Bool {
        let ready: Bool = interrupt
        if ready {
            state = .ready
        }
        return !ready
    }
}
