import React, { useCallback, useEffect, useMemo, useState, useRef } from 'react'
import { Stage } from '@inlet/react-pixi'
import { makeStyles } from '@material-ui/core'

import { GameQueryResponse } from '../__generated__/GameQuery.graphql'
import { Size } from '../app/types'
import { Characters, Tints, Maps } from '../app/constants'
import XYRecord from '../app/XYRecord'

import TextureLoader from './TextureLoader'
import Background from './Background'
import Obstacles from './Obstacles'
import Character from './Character'
import Bombs from './Bombs'
import GameResult from './GameResult'
import InitialCountdown from './InitialCountdown'

import {
  Bomb as BombProps,
  Direction,
  Player as CharacterStatus,
  GameState,
  GameOverData,
  GameStateObstacle,
  CanExplodeType,
} from './types'

interface Props extends GameQueryResponse {
  readonly userId: string
  readonly gameState: GameState
  readonly gameOverData: GameOverData | null
  readonly allPlayersReady: boolean
  readonly onReady: () => void
  readonly onMove: (direction: Direction) => Promise<void>
  readonly onPutBomb: () => Promise<void>
}

// playerTint[userId] -> color
type PlayerTint = Partial<Record<string, number>>

// 'PredictedData' is used to store the predicted
// game state until server response.
interface PredictedData {
  readonly playerStatus?: CharacterStatus
  readonly bomb?: BombProps
}

const useStyles = makeStyles({
  root: {
    display: 'inline-block',
    position: 'relative',
    minWidth: 600,
    minHeight: 600,
  },
})

