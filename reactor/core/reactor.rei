/* ? */

/** A Reasonably-typed Actor-model Library for the Browser

  [ReActor] works by scheduling processes to run in different schedulers
  that are in turn managed by a node

  A node corresponds to a browser agent (a browser window if you will), and it
  will manage as many schedulers as you have cores in your machine This is to
  utilize as much of the CPU power available when executing the processes

  Each scheduler corresponds to either the Main Thread of execution in the
  browser agent, or a WebWorker

  Every process that is spawned will be executed in any of the running
  schedulers, guaranteeing that the load is balanced amongst the browser agent
  cores

  You can send messages to processes from other processes This allows them to
  collaborate and solve problems together

  For more info on the Actor-model feel free to have a look at:

  - {{:https://enwikipediaorg/wiki/Smalltalk}Smalltalk}, {{:http://wwwerlangorg/}Erlang} and {{:https://elixir-langorg/}Elixir}
  - {{:https://arxivorg/vc/arxiv/papers/1008/10081459v8pdf}Hewitt's Actor Model of Computation}
  - {{:https://mitpressmitedu/books/actors}Gul Agha's Actors}
 */;

module Node = Node;
module Scheduler = Scheduler;
module Process = Process;
module Tracer = Tracer;

/**
  Spawning processes is a core functionality of [ReActor], and for every
  spawned process you will always get a process identifier back ({!Pid.t})

  You can use the returned {!Pid.t} to {!exit} this process, {!send} messages to
  it, {!register} it under a well-known name, or use it for tracing purposes
  with {!trace}
  */
let spawn: (Process.f('a), 'a) => Process.Pid.t;

/**
  Marks a [pid] to be terminated by the end of the current execution

  Warning: the current execution **cannot** mark itself to continue, but may
  spawn a new process to continue it's prior work
 */
let exit: Process.Pid.t => unit;

/**
  Registers a [pid] under a given [name] in this [node]

  Multiple processes might be registered under the same [name] but only the
  first one will be retrieved when searching for it with `[where_is]`
  */
let register: (string, Process.Pid.t) => Process.Pid.t;

/**
  Looks up a process by [name] in the given [node] registry

  Name matching is done by exact matches, so make sure to use the exact same
  [name] you registered a process with

  Returns None if no process was found, or Some([Pid.t]) if some process was
  found
  */
let where_is: string => option(Process.Pid.t);

/**
  Sending messages to processes is a core functionality of [ReActor] It's the
  piece that makes different processes able to collaborate and solve problems
  together

  [send] will write the [message] to the mailbox of the specified [pid]

  Warning: There is no guarantee that the process will live long enough to
  consume the [message], or that it will consume it at all However, delivery of
  the [message] to the [pid]s mailbox is guaranteed

  Note: one limitation of working in the browser is that processes being
  executed in schedulers other than the Main Thread Scheduler **cannot** receive
  functions in their messages

  This is due to functions not being serializable by the
  {{:https://developermozillaorg/en-US/docs/Web/API/Web_Workers_API/Structured_clone_algorithm}Structured
  Clone algorithm}

 */
let send: (Process.Pid.t, Process.Message.t) => unit;

/** Operator alias for {{!send}send}

It makes sequencing messages to a particular process much cleaner From:

{[

(pid : Pid.t)
|> p => send(p, message1)
|> p => send(p, message2)
|> p => send(p, message3)

]}

We can simplify to:

{[

(pid : Pid.t) <- message1 <- message2 <- message3

]}
 */
let (<-): (Process.Pid.t, Process.Message.t) => unit;

/**
  Sets up a given [tracer] on the current node

  Tracing is very useful to inspect message passing safely In general, if your
  messages are completely immutable, this means nobody can tamper with them and
  tracing is completely safe If your messages include references, the [tracer]
  will be able to update those references unsafely

  Use with caution, since every message in every scheduler of this node will be
  preprocessed by the [tracer]
  */
let trace: Tracer.t => unit;