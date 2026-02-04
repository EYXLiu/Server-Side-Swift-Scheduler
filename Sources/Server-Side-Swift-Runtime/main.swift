// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Scheduler

let task1: SchedulerTask = SchedulerTask(pid: 1, priority: 2, work: { task in 
    switch task.step {
    case 0:
        for i: Int in 0..<10 {
            print("Task 1 running \(i)")
            Scheduler.shared.yieldIfNeeded()
            usleep(10_000)
        }
        task.incrementStep()
    default:
        task.finish()
    }
})

let task2: SchedulerTask = SchedulerTask(pid: 2, priority: 5, work: { task in
    switch task.step {
    case 0:
        for i: Int in 30..<40 {
            print("Task 2 running \(i)")
            Scheduler.shared.yieldIfNeeded()
            usleep(10_000)
        }
        task.incrementStep()
    default:
        task.finish()
    }
})

let ioTask: TimedSchedulerTask = TimedSchedulerTask(pid: 3, priority: 1, timedWork: { task in 
    switch task.step {
    case 0:
        print("Task 3 starting I/O")
        task.sleep(seconds: 3)
        task.incrementStep()
    case 1:
        print("Task 3 finished I/O")
        task.incrementStep()
    default:
        task.finish()
    }
})

Scheduler.shared.addTask(task1)
Scheduler.shared.addTask(task2)
Scheduler.shared.addTask(ioTask)
Scheduler.shared.start()

print("Hello, world!")
