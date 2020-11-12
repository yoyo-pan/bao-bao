import React, { useCallback } from 'react'
import { useFragment } from 'relay-hooks'
import { graphql } from 'babel-plugin-relay/macro'
import { Card, CardHeader, CardContent, makeStyles } from '@material-ui/core'

import { RoomCard_room$key } from '../__generated__/RoomCard_room.graphql'

const useStyles = makeStyles({
  card: {
    display: 'inline-block',
    width: 230,
    height: 250,
    border: 'solid 1px #bbbbbb',
    margin: '10px',
    position: 'relative',
    '& .host-info': {
      'font-size': '0.5em',
    },
    '& .content': {
      fontSize: 12,
    },
  },
})

const fragmentSpec = graphql`
  fragment RoomCard_room on Room {
    id
    idNumber
    host {
      id
      nickname
    }
    players {
      id
      user {
        id
        nickname
      }
    }
  }
`

interface Props {
  room: RoomCard_room$key
  onJoinRoom: (roomId: number) => void
}

export default function RoomCard(props: Props) {
  const { onJoinRoom } = props
  const room = useFragment(fragmentSpec, props.room)
  const classes = useStyles()

  const onEnterRoom = useCallback(() => {
    onJoinRoom(room.idNumber)
  }, [room.idNumber, onJoinRoom])

  return (
    <Card className={classes.card} onClick={onEnterRoom}>
      <CardHeader
        title={
          <>
            <div>{room.id}</div>
            {room.host && (
              <span className="host-info">
                host: {room.host.nickname} ({room.host.id})
              </span>
            )}
          </>
        }
      />
      <CardContent className="content">
        <div>players:</div>
        {room.players.map(player => {
          if (!player) return ''
          return (
            <div key={player.id}>
              - {player.user.nickname} ({player.user.id})
            </div>
          )
        })}
      </CardContent>
    </Card>
  )
}
