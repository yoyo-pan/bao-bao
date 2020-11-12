import React, { FC, useEffect, useState, useRef } from 'react'
import { Box, makeStyles } from '@material-ui/core'

interface Props {
  readonly allPlayersReady: boolean
  readonly onComplete: (complete: true) => void
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
    backgroundColor: 'rgba(0, 0, 0, 0.4)',
    padding: 20,
    fontSize: 48,
  },
  countdownNumber: {
    fontSize: 80,
  },
})

const InitialCountDown: FC<Props> = props => {
  const { allPlayersReady, onComplete } = props
  const classes = useStyles()

  const [countdown, setCountdown] = useState<number>(3)
  const countdownRef = useRef<number>(3)

  useEffect(() => {
    if (allPlayersReady) {
      const id = window.setInterval(() => {
        const value = countdownRef.current - 1
        setCountdown(value)
        countdownRef.current = value
        if (value <= 0) {
          onComplete(true)
        }
      }, 1000)
      return () => window.clearInterval(id)
    }
  }, [allPlayersReady, onComplete])

  return (
    <Box
      className={classes.root}
      display='flex'
      justifyContent='center'
      alignItems='center'
    >
      {allPlayersReady && (
        <span className={classes.countdownNumber}>
          {countdown}
        </span>
      )}
      {!allPlayersReady && 'Loading'}
    </Box>
  )
}

export default InitialCountDown
