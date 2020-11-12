import React, { useCallback, useEffect, useMemo, useRef, useState } from 'react'
import { useApp } from '@inlet/react-pixi'

import { getTextureFromApp } from '../../app/util'
import { CharacterProfile, PlayerKey, Point } from '../../app/types'

import { Player as CharacterStatus, Direction, TextureBank } from '../types'

import KeyboardHandler from './KeyboardHandler'
import Moving from './Moving'
import SpriteHandler from './SpriteHandler'
import DownArrow from './DownArrow'

interface Props {
  readonly profile: CharacterProfile
  readonly status: CharacterStatus
  readonly tint?: number
  readonly blinking?: boolean
  readonly hasArrow?: boolean
  readonly playerOnlyProps?: {
    readonly isGameOver: boolean
    readonly disableControl?: boolean
    readonly onStatusChange: (newStatus: CharacterStatus) => void
    readonly canMoveTo: (x: number, y: number) => boolean
    readonly onPutBomb: (x: number, y: number) => void
  }
}

export default function Character(props: Props) {
  const { profile, status, playerOnlyProps, tint, blinking, hasArrow } = props
  const app = useApp()
  const [pressedKey, setPressedKey] = useState<PlayerKey | null>(null)
  const [isWalking, setIsWalking] = useState<boolean>(false)
  const [speculatedDirection, setSpeculatedDirection] = useState<Direction | null>(null)
  const [animatedPosition, setAnimatedPosition] = useState<Point>(status)
  // This prevent putting multiple bombs at the same position.
  const putBombPositionLocker = useRef<boolean>(false)

  const textureBank = useMemo<TextureBank>(() => {
    const {
      walkingUp: up,
      walkingDown: down,
      walkingLeft: left,
      walkingRight: right,
    } = profile
    return {
      up: up.items.map(item => getTextureFromApp(app, item)),
      down: down.items.map(item => getTextureFromApp(app, item)),
      left: left.items.map(item => getTextureFromApp(app, item)),
      right: right.items.map(item => getTextureFromApp(app, item)),
    }
  }, [app, profile])

  const onMoving = useCallback((newStatus: CharacterStatus, moved: boolean) => {
    if (!playerOnlyProps) return
    putBombPositionLocker.current = false
    if (moved) {
      // Send command to server & clear 'speculatedDirection'
      playerOnlyProps.onStatusChange(newStatus)
      setSpeculatedDirection(null)
    } else {
      // Set 'speculatedDiurection' to make the character
      // face to the correct direction.
      setSpeculatedDirection(newStatus.direction)
    }
  }, [playerOnlyProps])

  const onPutBomb = useCallback(() => {
    if (playerOnlyProps && !putBombPositionLocker.current && status.bombs > 0) {
      putBombPositionLocker.current = true
      playerOnlyProps.onPutBomb(status.x, status.y)
    }
  }, [playerOnlyProps, status])

  useEffect(() => {
    if (!status.isAlive || playerOnlyProps?.isGameOver || playerOnlyProps?.disableControl) {
      setPressedKey(null)
      setIsWalking(false)
    }
  }, [status.isAlive, playerOnlyProps])

  return (
    <>
      {
        (
          playerOnlyProps && status.isAlive &&
          !playerOnlyProps.isGameOver &&
          !playerOnlyProps.disableControl
        ) &&
        (
          <KeyboardHandler
            onChange={setPressedKey}
            onPutBomb={onPutBomb}
          />
        )
      }
      <Moving
        profile={profile}
        status={status}
        pressedKey={pressedKey}
        onAnimation={setAnimatedPosition}
        onWalking={setIsWalking}
        onStatusChange={playerOnlyProps && onMoving}
        canMoveTo={playerOnlyProps?.canMoveTo}
      />
      <SpriteHandler
        textureBank={textureBank}
        profile={profile}
        status={{
          ...status,
          direction: speculatedDirection || status.direction,
        }}
        isWalking={isWalking}
        animatedPosition={animatedPosition}
        tint={tint}
        blinking={blinking}
      />
      {hasArrow && <DownArrow {...animatedPosition}/>}
    </>
  )
}
