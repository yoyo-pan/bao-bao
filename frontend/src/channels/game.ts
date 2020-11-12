import { Channel } from 'phoenix'

import {
  Command,
  CommandName,
  GameStateResponse,
  GameOverData,
} from '../game/types'

import socket from './socket'

const START_GAME_TOPIC = 'start_game'
const STATE_TOPIC = 'state'
const GAME_OVER_TOPIC = 'finish'
const COMMAND_TOPIC = 'cmd'
const LOADED_TOPIC = 'loaded'
const START_TIMER_TOPIC = 'start_timer'

let gameChannel: Channel

// This delay is necessary for predicted data taking effect.
const socketDelay = () => new Promise(resolve => {
  setTimeout(resolve, 40)
})

export default {
  join: (roomId: number) => {
    gameChannel = socket.channel(`game:${roomId}`, {})
    gameChannel
      .join()
      .receive('ok', () => {
        console.log('Joined to the game channel')
      })
      .receive('error', () => {
        console.log('Unable to join to the game channel')
      })
  },
  leave: () => {
    gameChannel.leave()
  },
  onGameStart: (callback: (response: any) => void) => {
    gameChannel.on(START_GAME_TOPIC, callback)
  },
  start: () => {
    gameChannel
      .push(START_GAME_TOPIC, {})
      .receive('ok', () => console.log('ok'))
      .receive('error', () => console.log('error'))
  },
  ready: () => {
    gameChannel.push(LOADED_TOPIC, {})
  },
  onAllPlayersReady: (callback: () => void) => {
    gameChannel.on(START_TIMER_TOPIC, callback)
  },
  onStateUpdate: (callback: (response: GameStateResponse) => void) => {
    gameChannel.on(STATE_TOPIC, callback)
  },
  onGameOver: (callback: (response: GameOverData) => void) => {
    gameChannel.on(GAME_OVER_TOPIC, callback)
  },
  sendCommand: <T extends CommandName>(command: Command<T>) => {
    gameChannel.push(COMMAND_TOPIC, { ...command, time: Date.now() })
    return socketDelay()
  },
}
