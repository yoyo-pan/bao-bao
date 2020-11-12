import React, { useCallback } from 'react'
import { useQuery, useMutation } from 'relay-hooks'
import { useHistory, generatePath } from 'react-router-dom'
import { graphql } from 'babel-plugin-relay/macro'
import { Box, Button, makeStyles } from '@material-ui/core'

import routes from '../app/routes'
import { ROOM_JOIN_MUTATION, ROOM_CREATE_MUTATION } from '../queries/room'
import { LobbyQuery } from '../__generated__/LobbyQuery.graphql'
import { roomJoinMutation } from '../__generated__/roomJoinMutation.graphql'
import { roomCreateMutation } from '../__generated__/roomCreateMutation.graphql'

import RoomCard from './RoomCard'

const useStyles = makeStyles({
  box: {
    '& button': {
      'margin-left': '10px',
    },
  },
})

const query = graphql`
  query LobbyQuery {
    rooms {
      id
      ...RoomCard_room
    }
  }
`

export default function Lobby() {
  const history = useHistory()
  const { props, retry } = useQuery<LobbyQuery>(query, undefined, { fetchPolicy: 'store-and-network' })
  const classes = useStyles()
  const [joinRoom] = useMutation<roomJoinMutation>(ROOM_JOIN_MUTATION)
  const [createRoom] = useMutation<roomCreateMutation>(ROOM_CREATE_MUTATION)

  const onJoinRoom = useCallback(
    (roomId: number) => {
      joinRoom({
        variables: {
          roomId,
        },
        onCompleted: () => {
          history.push(generatePath(routes.Room, { id: roomId }))
        },
      })
    },
    [history, joinRoom],
  )

  const onCreateRoom = useCallback(() => {
    createRoom({
      variables: {},
      onCompleted: resp => {
        if (!resp.createRoom.successful) {
          window.alert('Create room GG')
          return
        }
        history.push(generatePath(routes.Room, { id: resp.createRoom.result?.idNumber }))
      },
    })
  }, [history, createRoom])

  if (!props) return <div>Loading</div>

  return (
    <>
      <Box className={classes.box}>
        <Button variant="contained" color="primary" onClick={onCreateRoom}>
          Create Room
        </Button>
        <Button
          variant="contained"
          color="secondary"
          onClick={() => {
            retry()
          }}
        >
          Reload
        </Button>
      </Box>
      {props.rooms.map(room => (
        <RoomCard
          key={room.id}
          room={room}
          onJoinRoom={onJoinRoom}
        />
      ))}
    </>
  )
}
