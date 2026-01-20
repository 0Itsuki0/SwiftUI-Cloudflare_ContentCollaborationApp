// deno-lint-ignore-file
import express, { Request, Response } from "express"
import { jwt } from "twilio"
import { configDotenv } from "dotenv"

configDotenv()

const AccessToken = jwt.AccessToken
const VideoGrant = AccessToken.VideoGrant

const twilioAccountSid = process.env.TWILIO_ACCOUNT_SID ?? ""
const twilioApiKey = process.env.TWILIO_API_KEY_SID ?? ""
const twilioApiSecret = process.env.TWILIO_API_KEY_SECRET ?? ""

const MAX_ALLOWED_SESSION_DURATION = 14400

const app = express()
const PORT = 8080

app.use(express.json({}))

app.get("/token", async (req: Request, res: Response) => {
    const { identity } = req.query
    if (typeof identity !== "string") {
        res.status(500).send({
            error: true,
            message: `Bad query parameter`,
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
            identity: identity,
        },
    )

    // Grant the access token Twilio Video capabilities.
    const grant = new VideoGrant()
    token.addGrant(grant)

    // Serialize the token to a JWT string.
    res.status(200).send({
        error: false,
        token: token.toJwt(),
    })
    return
})

app.listen(PORT, () => {
    console.log(`Server started at http://localhost:${PORT}`)
})