export default function Map(props: Props) {
  const {
    map: { width, height, name },
    userId,
    gameState,
    gameOverData,
    allPlayersReady,
    onReady,
    onMove,
    onPutBomb,
  } = props
  const [textureLoaded, setTextureLoaded] = useState<boolean>(false)
  const [canvasSize, setCanvasSize] = useState<Size>({ width: 0, height: 0 })
  // 'finalGameState' = 'gameState' + 'predictedData'
  const [finalGameState, setFinalGameState] = useState<GameState>(gameState)
  const [playerTint, setPlayerTint] = useState<PlayerTint | null>(null)
  const [initialCountdownCompleted, setInitialCountdownCompleted] = useState<boolean>(false)
  const predictedData = useRef<PredictedData>({})
  const classes = useStyles()

  const mapProfile = useMemo(
    () => Maps[name]!,
    [name],
  )

  // Finding object by x & y with hash map can reduce
  // time complexity from linear to constant.
  const hashedObstable = useMemo<XYRecord<GameStateObstacle>>(
    () => new XYRecord<GameStateObstacle>(gameState.objects),
    [gameState],
  )

  const prevHashedObstacle = useRef<XYRecord<GameStateObstacle>>(hashedObstable)

  const hashedBomb = useMemo<XYRecord<BombProps>>(
    () => new XYRecord<BombProps>(finalGameState.bombs),
    [finalGameState.bombs],
  )

  const hasObject = useCallback(
    (x: number, y: number): boolean =>
      !!(hashedObstable.has(x, y) || hashedBomb.has(x, y)),
    [hashedObstable, hashedBomb],
  )

  const canMoveTo = useCallback(
    (x: number, y: number): boolean =>
      x >= 0 && x < width &&
      y >= 0 && y < height &&
      !hasObject(x, y) &&
      !predictedData.current.playerStatus,
    [width, height, hasObject],
  )

  const canExplode = useCallback((x: number, y: number): CanExplodeType => {
    // Preventing bombs explode through the exploded dynamic obstacles
    // by using previous obstacles.
    const obstacle = prevHashedObstacle.current.getItem(x, y)
    if (!obstacle && x >= 0 && x < width && y >= 0 && y < height) {
      return CanExplodeType.Yes
    } else if (obstacle && obstacle.id !== 1) {
      return CanExplodeType.StopHere
    }
    return CanExplodeType.No
  }, [width, height])

  const onTextureLoad = useCallback(() => {
    setTextureLoaded(true)
    onReady()
  }, [onReady])

  const updateFinalGameState = useCallback(() => {
    // If there exists predicted data,
    // we must merge them into 'finalGameState'.
    let newState: GameState = gameState
    const { playerStatus, bomb } = predictedData.current

    if (playerStatus) {
      newState = {
        ...newState,
        players: {
          ...newState.players,
          [userId]: playerStatus,
        },
      }
    }

    if (bomb) {
      let me: CharacterStatus = playerStatus || {...newState.players[userId]!}
      me = {...me, bombs: me.bombs - 1}
      newState = {
        ...newState,
        players: {
          ...newState.players,
          [userId]: me,
        },
        bombs: [...newState.bombs, bomb],
      }
    }
    setFinalGameState(newState)
  }, [gameState, userId])

  const onPlayerStatusChange = useCallback((newStatus: CharacterStatus) => {
    // If 'predictedData.current.playerStatus' exists,
    // that means there's a pending moving request,
    // in this case we do nothing.
    if (predictedData.current.playerStatus) return

    // Create a predicted data.
    predictedData.current = {
      ...predictedData.current,
      playerStatus: newStatus,
    }

    // Make 'finalGameState' sync with our prediction.
    updateFinalGameState()

    const { direction } = newStatus
    onMove(direction)
      .then(() => {
        // Clear predicted data.
        predictedData.current = {
          bomb: predictedData.current.bomb,
        }
      })
  }, [onMove, updateFinalGameState])

  const putBomb = useCallback((x: number, y: number) => {
    if (predictedData.current.bomb) return

    const newBomb: BombProps = { x, y, isPredicted: true }
    predictedData.current = {
      ...predictedData.current,
      bomb: newBomb,
    }
    updateFinalGameState()

    onPutBomb()
      .then(() => {
        predictedData.current = {
          playerStatus: predictedData.current.playerStatus,
        }
      })
  }, [onPutBomb, updateFinalGameState])

  useEffect(() => {
    updateFinalGameState()
  }, [updateFinalGameState])

  useEffect(() => {
    if (!playerTint) {
      const newPlayerTint: PlayerTint = {}
      Object.keys(gameState.players).sort().forEach((id, i) => {
        if (id !== userId) {
          newPlayerTint[id] = Tints[i]
        }
      })
      setPlayerTint(newPlayerTint)
    }
  }, [gameState, playerTint, userId])

  useEffect(() => () => {
    // Maintaining "prevHashedObstacle"
    prevHashedObstacle.current = hashedObstable
  }, [hashedObstable])

  return (
    <div className={classes.root}>
      <Stage
        width={canvasSize.width}
        height={canvasSize.height}
      >
        <TextureLoader onLoad={onTextureLoad} />
        {textureLoaded && (
          <Background
            profile={mapProfile}
            mapWidth={width}
            mapHeight={height}
            onSize={setCanvasSize}
          >
            <Obstacles
              profile={mapProfile}
              items={gameState.objects}
            />
            <Bombs
              bombs={finalGameState.bombs}
              canExplode={canExplode}
            />
            {Object.keys(finalGameState.players).map(id => {
              const isMe = userId === id
              return (
                <Character
                  key={id}
                  profile={Characters[0]}
                  status={finalGameState.players[id]!}
                  tint={(playerTint && playerTint[id]) || undefined}
                  hasArrow={isMe}
                  blinking={isMe && !initialCountdownCompleted}
                  playerOnlyProps={isMe ? {
                    isGameOver: !!gameOverData,
                    disableControl: !initialCountdownCompleted,
                    onStatusChange: onPlayerStatusChange,
                    canMoveTo,
                    onPutBomb: putBomb,
                  } : undefined}
                />
              )
            })}
          </Background>
        )}
      </Stage>
      {gameOverData && <GameResult gameOverData={gameOverData} />}
      {!initialCountdownCompleted && (
        <InitialCountdown
          allPlayersReady={allPlayersReady}
          onComplete={setInitialCountdownCompleted}
        />
      )}
    </div>
  )
}
