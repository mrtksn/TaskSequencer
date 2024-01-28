//
//  TaskSequencer.swift
//  QuitKit
//
//  Created by Mertol on 28/01/2024.
//
import Foundation

public class DelayedOperation: Operation {
    var task: () -> Void
    var delay: TimeInterval
    let id: String

    public init(id: String, delay: TimeInterval, task: @escaping () -> Void) {
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

    public init(id: String, delay: TimeInterval, task: @escaping () async -> Void) {
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
    
    public init() {
        queue.isSuspended = true
        queue.maxConcurrentOperationCount = 1
        /*
         // Add a dummy task
     addTaskWithDelay(id: "dummy", delay: 0) { /* Dummy task code */ }
         // Pause the queue immediately
         pause()
     
         */
    }
    
    /// Add a task that will wait for some time after the previous task is done
    /// - Parameters:
    ///   - id: Optional ID. Can be useful to provide an ID if you plan to cancel a specific task later
    ///   - delay: how much to wait before executing
    ///   - task: the task to execute
    func addTaskWithDelay(id: String = UUID().uuidString, delay: TimeInterval, task: @escaping () -> Void) {
        // Dummy operation for the delay
        let delayOperation = DelayedOperation(id: id + "_delay", delay: delay, task: {})
        
        // Actual task operation with no delay
        let actualTaskOperation = DelayedOperation(id: id, delay: 0, task: task)

        // Ensuring the actual task runs after the delay
        actualTaskOperation.addDependency(delayOperation)

        // Add both operations to the queue
        queue.addOperation(delayOperation)
        queue.addOperation(actualTaskOperation)
    }
    
    /// Add an async task that will wait for some time after the previous task is done
    /// - Parameters:
    ///   - id: Optional ID. Can be useful to provide an ID if you plan to cancel a specific task later
    ///   - delay: how much to wait before executing
    ///   - task: the async task to execute. Useful to use with async/await
    func addTaskWithDelay(id: String = UUID().uuidString, delay: TimeInterval, task: @escaping () async -> Void) {
        // Dummy operation for the delay
        let delayOperation = AsyncDelayedOperation(id: id + "_delay", delay: delay, task: {})

        // Actual async task operation with no delay
        let actualTaskOperation = AsyncDelayedOperation(id: id, delay: 0, task: task)

        // Ensuring the actual task runs after the delay
        actualTaskOperation.addDependency(delayOperation)

        // Add both operations to the queue
        queue.addOperation(delayOperation)
        queue.addOperation(actualTaskOperation)
    }
    
    /// Remove a task from the queue
    /// - Parameter id: the id of the task to remove
    public func removeTaskByID(id: String) {
        operations[id]?.cancel()
        operations.removeValue(forKey: id)
    }
    
    /// a convinience function. the same as resume()
    public func start() {
        resume()
    }
    
    
    /// Pause until resume or cancel
    public func pause() {
        queue.isSuspended = true
    }
    
    /// resume current que execution
    public func resume() {
        queue.isSuspended = false
    }
    
    /// cancel the current execution queue
    public func cancel() {
        queue.cancelAllOperations()
    }
    
    /// cancel the current execution and remove all the defined tasks
    public func reset() {
        cancel()
        operations.removeAll()
    }
}
