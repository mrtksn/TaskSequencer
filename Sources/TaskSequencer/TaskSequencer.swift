// The Swift Programming Language
// https://docs.swift.org/swift-book
//  TaskSequencer.swift
//  QuitKit
//
//  Created by Mertol on 27/01/2024.
//

import Foundation


public class DelayedOperation: Operation {
    var task: () -> Void
    var delay: TimeInterval
    let id: String

    init(id: String, delay: TimeInterval, task: @escaping () -> Void) {
        self.id = id
        self.delay = delay
        self.task = task
        super.init()
    }

    public override func main() {
        if isCancelled { return }
        Thread.sleep(forTimeInterval: delay)
        task()
    }
}
public class AsyncDelayedOperation: Operation {
    var task: () async -> Void
    var delay: TimeInterval
    let id: String

    init(id: String, delay: TimeInterval, task: @escaping () async -> Void) {
        self.id = id
        self.delay = delay
        self.task = task
        super.init()
    }

    public override func main() {
        guard !isCancelled else { return }

        let taskGroup = DispatchGroup()
        taskGroup.enter()

        Task {
            // Wait for the specified delay
            try? await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))

            // Execute the async task
            guard !isCancelled else {
                taskGroup.leave()
                return
            }
            await task()

            taskGroup.leave()
        }

        taskGroup.wait()
    }
}




public class TaskSequencer {
    private let queue = OperationQueue()
    private var operations = [String: DelayedOperation]()
    
    init() {
            // Add a dummy task
        addTaskWithDelay(id: "dummy", delay: 0) { /* Dummy task code */ }
            // Pause the queue immediately
            pause()
        }
    
    /// Add a task that will wait for some time after the previous task is done
    /// - Parameters:
    ///   - id: Optional ID. Can be useful to provide an ID if you plan to cancel a specific task later
    ///   - delay: how much to wait before executing
    ///   - task: the task to execute
    func addTaskWithDelay(id: String = UUID().uuidString, delay: TimeInterval, task: @escaping () -> Void) {
        let operation = DelayedOperation(id: id, delay: delay, task: task)
        operations[id] = operation
        queue.addOperation(operation)
    }
    
    /// Add an async task that will wait for some time after the previous task is done
    /// - Parameters:
    ///   - id: Optional ID. Can be useful to provide an ID if you plan to cancel a specific task later
    ///   - delay: how much to wait before executing
    ///   - task: the async task to execute. Useful to use with async/await
    func addTaskWithDelay(id: String = UUID().uuidString, delay: TimeInterval, task: @escaping () async -> Void) {
        let operation = AsyncDelayedOperation(id: id, delay: delay, task: task)
           queue.addOperation(operation)
       }
    
    /// Remove a task from the queue
    /// - Parameter id: the id of the task to remove
    func removeTaskByID(id: String) {
        operations[id]?.cancel()
        operations.removeValue(forKey: id)
    }
    
    /// a convinience function. the same as resume()
    func start() {
        resume()
    }
    
    
    /// Pause until resume or cancel
    func pause() {
        queue.isSuspended = true
    }
    
    /// resume current que execution
    func resume() {
        queue.isSuspended = false
    }
    
    /// cancel the current execution queue
    func cancel() {
        queue.cancelAllOperations()
    }
    
    /// cancel the current execution and remove all the defined tasks
    func reset() {
        cancel()
        operations.removeAll()
    }
}
