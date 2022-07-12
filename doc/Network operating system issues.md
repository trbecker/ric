The state of the NOS interfaces (YANG) is dependant on the state of the applications, which is dependant on the state of the network, and this state is propagated via events inside the system. This makes easy to create inconsistencies, since there's multiple _[truth](truth.md)_ sources in the system.

The implementation of NOS usually tries to disagregate and specialize control applications, with a communication layer responsible for transmitting state changes, which also creates multiple state containers.

The NOS modeling language defines only the communication model, leaving the application model, integration, testing and validation up to the developers.
