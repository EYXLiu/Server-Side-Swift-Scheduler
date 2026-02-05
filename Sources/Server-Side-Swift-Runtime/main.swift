// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
import Scheduler

// run in function so declared functions aren't defaulted to mainactor
func runScheduler() async {
    let task1: SchedulerTask = await SchedulerTask(priority: 3, work: { task in 
        switch task.step {
        case 0:
            for i: Int in 0..<10 {
                print("Task \(task.getPid()) running \(i)")
                await Scheduler.shared.yieldIfNeeded()
                usleep(10_000)
            }
            await Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    let task2: SchedulerTask = await SchedulerTask(priority: 4, work: { task in
        switch task.step {
        case 0:
            for i: Int in 30..<40 {
                print("Task \(task.getPid()) running \(i)")
                await Scheduler.shared.yieldIfNeeded()
                usleep(10_000)
            }
            await Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    let interruptTask: InterruptSchedulerTask = await InterruptSchedulerTask(priority: 1, interruptWork: { task in 
        switch task.step {
        case 0:
            print("Task \(task.getPid()) waiting on interrupt")
            task.waitInterrupt()
            await Scheduler.shared.yieldIfNeeded()
        case 1:
            print("Task \(task.getPid()) received interrupt")
            await Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    let ioTask: TimedSchedulerTask = await TimedSchedulerTask(priority: 2, timedWork: { task in 
        switch task.step {
        case 0:
            print("Task \(task.getPid()) starting I/O")
            task.sleep(seconds: 1)
            await Scheduler.shared.yieldIfNeeded()
        case 1:
            print("Task \(task.getPid()) finished I/O")
            await Scheduler.shared.yieldIfNeeded()
        default:
            task.finish()
        }
    })

    // interrupt for the interrupt task (after 2 seconds)
    Task {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        // actor isolation guarantees actions are queued, so no race lock
        Task { await Scheduler.shared.signalInterrupt(for: interruptTask.getPid()) }
    }

    await Scheduler.shared.addTask(task1)
    await Scheduler.shared.addTask(task2)
    await Scheduler.shared.addTask(ioTask)
    await Scheduler.shared.addTask(interruptTask)
    await Scheduler.shared.start()

    await Scheduler.shared.printMetrics()
    await Scheduler.shared.printMemoryUsage()
}

await runScheduler()