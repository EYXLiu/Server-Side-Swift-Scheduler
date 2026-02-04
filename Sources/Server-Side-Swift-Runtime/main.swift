// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Scheduler

let task1: SchedulerTask = SchedulerTask(pid: 1, priority: 1) {
    for i: Int in 0..<10 {
        print("Task 1 running \(i)")
        Scheduler.shared.yieldIfNeeded()
        usleep(10_000)
    }
}

Scheduler.shared.addTask(task1)
Scheduler.shared.start()

print("Hello, world!")
