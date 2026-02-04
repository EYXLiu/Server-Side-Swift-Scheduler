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
        let readyTasks: [SchedulerTask] = tasks.filter { $0.state == .ready }
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
            return
        }
    }
}
