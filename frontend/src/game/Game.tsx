import React, { useCallback, useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import { useQuery } from 'relay-hooks'
import { graphql } from 'babel-plugin-relay/macro'
import { Avatar as AvatarIcon, Card } from '@material-ui/core'

import lobbyChannel from '../channels/lobby'
import gameChannel from '../channels/game'
import { GameQuery } from '../__generated__/GameQuery.graphql'

import { CommandName, Direction, GameState, GameOverData } from './types'
import Map from './Map'
import useStyle from './style'
import Chatbox from '../app/components/Chatbox'
import { Chat } from '../app/types'

const DEFAULT_GAME_STATE: GameState = {
  bombs: [],
  players: {},
  objects: [],
}

const GAME_QUERY = graphql`
  query GameQuery($id: Int!) {
    viewer {
      userId
    }
    room(id: $id) {
      players {
        id
        user {
          id
          nickname
        }
      }
    }
    map(id: $id) {
      name
      width
      height
      tiles
      objects {
        objectId
        x
        y
      }
    }
  }
`

export default function Game() {
  const { id } = useParams()
  const { props } = useQuery<GameQuery>(GAME_QUERY, { id: parseInt(id, 10) })
  const classes = useStyle()
  const [gameState, setGameState] = useState<GameState>(DEFAULT_GAME_STATE)
  const [gameOverData, setGameOverData] = useState<GameOverData | null>(null)
  const [allPlayersReady, setAllPlayersReady] = useState<boolean>(false)
  const [chatHistory, setChatHistory] = useState<Chat[]>([])
  const [typingStatus, setTypingStatus] = useState<{ [userId: string]: boolean }>({})

  const onMove = useCallback(async (direction: Direction) => {
    await gameChannel.sendCommand({
      name: CommandName.KeyDown,
      payload: direction,
    })
    await gameChannel.sendCommand({
      name: CommandName.KeyUp,
      payload: direction,
    })
  }, [])

  const onPutBomb = useCallback(async () => {
    await gameChannel.sendCommand({
      name: CommandName.PlaceBomb,
      payload: null,
    })
  }, [])

  const onReady = useCallback(() => {
    gameChannel.ready()
  }, [])

  const onMessageSend = (message: String) => lobbyChannel.sendMessage(message)

  useEffect(() => {
    gameChannel.onStateUpdate(state => {
      setGameState(state.state)
    })
    gameChannel.onGameOver(record => {
      setGameOverData(record)
    })
    gameChannel.onAllPlayersReady(() => {
      setAllPlayersReady(true)
    })
    const refMessage = lobbyChannel.onMessage(({ from, body }: any) => {
      setChatHistory(prev => [
        ...prev,
        {
          name: from,
          message: body,
          receivedAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
      ])
    })
    const refTyping = lobbyChannel.onIsTyping(({ from, isTyping }) => {
      setTypingStatus(prev => ({ ...prev, [from]: isTyping }))
    })

    return () => {
      lobbyChannel.offMessage(refMessage)
      lobbyChannel.offIsTyping(refTyping)
      gameChannel.leave()
      lobbyChannel.leave()
    }
  }, [])

  if (!props || !props.viewer || !props.room) {
    return <div>Loading...</div>
  }

  return (
    <>
      <div className={classes.mapArea}>
        <Map
          userId={props.viewer.userId}
          gameState={gameState}
          gameOverData={gameOverData}
          allPlayersReady={allPlayersReady}
          onReady={onReady}
          onMove={onMove}
          onPutBomb={onPutBomb}
          {...props}
        />
      </div>
      <div className={classes.avatarArea}>
        {props.room.players
          .slice()
          .reverse()
          .map(player => {
            const isMe = player.user.id === props.viewer!.userId
            const isAlive = gameState?.players[player.user.id]?.isAlive
            let className: string = 'avatarIcon'
            if (isMe) {
              className += ' me'
            }
            if (!isAlive) {
              className += ' dead'
            }
            return (
              <Card key={player.id} className={classes.avatarCard}>
                <AvatarIcon className={className}>{player.user.nickname?.charAt(0).toUpperCase()}</AvatarIcon>
                {typingStatus[player.user.id] ? <p>...</p> : null}
              </Card>
            )
          })}
      </div>
      <div className={classes.chatArea}>
        <Chatbox
          isInGame={true}
          chatHistory={chatHistory}
          onMessageSend={onMessageSend}
          onTypingStatusChange={lobbyChannel.sendIsTyping}
        />
      </div>
    </>
  )
}
