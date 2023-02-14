const os = require('os')
 
function main(params) {
    const name = params && params.name || 'anonymous'
    const hostname = os.hostname()
    const message = `Hello ${name} from ${hostname}`
    const body = JSON.stringify({
        name,
        hostname,
        message
    })
    const response = {
        statusCode: 200,
        headers: { 'Content-Type': 'application/json' },
        body
    }
    return response
}