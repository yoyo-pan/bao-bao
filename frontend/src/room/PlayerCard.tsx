import React from 'react'
import { useFragment } from 'relay-hooks'
import { graphql } from 'babel-plugin-relay/macro'
import { Paper, makeStyles, Box, Icon } from '@material-ui/core'

import { PlayerCard_player$key } from '../__generated__/PlayerCard_player.graphql'

const useStyles = makeStyles({
  card: {
    backgroundColor: '#4EBDFF',
    borderRadius: 10,
    height: 120,
    position: 'relative',
    '& .kick-btn': {
      position: 'absolute',
      right: 5,
      top: 5,
    },
  },
  footer: {
    backgroundColor: '#3473D0',
    color: '#FFFFFF',
    marginTop: 5,
    padding: 1,
    textAlign: 'center',
    '& .role': {
      backgroundColor: '#13325E',
      borderRadius: 5,
      color: '#4EBDFF',
      margin: '0 auto',
    },
  },
})

export enum Role {
  host = 'Host',
  player = 'Player',
}

interface Props {
  player: PlayerCard_player$key
  isHost: boolean
  isKickable: boolean
  onKick: (id: string) => void
}

const fragmentSpec = graphql`
  fragment PlayerCard_player on RoomPlayer {
    user {
      id
      nickname
    }
    isReady
  }
`

export default function PlayerCard(props: Props) {
  const { isHost, isKickable, onKick } = props
  const { user, isReady } = useFragment(fragmentSpec, props.player)
  const classes = useStyles()

  return (
    <>
      <Paper className={classes.card} elevation={20}>
        {isKickable && (
          <Icon className="kick-btn" onClick={() => onKick(user.id)}>
            clear
          </Icon>
        )}
      </Paper>
      <Paper className={classes.footer} elevation={20}>
        <Box>{user.nickname}</Box>
        {!isHost && (
          <Box className="role">
            {isReady ? 'READY' : 'WAITING'}
          </Box>
        )}
      </Paper>
    </>
  )
}
