## Pipeline scalability protocol for passing tasks through a series of processing steps

Fair queues messages from the previous processing step and load balances them among instances of the next processing step.

- `PushSocket()` : This socket is used to send messages to a cluster of load-balanced nodes. Receive operation is not implemented on this socket type.
- `PullSocket()` : This socket is used to receive a message from a cluster of nodes. Send operation is not implemented on this socket type.


## Pair family one-to-one scalability protocol

Pair protocol is the simplest and least scalable scalability protocol. It allows scaling by breaking the application in exactly two pieces. For example, if a monolithic application handles both accounting and agenda of HR department, it can be split into two applications (accounting vs. HR) that are run on two separate servers. These applications can then communicate via PAIR sockets.

The downside of this protocol is that its scaling properties are very limited. Splitting the application into two pieces allows to scale the two servers. To add the third server to the cluster, the application has to be split once more, say by separating HR functionality into hiring module and salary computation module. Whenever possible, try to use one of the more scalable protocols instead.

- `PairSocket()` : Socket for communication with exactly one peer. Each party can send messages at any time. If the peer is not available or send buffer is full subsequent calls to sendMessage() will block until it’s possible to send the message.


## Request/Repley family scalability protocol

This protocol is used to distribute the workload among multiple stateless workers.

Please note that request/reply applications should be stateless.

It’s important to include all the information necessary to process the request in the request itself, including information about the sender or the originator of the request if this is necessary to respond to the request.

Sender information cannot be retrieved from the underlying socket connection since, firstly, transports like IPC may not have a firm notion of a message origin. Secondly, transports that have some notion may not have a reliable one — a TCP disconnect may mean a new sender, or it may mean a temporary loss in network connectivity.

For this reason, sender information must be included by the application if required. Allocating 6 randomly-generated bytes in the message for the lifetime of the connection is sufficient for most purposes. For longer-lived applications, an UUID is more suitable.

- `RequestSocket()` : Used to implement the client application that sends requests and receives replies.
- `ReplySocket()`   : Used to implement the stateless worker that receives requests and sends replies.


## Publisher/Sunscriber family scalability protocol

Broadcasts messages to multiple destinations.

Messages are sent from Publisher sockets and will only be received by Subscriber sockets that have subscribed to the matching topic. Topic is an arbitrary sequence of bytes at the beginning of the message body. The Subscriber socket will determine whether a message should be delivered to the user by comparing the subscribed topics to the incoming message.

- `PublisherSocket()`  : This socket is used to distribute messages to multiple destinations. Receive operation is not defined.
- `SubscriberSocket()` : Receives messages from the publisher. Only messages that the socket is subscribed to are received. When the socket is created there are no subscriptions and thus no messages will be received. Send operation is not defined on this socket.


## Survey scalability protocol

Allows to broadcast a survey to multiple locations and gather the responses.

- `SurveyorSocket()`   : Used to send the survey. The survey is delivered to all the connected respondents. Once the query is sent, the socket can be used to receive the responses. When the survey deadline expires, receive will return timeout error.
- `RespondentSocket()` : Use to respond to the survey. Survey is received using receive function, response is sent using send function. This socket can be connected to at most one peer.


## Message bus scalability protocol

Broadcasts messages from any node to all other nodes in the topology. The socket should never receive messages that it sent itself.

This pattern scales only to local level (within a single machine or within a single LAN). Trying to scale it further can result in overloading individual nodes with messages.

> ***Warning*** - For bus topology to function correctly, user is responsible for ensuring that path from each node to any other node exists within the topology.

A Raw Socket Domain BUS socket never sends the message to the peer it was received from.

- `BusSocket()` : Sent messages are distributed to all nodes in the topology. Incoming messages from all other nodes in the topology are fair-queued in the socket.