import React, { useEffect, useCallback, useMemo, useState } from 'react'
import { useParams, useHistory, generatePath } from 'react-router-dom'
import { useQuery, useMutation, useSubscription } from 'relay-hooks'
import { graphql } from 'babel-plugin-relay/macro'
import { Grid, makeStyles, Button, Box } from '@material-ui/core'

import routes from '../app/routes'
import { RoomQuery } from '../__generated__/RoomQuery.graphql'
import { roomLeaveMutation } from '../__generated__/roomLeaveMutation.graphql'
import { roomKickMutation } from '../__generated__/roomKickMutation.graphql'
import {
  roomUpdatedSubscription,
  roomUpdatedSubscriptionResponse,
} from '../__generated__/roomUpdatedSubscription.graphql'
import { roomReadyMutation } from '../__generated__/roomReadyMutation.graphql'
import { roomUnreadyMutation } from '../__generated__/roomUnreadyMutation.graphql'
import { Chat } from '../app/types'
import Chatbox from '../app/components/Chatbox'
import gameChannel from '../channels/game'
import lobbyChannel from '../channels/lobby'
import {
  ROOM_LEAVE_MUTATION,
  ROOM_KICK_MUTATION,
  ROOM_UPDATED_SUBSCRIPTION,
  ROOM_READY_MUTATION,
  ROOM_UNREADY_MUTATION,
} from '../queries/room'

import PlayerCard from './PlayerCard'

const useStyles = makeStyles({
  root: {
    backgroundColor: '#4EC3F3',
    padding: 10,
    width: 600,
  },
  container: {
    backgroundColor: '#214996',
    borderRadius: 5,
  },
  chatbox: {
    width: '600px',
    marginTop: '36px',
  },
})

export const query = graphql`
  query RoomQuery($id: Int!) {
    viewer {
      userId
    }
    room(id: $id) {
      host {
        id
      }
      players {
        id
        user {
          id
        }
        isReady
        ...PlayerCard_player
      }
    }
  }
`

export default function Room() {
  const history = useHistory()
  const classes = useStyles()
  const { id } = useParams()
  const { props } = useQuery<RoomQuery>(query, { id: parseInt(id, 10) }, { fetchPolicy: 'network-only' })

  const [leaveRoom] = useMutation<roomLeaveMutation>(ROOM_LEAVE_MUTATION)
  const [kickPlayer] = useMutation<roomKickMutation>(ROOM_KICK_MUTATION)
  const [ready] = useMutation<roomReadyMutation>(ROOM_READY_MUTATION)
  const [unready] = useMutation<roomUnreadyMutation>(ROOM_UNREADY_MUTATION)
  const [chatHistory, setChatHistory] = useState<Chat[]>([])
  const subscriptionConfig = useMemo(
    () => ({
      subscription: ROOM_UPDATED_SUBSCRIPTION,
      variables: {},
      onNext: (_result: any) => {
        const { roomUpdated } = _result as roomUpdatedSubscriptionResponse
        console.log('Receive roomUpdated: ', roomUpdated)

        const hasViewer = roomUpdated.players.some(({ user }) => user.id === props?.viewer?.userId)

        if (!hasViewer) {
          history.replace(routes.Lobby)
        }
      },
      onError: (e: any) => {
        console.log('Error', e)
      },
    }),
    [history, props],
  )
  useSubscription<roomUpdatedSubscription>(subscriptionConfig)

  const imReady = useMemo(
    () => props?.room.players.find(item => item.user.id === props?.viewer?.userId)?.isReady || false,
    [props],
  )

  const allPlayersReady = useMemo(
    () => !props?.room.players
      .filter(item => item.user.id !== props.room.host?.id)
      .some(item => !item.isReady),
    [props],
  )

  const onReadyClick = useCallback(() => {
    if (imReady) {
      unready({
        variables: {},
      })
    } else {
      ready({
        variables: {},
      })
    }
  }, [imReady, ready, unready])

  useEffect(() => {
    gameChannel.join(id)
    gameChannel.onGameStart(() => history.push(generatePath(routes.Game, { id })))

    lobbyChannel.join()
    const ref = lobbyChannel.onMessage(({ from, body }: any) => {
      setChatHistory(prev => [
        ...prev,
        {
          name: from,
          message: body,
          receivedAt: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        },
      ])
    })

    return () => {
      lobbyChannel.offMessage(ref)
    }
  }, [history, id])

  const onStart = useCallback(() => {
    gameChannel.start()
  }, [])

  const onLeaveRoom = useCallback(() => {
    leaveRoom({
      variables: {},
      onCompleted: () => {
        history.replace(routes.Lobby)
      },
    })
  }, [history, leaveRoom])

  const onKick = useCallback(
    (userId: string) => {
      kickPlayer({
        variables: { userId },
      })
    },
    [kickPlayer],
  )

  if (!props || !props.viewer || !props.room.host) {
    return <div>Loading...</div>
  }

  const reversedPlayers = props.room.players.slice().reverse()
  const onMessageSend = (message: String) => lobbyChannel.sendMessage(message)
  const isHost = props.viewer.userId === props.room.host.id

  return (
    <>
      <section className={classes.root}>
        <Grid container className={classes.container} spacing={1}>
          {reversedPlayers.map(player => (
            <Grid key={player.id} item xs={3}>
              <PlayerCard
                player={player}
                isHost={player.user.id === props?.room.host?.id}
                isKickable={isHost && player.id !== props?.viewer?.userId}
                onKick={onKick}
              />
            </Grid>
          ))}
        </Grid>
        <div className={classes.chatbox}>
          <Chatbox chatHistory={chatHistory} onMessageSend={onMessageSend} />
        </div>
        <Box textAlign="center" mt={10}>
          {isHost && (
            <Button variant="outlined" onClick={onStart} disabled={!allPlayersReady}>
              Start
            </Button>
          )}
          {!isHost && (
            <Button variant="outlined" onClick={onReadyClick}>
              {imReady ? 'Cancel' : 'Ready'}
            </Button>
          )}
          <Button variant="outlined" onClick={onLeaveRoom}>
            Leave
          </Button>
        </Box>
      </section>
    </>
  )
}
