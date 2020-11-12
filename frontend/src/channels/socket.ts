import { Socket } from 'phoenix'

const SOCKET_ENDPOINT = process.env.REACT_APP_SOCKET_ENDPOINT!

let socket: Socket

export default {
  connect: () => {
    const token = localStorage.getItem('token')
    socket = new Socket(SOCKET_ENDPOINT, { params: { token } })
    socket.connect()

    return socket
  },
  channel: (channel: string, params: object = {}) => {
    return socket.channel(channel, params)
  }
}
