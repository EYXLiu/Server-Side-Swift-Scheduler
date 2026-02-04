import Foundation
import CShims
import Darwin

@MainActor
public class Scheduler {
    // singleton
    public static let shared: Scheduler = Scheduler()
    private var tasks: [SchedulerTask] = []
    private var currentTask: SchedulerTask?
    var shouldYield: Bool = false

    public func addTask(_ task: SchedulerTask) {
        tasks.append(task)
    }

    private func setupTimer(timeSliceMs: UInt32) {
        DispatchQueue.global().async {
            while true {
                usleep(timeSliceMs * 1_000)
                DispatchQueue.main.async {
                    self.shouldYield = true
                }
            }
        }
    }

    private func scheduleNext() {
        let readyTasks: [SchedulerTask] = tasks.filter { $0.state == .ready || ( $0.state == .blocked && !$0.isBlocked()) }
        guard !readyTasks.isEmpty else { return }

        if let task: SchedulerTask = readyTasks.min(by: { $0.priority < $1.priority }) {
            currentTask = task
        }
    }

    public func start(timeSliceMs: UInt32 = 50) {
        setupTimer(timeSliceMs: timeSliceMs)

        while tasks.contains(where: { $0.state != .finished }) {
            scheduleNext()
            currentTask?.run()

        }
    }

    public func yieldIfNeeded() {
        if shouldYield {
            shouldYield = false
            currentTask?.state = .ready
            return
        }
    }

    public func printMetrics() {
        print("--- Task Metrics ---")
        for task in tasks {
            print("Task \(task.pid): executed cycles = \(task.cyclesExecuted)")
        }
    }

    public func printMemoryUsage() {
        var info: task_basic_info = task_basic_info()
        var count: mach_msg_type_number_t = mach_msg_type_number_t(MemoryLayout<task_basic_info>.size / MemoryLayout<natural_t>.size)
        let kr = withUnsafeMutablePointer(to: &info) { 
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { 
                task_info(mach_task_self_, task_flavor_t(TASK_BASIC_INFO), $0, &count)
            }
        }

        if kr == KERN_SUCCESS {
            print("--- Memory Metrics---")
            print("Memory used: \(info.resident_size / 1024) KB")
        }
    }
}
