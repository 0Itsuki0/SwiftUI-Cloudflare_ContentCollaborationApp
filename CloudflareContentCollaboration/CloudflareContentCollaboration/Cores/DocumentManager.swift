//
//  DocumentManager.swift
//  CloudflareContentCollaboration
//
//  Created by Itsuki on 2026/01/24.
//

import SwiftUI
import YSwift
import Yniffi

@Observable
class DocumentManager {
    var currentContent: String? {
        return yText?.getString()
    }
    private(set) var collaborators: Set<String> = []

    private var yText: YText?
    private(set) var documentId: String? {
        didSet {
            if let documentId = documentId {
                self.yText = self.yDocument.getOrCreateText(named: documentId)
            } else {
                self.yText = nil
            }
        }
    }
    private(set) var wsConnectionState: WebSocketService.ConnectionState =
        .disConnected

    var error: Error? {
        didSet {
            if let error {
                print(error)
            }
        }
    }

    private let yDocument = YDocument()

    private let websocketService = WebSocketService()

    let userID = UUID().uuidString

    let contentUpdates: AsyncStream<String>
    private let contentUpdatesContinuation: AsyncStream<String>.Continuation

    init() {
        (self.contentUpdates, self.contentUpdatesContinuation) =
            AsyncStream.makeStream(of: String.self)

        websocketService.onError = { [weak self] in
            guard let self else { return }
            guard self.documentId != nil else { return }
            self.error = $0
        }
        websocketService.onMessage = { [weak self] in
            guard let self else { return }
            guard self.documentId != nil else { return }
            handleWebsocketMessage($0)
        }

        websocketService.onConnectionStateChange = { [weak self] in
            guard let self else { return }
            guard self.documentId != nil else { return }
            self.wsConnectionState = $0
        }
    }

    // if id exist, ie: someone else working on it, then open the existing document
    // if not, creating a new one
    func openOrCreateDocument(_ documentId: String) async {
        do {
            guard
                let url = URL(
                    string:
                        "\(ServerConfig.url)?doc_id=\(documentId)&user_id=\(userID)"
                )
            else {
                throw NetworkError.failToCreateURL
            }
            try self.websocketService.connect(
                url: url,
                method: ServerConfig.method,
                headers: ServerConfig.headers
            )

            try self.websocketService.startReceivingMessages()

            // not using subscription to update _content
            // because local difference is calculated based on the current _content and
            // we want to make sure that those changes are applied in order using the applyDocumentUpdate(_ newContent: String) function
            // in the swift SDK, there isn't a way for us to check wether the change event is local or not
            //
            // self.subscription = self.yText?.observe({ changes in
            //     self.processChangeEvents(changes)
            // })

            self.documentId = documentId
        } catch (let error) {
            self.error = error
        }
    }

    func closeDocument() {
        self.documentId = nil
        self.websocketService.disconnect()
    }

    // local update
    func applyDocumentUpdate(old: String, new: String) {
        guard let yText else {
            return
        }

        let differences = new.difference(from: old)
        Task {
            // trying to return transaction here and call transactionEncodeStateAsUpdate outside closure will cause the app to crash
            let updates = await self.yDocument.transact { transaction in
                for difference in differences {
                    switch difference {
                    case .insert(let offset, let element, associatedWith: _):
                        yText.insert(
                            String(element),
                            at: UInt32(offset),
                            in: transaction
                        )
                    case .remove(let offset, element: _, associatedWith: _):
                        yText.removeRange(
                            start: UInt32(offset),
                            length: 1,
                            in: transaction
                        )
                    }
                }
                self.contentUpdatesContinuation.yield(
                    yText.getString(in: transaction)
                )
                return transaction.transactionEncodeStateAsUpdate()
            }

            self.sendUpdates(updates)

        }
    }

    private func handleWebsocketMessage(
        _ message: URLSessionWebSocketTask.Message
    ) {
        guard let messageData = message.data else {
            return
        }
        guard self.wsConnectionState != .disConnected else {
            return
        }
        guard self.documentId != nil else {
            return
        }
        let websocketMessage: WebsocketMessage
        do {
            websocketMessage = try JSONDecoder().decode(
                WebsocketMessage.self,
                from: messageData
            )
        } catch (let error) {
            self.error = error
            return
        }

        switch websocketMessage {
        case .userEvent(let event):
            event.type == .join
                ? self.addCollaborator(event.userId)
                : self.removeCollaborator(event.userId)
        case .connectionInit(let event):
            self.applyDocumentUpdate(event.content)
            event.collaborators.forEach(self.addCollaborator(_:))
        case .docUpdate(let event):
            self.addCollaborator(event.userId)
            self.applyDocumentUpdate(event.data)
        }
    }

    // remote updates
    private func applyDocumentUpdate(_ update: [UInt8]) {
        guard let yText else {
            return
        }
        Task {
            await self.yDocument.transact { transaction in
                do {
                    try transaction.transactionApplyUpdate(update: update)
                    self.contentUpdatesContinuation.yield(
                        yText.getString(in: transaction)
                    )
                } catch (let error) {
                    self.error = error
                }
            }
        }
    }

    // send updates to websocket server to notify other collaborators
    private func sendUpdates(_ updates: [UInt8]) {
        guard self.wsConnectionState == .connected else {
            return
        }
        Task.detached(operation: { [weak self] in
            guard let self else {
                return
            }
            do {
                let updateEvent = DocumentUpdateEvent(
                    type: .update,
                    data: updates,
                    userId: self.userID
                )
                try await websocketService.send(
                    try JSONEncoder().encode(updateEvent)
                )
            } catch (let error) {
                Task { @MainActor in
                    self.error = error
                }
            }
        })
    }

    private func addCollaborator(_ userId: String) {
        self.collaborators.insert(userId)
    }

    private func removeCollaborator(_ userId: String) {
        self.collaborators.remove(userId)
    }

}
