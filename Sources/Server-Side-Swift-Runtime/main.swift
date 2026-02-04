// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Scheduler

// run in function so declared functions aren't defaulted to mainactor
func runScheduler() {
    let task1: SchedulerTask = SchedulerTask(priority: 3, work: { task in 
        switch task.step {
        case 0:
            for i: Int in 0..<10 {
                print("Task \(task.getPid()) running \(i)")
                Scheduler.shared.yieldIfNeeded()
                usleep(10_000)
            }
            Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    let task2: SchedulerTask = SchedulerTask(priority: 4, work: { task in
        switch task.step {
        case 0:
            for i: Int in 30..<40 {
                print("Task \(task.getPid()) running \(i)")
                Scheduler.shared.yieldIfNeeded()
                usleep(10_000)
            }
            Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    let interruptTask: InterruptSchedulerTask = InterruptSchedulerTask(priority: 1, interruptWork: { task in 
        switch task.step {
        case 0:
            print("Task \(task.getPid()) waiting on interrupt")
            task.waitInterrupt()
            Scheduler.shared.yieldIfNeeded()
        case 1:
            print("Task \(task.getPid()) received interrupt")
            Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    let ioTask: TimedSchedulerTask = TimedSchedulerTask(priority: 2, timedWork: { task in 
        switch task.step {
        case 0:
            print("Task \(task.getPid()) starting I/O")
            task.sleep(seconds: 3)
            Scheduler.shared.yieldIfNeeded()
        case 1:
            print("Task \(task.getPid()) finished I/O")
            Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    // interrupt for the interrupt task (after 2 seconds)
    let interruptPid: Int = interruptTask.getPid()
    DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 2) {
        Scheduler.shared.signalInterrupt(for: interruptPid)
    }

    Scheduler.shared.addTask(task1)
    Scheduler.shared.addTask(task2)
    Scheduler.shared.addTask(ioTask)
    Scheduler.shared.addTask(interruptTask)
    Scheduler.shared.start()

    Scheduler.shared.printMetrics()
    Scheduler.shared.printMemoryUsage()
}

runScheduler()