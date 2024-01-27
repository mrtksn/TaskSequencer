# TaskSequencer

**TaskSequencer** is a Swift package designed to manage and execute a sequence of tasks, both synchronous and asynchronous, with specified delays. This tool is ideal for scenarios where tasks need to be performed in a specific order, with controlled timing — such as UI animations, sequential network requests, or chained operations with dependencies.

## Features

* Manage a sequence of synchronous and asynchronous tasks.
* Specify delays for each task individually.
* Control task execution with pause, resume, and cancel functionalities.
* Add, remove, and reset tasks dynamically.

### Installation

Install like any other Swift package.

## Usage

**Basic Example**

```swift
    import TaskSequencer
    
    let sequencer = TaskSequencer()
    
    // Adding a synchronous task
    sequencer.addTaskWithDelay(id: "task1", delay: 2) {
        print("This is a synchronous task")
    }
    
    // Adding an asynchronous task
    sequencer.addTaskWithDelay(id: "task2", delay: 1) {
        await someAsyncOperation()
    }
    
    // Start executing tasks
    sequencer.start()

```

**Removing a Task**

```swift
    sequencer.removeTaskByID(id: "task1")
```

**Controlling Execution**

```swift
    // Pause the sequence
    sequencer.pause()
    
    // Resume the sequence
    sequencer.resume()
    
    // Cancel all tasks
    sequencer.cancel()
    
    // Reset the sequencer
    sequencer.reset()
```

## API Reference

* **addTaskWithDelay(id:delay:task:):** Add a synchronous task with a specified delay.
* **addTaskWithDelay(id:delay:task:):** Add an asynchronous task with a specified delay.
* **removeTaskByID(id:):** Remove a task from the sequence using its ID.
* **start():** Start or resume executing the tasks.
* **pause():** Pause the task execution.
* **resume():** Resume the task execution.
* **cancel():** Cancel all tasks in the sequence.
* **reset():** Cancel all tasks and clear the sequence.


## Considerations and Gotchas

* **Thread Blocking:** DelayedOperation uses Thread.sleep, which blocks the thread on which it is running. Ensure this aligns with your performance and concurrency needs.
* **Main Thread:** Operations are executed on background threads and do not block the main thread. However, ensure tasks added to the sequencer, especially UI updates, are dispatched on the main thread if necessary.
* **Error Handling:** The current implementation does not explicitly handle errors in task execution. Consider implementing error handling based on your specific requirements.
* **Resource Management:** Be mindful of resource usage, especially with AsyncDelayedOperation, when scheduling a large number of tasks or tasks with long-running operations.


## License

MIT License








