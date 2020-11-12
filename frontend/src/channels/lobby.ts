import { Channel } from 'phoenix'

import socket from './socket'

const MESSAGE_TOPIC = 'message'
const TYPING_TOPIC = 'typing'

let lobbyChannel: Channel

export default {
  join: () => {
    lobbyChannel = socket.channel('room:lobby', {})
    lobbyChannel
      .join()
      .receive('ok', () => {
        console.log('Joined to the lobby channel')
      })
      .receive('error', () => {
        console.log('Unable to join to the lobby channel')
      })
  },
  leave: () => {
    lobbyChannel.leave()
  },
  onMessage: (callback: (response: any) => void) => {
    return lobbyChannel.on(MESSAGE_TOPIC, callback)
  },
  offMessage: (ref: number) => {
    lobbyChannel.off(MESSAGE_TOPIC, ref)
  },
  sendMessage: (message: String) => {
    lobbyChannel.push(MESSAGE_TOPIC, { body: message })
  },
  onIsTyping: (callback: (response: { from: string; isTyping: boolean }) => void) => {
    return lobbyChannel.on(TYPING_TOPIC, callback)
  },
  offIsTyping: (ref: number) => {
    lobbyChannel.off(TYPING_TOPIC, ref)
  },
  sendIsTyping: (isTyping: boolean) => {
    lobbyChannel.push(TYPING_TOPIC, { isTyping })
  },
}
