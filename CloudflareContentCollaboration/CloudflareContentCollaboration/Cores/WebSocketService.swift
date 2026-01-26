//
//  WebSocketService.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/24.
//

import Foundation

// MARK: - WebSocket Connection State
nonisolated extension WebSocketService {
    enum ConnectionState: Sendable {
        case disConnected
        case connecting
        case connected
    }
}

// MARK: - WebSocket Main Implementation
nonisolated class WebSocketService: NSObject, @unchecked Sendable {
    var onError: ((Error) -> Void)?
    var onMessage: ((URLSessionWebSocketTask.Message) -> Void)?
    var onConnectionStateChange: ((ConnectionState) -> Void)?

    private(set) var connectionState: ConnectionState = .disConnected {
        didSet {
            if self.connectionState != oldValue {
                self.onConnectionStateChange?(self.connectionState)
            }
        }
    }

    private var webSocketTask: URLSessionWebSocketTask?

    private let urlSession: URLSession = .shared

    private var receivingTask: Task<Void, Error>?

    deinit {
        self.webSocketTask?.cancel(with: .goingAway, reason: nil)
        self.webSocketTask = nil
        self.urlSession.finishTasksAndInvalidate()
    }

    private func handleError(_ error: Error) {
        self.disconnect()
        self.onError?(error)
    }

    // URL: has to be either `ws` or `wss` scheme
    func connect(
        url: URL,
        method: String,
        headers: [String: String],
    ) throws {

        self.cleanUp()

        var request = URLRequest(url: url)
        request.httpMethod = method

        request.allHTTPHeaderFields = headers

        self.webSocketTask = self.urlSession.webSocketTask(with: request)
        self.webSocketTask?.delegate = self
        self.webSocketTask?.resume()

        // we won't know whether if we are actually connected, ie: handshake completes,
        // until we receive the notifications through the session’s delegate
        self.connectionState = .connecting
    }

    func disconnect() {
        // set connection state before cancelling to avoid processing didCloseWith delegate function unintentionally
        self.connectionState = .disConnected
        self.cleanUp()
    }

    private func cleanUp() {
        self.stopReceivingMessages()
        self.webSocketTask?.cancel(with: .goingAway, reason: nil)
        self.webSocketTask = nil
    }

    func sendPing(pongHandler: @escaping @Sendable ((any Error)?) -> Void) {
        self.webSocketTask?.sendPing(pongReceiveHandler: pongHandler)
    }

    func send(_ string: String) async throws {
        guard let webSocketTask = self.webSocketTask else {
            throw WebSocketError.webSocketTaskUndefined
        }
        try await webSocketTask.send(.string(string))
    }

    func send(_ data: Data) async throws {
        guard let webSocketTask = self.webSocketTask else {
            throw WebSocketError.webSocketTaskUndefined
        }
        try await webSocketTask.send(.data(data))
    }

    func startReceivingMessages() throws {
        guard self.webSocketTask != nil else {
            return
        }

        self.receivingTask = Task { [weak self] in
            guard let self else { return }
            while let webSocketTask = self.webSocketTask {
                guard !Task.isCancelled else { break }
                do {
                    let message = try await webSocketTask.receive()
                    self.onMessage?(message)
                } catch (let error) {
                    // if error is isSocketNotConnectedError, we will receive the close code and reason within the delegate function, so we will ignore this error
                    if self.webSocketTask != nil {
                        self.handleError(error)
                    }
                }
            }
        }
    }

    func stopReceivingMessages() {
        self.receivingTask?.cancel()
        self.receivingTask = nil
    }
}

// MARK: - URLSessionWebSocketDelegate
nonisolated extension WebSocketService: URLSessionWebSocketDelegate {
    // Tells the delegate that the WebSocket task successfully negotiated the handshake with the endpoint, indicating the negotiated protocol.
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didOpenWithProtocol protocol: String?
    ) {

        if webSocketTask == self.webSocketTask {
            self.connectionState = .connected
        }
    }

    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: (any Error)?
    ) {
        guard let error, task == self.webSocketTask,
            self.connectionState != .disConnected
        else {
            return
        }

        // in the case of `Socket is not connected` error, we will receive more details in `didCloseWith` function below
        self.handleError(WebSocketError.connectionCompleted(error))
        return

    }

    // Tells the delegate that the WebSocket task received a close frame from the server endpoint, optionally including a close code and reason from the server.
    nonisolated func urlSession(
        _ session: URLSession,
        webSocketTask: URLSessionWebSocketTask,
        didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
        reason: Data?
    ) {
        let reason =
            String(
                data: reason ?? Data("unknown".utf8),
                encoding: .utf8
            ) ?? "unknown"

        guard webSocketTask == self.webSocketTask,
            self.connectionState != .disConnected
        else {
            return
        }

        self.disconnect()

        // connection lost due to server close
        let error = WebSocketError.connectionClosed(
            code: closeCode,
            reason: reason
        )

        self.handleError(error)

    }
}
