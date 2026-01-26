import { DurableObject } from "cloudflare:workers"
import * as Y from "yjs"
import { z } from "zod"

export const DocumentUpdate = z.object({
  type: z.literal("update"),
  data: z.array(z.int()),
  userId: z.string(),
})
export type DocumentUpdate = z.infer<typeof DocumentUpdate>

// One durable object = One document
export class CollaborationDocument extends DurableObject<Env> {
  private readonly connections: Map<WebSocket, { userId: string }>
  private readonly yDoc = new Y.Doc()
  private readonly sql: SqlStorage

  constructor(ctx: DurableObjectState, env: Env) {
    super(ctx, env)
    this.sql = ctx.storage.sql
    this.createTableIfNeeded()
    this.connections = new Map()

    const docName = ctx.id.name || "default"
    // load document from DB asynchronously
    this.ctx.blockConcurrencyWhile(async () => {
      await this.loadDoc(docName)
    })

    // store the doc to DB every time there is an update
    this.yDoc.on("update", async (updates) => {
      await this.storeDoc(docName, updates)
    })

    // Get all WebSocket connections from the DO
    this.ctx.getWebSockets().forEach((ws) => {
      let attachment = ws.deserializeAttachment()
      if (attachment) {
        // If we previously attached state to our WebSocket,
        // let's add it to `sessions` map to restore the state of the connection.
        this.connections.set(ws, { ...attachment })
      }
    })

    // setHibernatableWebSocketEventTimeout allows a Durable Object to be removed from memory to save costs while keeping its WebSockets connected.
    // set it to be 10 minutes here
    this.ctx.setHibernatableWebSocketEventTimeout(10 * 60 * 1000)

    // Sets an application level auto response that does not wake hibernated WebSockets.
    this.ctx.setWebSocketAutoResponse(new WebSocketRequestResponsePair("ping", "pong"))
  }

  async fetch(request: Request): Promise<Response> {
    const url = new URL(request.url)
    const userId = url.searchParams.get("user_id") || crypto.randomUUID()

    // WebSocket Upgrade
    const webSocketPair = new WebSocketPair()
    const [client, server] = Object.values(webSocketPair)

    // Calling `acceptWebSocket()` informs the runtime that this WebSocket is to begin terminating
    // request within the Durable Object. It has the effect of "accepting" the connection,
    // and allowing the WebSocket to send and receive messages.
    //
    // Unlike `ws.accept()`, `this.ctx.acceptWebSocket(ws)` informs the Workers Runtime that the WebSocket
    // is "hibernatable", so the runtime does not need to pin this Durable Object to memory while
    // the connection is open.
    //
    // During periods of inactivity, the Durable Object can be evicted
    // from memory, but the WebSocket connection will remain open. If at some later point the
    // WebSocket receives a message, the runtime will recreate the Durable Object
    // (run the `constructor`) and deliver the message to the appropriate handler.
    this.ctx.acceptWebSocket(server)

    // Attach the session ID to the WebSocket connection and serialize it.
    // This is necessary to restore the state of the connection when the Durable Object wakes up.
    server.serializeAttachment({ userId })

    // Add the WebSocket connection to the map of active sessions.
    this.connections.set(server, { userId })

    // When using the WebSocket Hibernation API, we cannot use addEventListener("...").
    // Instead, we must use the webSocketMessage handler within the fetch method to process incoming messages, or the connection will not respond.
    //
    // server.addEventListener("message", (event) => {
    // 	this.handleWebSocketMessage(server, event.data)
    // })

    server.send(
      JSON.stringify({
        type: "init",
        content: Array.from(Y.encodeStateAsUpdate(this.yDoc)), // send current content to the new session
        collaborators: [...this.connections.values()].map((entry) => entry.userId),
      }),
    )

    // send join event to other sessions
    this.connections.forEach((_, connectedWs) => {
      if (connectedWs !== server) {
        connectedWs.send(
          JSON.stringify({
            type: "join",
            userId: userId,
          }),
        )
      }
    })

    return new Response(null, { status: 101, webSocket: client })
  }

