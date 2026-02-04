import Foundation
import CShims
import Darwin

@MainActor
public class Scheduler {
    // singleton
    public static let shared: Scheduler = Scheduler()
    private var tasks: [SchedulerTask] = []
    private var currentTaskIndex: Int = 0
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

    public func start(timeSliceMs: UInt32 = 50) {
        setupTimer(timeSliceMs: timeSliceMs)

        while tasks.contains(where: { $0.state != .finished }) {
            let task: SchedulerTask = tasks[currentTaskIndex]
            guard task.state != .finished else {
                currentTaskIndex = (currentTaskIndex + 1) % tasks.count
                continue
            }

            task.run()

            currentTaskIndex = (currentTaskIndex + 1) % tasks.count
        }
    }

    public func yieldIfNeeded() {
        if shouldYield {
            shouldYield = false
            return
        }
    }
}
