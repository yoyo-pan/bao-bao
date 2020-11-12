import React, { FC, useCallback, useMemo } from 'react'
import { useHistory } from 'react-router-dom'
import { Box, Button, Grid, makeStyles } from '@material-ui/core'

import routes from '../app/routes'

import { GameOverData, PlayerSummary, PlayerSummaryRecord } from './types'

interface Props {
  readonly gameOverData: GameOverData
}

interface ExtendedPlayerSummary extends PlayerSummary {
  readonly isWinner: boolean
}

interface DisplayData {
  readonly isDraw: boolean
  readonly players: ReadonlyArray<ExtendedPlayerSummary>
}

const useStyles = makeStyles({
  root: {
    boxSizing: 'border-box',
    position: 'absolute',
    left: 0,
    top: 0,
    width: '100%',
    height: '100%',
    color: '#FFFFFF',
    backgroundColor: 'rgba(0, 0, 0, 0.8)',
    padding: 20,
  },
  rootGrid: {
    height: '100%',
  },
  title: {
    fontSize: 24,
    textAlign: 'center',
  },
  row: {
    borderBottom: '1px #999999 solid',
    padding: 10,
  },
})

const GameResult: FC<Props> = ({ gameOverData }) => {
  const classes = useStyles()
  const history = useHistory()

  const displayData = useMemo<DisplayData>(() => {
    const { winners, losers } = gameOverData
    const record: PlayerSummaryRecord = {
      ...winners,
      ...losers,
    }
    return {
      isDraw: Object.keys(winners).length === 0,
      players: Object.keys(record)
        .sort()
        .map((id): ExtendedPlayerSummary => ({
          ...record[id]!,
          isWinner: !!winners[id],
        })),
    }
  }, [gameOverData])

  const onOK = useCallback(() => {
    history.push(routes.Lobby)
  }, [history])

  return (
    <div className={classes.root}>
      <Grid className={classes.rootGrid} container direction='column' spacing={4} wrap='nowrap'>
        <Grid className={classes.title} item>
          {displayData.isDraw ? 'Draw' : 'Game Over'}
        </Grid>
        <Grid item xs={12}>
          <Box display='flex' flexDirection='column'>
            {displayData.players.map((data, i) => (
              <Box key={i} className={classes.row} display='flex' justifyContent='space-between'>
                <span>{data.nickname}</span>
                <span>{data.isWinner ? 'Winner' : ''}</span>
                <span>{data.wins}-{data.losses}-{data.draws}</span>
              </Box>
            ))}
          </Box>
        </Grid>
        <Grid item>
          <Box display='flex' justifyContent='center'>
            <Button variant='contained' color='primary' onClick={onOK}>
              OK
            </Button>
          </Box>
        </Grid>
      </Grid>
    </div>
  )
}

export default GameResult
