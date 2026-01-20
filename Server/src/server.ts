import express, { Request, Response } from "express"
import { jwt } from "twilio"
import { configDotenv } from "dotenv"
import { z } from "zod"

configDotenv()

export const AccessTokenRequest = z.looseObject({
  identity: z.string(),
  roomName: z.string(),
})
export type AccessTokenRequest = z.infer<typeof AccessTokenRequest>

const AccessToken = jwt.AccessToken
const VideoGrant = AccessToken.VideoGrant

const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID ?? ""
const twilioApiKey = process.env.TWILIO_API_KEY_SID ?? ""
const twilioApiSecret = process.env.TWILIO_API_KEY_SECRET ?? ""

// 4 hours
// Matches the [Room Options setting](https://www.twilio.com/console/video/configure)
const MAX_ALLOWED_SESSION_DURATION = 14400

const app = express()
const PORT = 8080

app.use(express.json({}))

app.post("/token", async (req: Request, res: Response) => {
  const body = req.body
  console.log(body)
  let tokenRequst: AccessTokenRequest
  try {
    tokenRequst = AccessTokenRequest.parse(req.body)
  } catch (error) {
    res.status(500).send({
      error: true,
      message: `${error}`,
    })
    return
  }

  // Create an access token which we will sign and return to the client,
  // containing the grant we just created.
  const token = new AccessToken(
    twilioAccountSid,
    twilioApiKey,
    twilioApiSecret,
    {
      ttl: MAX_ALLOWED_SESSION_DURATION,
      // The identity of the first person. Required.
      identity: tokenRequst.identity,
    },
  )

  // Grant the access token Twilio Video capabilities.
  const room = tokenRequst.roomName
  // You can also encode the Room name in the Access Token,
  // which will let the user connect to only the Room specified in the token.
  const grant = new VideoGrant({
    room: room,
  })
  token.addGrant(grant)

  // Serialize the token to a JWT string.
  res.status(200).send({
    error: false,
    token: token.toJwt(),
    roomName: room,
  })
  return
})

app.listen(PORT, () => {
  console.log(`Server started at http://localhost:${PORT}`)
})