  // message: {type: "update", data: number[], userId: string}
  async webSocketMessage(ws: WebSocket, message: ArrayBuffer | string) {
    let jsonString: string
    if (typeof message !== "string") {
      const uint8Array = new Uint8Array(message)
      const decoder = new TextDecoder("utf-8")
      jsonString = decoder.decode(uint8Array)
    } else {
      jsonString = message
    }

    let jsonObject: any
    try {
      jsonObject = JSON.parse(jsonString)
    } catch (error) {
      console.error(error)
      return
    }

    const parseResult = DocumentUpdate.safeParse(jsonObject)
    if (parseResult.error) {
      console.error(parseResult.error)
      return
    }

    // the update will be saved to the db through the `update` listener we set up in the constructor
    const update = new Uint8Array(parseResult.data.data)
    Y.applyUpdate(this.yDoc, update)

    // Send a message to the rest of the WebSocket connections
    this.connections.forEach((_, connectedWs) => {
      if (connectedWs !== ws) {
        connectedWs.send(message)
      }
    })
  }

  async webSocketClose(ws: WebSocket, _code: number, reason: string, _wasClean: boolean) {
    this.closeSocket(ws, 1000, reason)
  }

  async webSocketError(ws: WebSocket, error: unknown) {
    this.closeSocket(ws, 1005, `error: ${error}`)
  }

  closeSocket(ws: WebSocket, code: number, reason: string) {
    const userLeaving = this.connections.get(ws)
    this.connections.delete(ws)
    ws.close(code, reason)
    // send leave event to other sessions
    if (!userLeaving) {
      return
    }
    this.connections.forEach((_, connectedWs) => {
      if (connectedWs !== ws) {
        connectedWs.send(
          JSON.stringify({
            type: "leave",
            userId: userLeaving.userId,
          }),
        )
      }
    })
  }

  private createTableIfNeeded() {
    this.sql.exec(`
		CREATE TABLE IF NOT EXISTS docs(
			name TEXT PRIMARY KEY,
			state  INTEGER[]
		);
		`)
  }

  // store Doc to database
  private async storeDoc(docName: string, _updates: Uint8Array) {
    // if storing individual updates is preferred than the full doc, use the updates array instead
    const stateArray = Array.from(Y.encodeStateAsUpdate(this.yDoc))
    console.log("Store Doc: ", docName)
    // perform some Async DB operations here...
    try {
      this.sql.exec(
        `
					INSERT INTO docs (name, state)
					values
						(?,  ?)
					ON CONFLICT(name)
					DO UPDATE SET
					state = ?;

				`,
        docName,
        stateArray,
        stateArray,
      )
    } catch (error) {
      console.error(error)
    }
  }

  // load doc from Database
  private async loadDoc(docName: string) {
    console.log("load Doc: ", docName)
    // fetch stored state resulting from Y.encodeStateAsUpdate(this.yDoc) from DB.
    try {
      const record = this.sql
        .exec(
          `
					SELECT * FROM docs WHERE name = ?;
				`,
          docName,
        )
        .toArray()
      if (record.length === 0) {
        return
      }
      if ("state" in record[0]) {
        const stateString = record[0].state?.toString()
        if (stateString) {
          const storedStateArray = stateString.split(",").map((s) => parseInt(s, 10))
          const stateAsUpdate: Uint8Array = new Uint8Array(storedStateArray)
          Y.applyUpdate(this.yDoc, new Uint8Array(stateAsUpdate))
        }
      }
    } catch (error) {
      console.error(error)
    }
  }
}

export default {
  async fetch(request: Request, env: Env, _ctx: ExecutionContext): Promise<Response> {
    const url = new URL(request.url)

    // Expect to receive a WebSocket Upgrade request.
    if (url.pathname !== "/websocket") {
      return new Response(`Supported endpoints: /websocket: Expects a WebSocket upgrade request`, {
        status: 400,
      })
    }

    const upgradeHeader = request.headers.get("Upgrade")
    if (!upgradeHeader || upgradeHeader !== "websocket") {
      return new Response("Worker expected Upgrade: websocket", {
        status: 426,
      })
    }

    if (request.method !== "GET") {
      return new Response("Worker expected GET method", {
        status: 400,
      })
    }

    if (!url.searchParams.get("user_id")) {
      return new Response("User id is required.", {
        status: 400,
      })
    }

    const docId = url.searchParams.get("doc_id")
    if (!docId) {
      return new Response("Doc id is required.", {
        status: 400,
      })
    }

    const stub = env.DOCUMENT_COLLABORATION_SERVER.getByName(docId)
    return stub.fetch(request)
  },
} satisfies ExportedHandler<Env>
