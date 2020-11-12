import { FC, useEffect, useRef } from 'react'
import { useTick } from '@inlet/react-pixi'

import { CharacterProfile, PlayerKey } from '../../app/types'
import { Point } from '../../app/types'

import { Player as CharacterStatus, Direction } from '../types'

interface Props {
  readonly profile: CharacterProfile
  readonly status: CharacterStatus
  readonly pressedKey: PlayerKey | null
  readonly onAnimation: (position: Point) => void
  readonly onWalking: (isWalking: boolean) => void
  readonly onStatusChange?: (newStatus: CharacterStatus, isMoved: boolean) => void
  readonly canMoveTo?: (x: number, y: number) => boolean
}

interface MovingInfo {
  readonly startAt: number
  readonly origin: Point
  readonly delta: Point
}

const isStillMovingSameDirection = (delta: Point, pressedKey: PlayerKey | null): boolean => {
  switch (pressedKey) {
    case PlayerKey.Up:
      return delta.y < 0
    case PlayerKey.Down:
      return delta.y > 0
    case PlayerKey.Left:
      return delta.x < 0
    case PlayerKey.Right:
      return delta.x > 0
  }
  return false
}

const deltaToDirection = (delta: Point, status: CharacterStatus): Direction => {
  const { x, y } = delta
  const { direction } = status

  if (x > 0) return Direction.Right
  if (x < 0) return Direction.Left
  if (y > 0) return Direction.Down
  if (y < 0) return Direction.Up

  return direction
}

const isMovingTo = (movingInfo: MovingInfo, dest: Point): boolean =>
  movingInfo.origin.x + movingInfo.delta.x === dest.x &&
  movingInfo.origin.y + movingInfo.delta.y === dest.y

const Moving: FC<Props> = props => {
  const {
    profile,
    status,
    pressedKey,
    onAnimation,
    onWalking,
    onStatusChange,
    canMoveTo,
  } = props
  const prevStatus = useRef<CharacterStatus>(status)
  const movingInfo = useRef<MovingInfo | null>(null)

  useEffect(() => {
    if (!movingInfo.current || !isMovingTo(movingInfo.current, status)) {
      // Trigger animation by 'status'.
      const dx = status.x - prevStatus.current.x
      const dy = status.y - prevStatus.current.y

      // If moving distance == 1,
      // then move to the destination smoothly.
      // If moving distance != 1,
      // this is usually caused by connection issues,
      // then move to the destination instantly.
      if (dx === 0 && Math.abs(dy) === 1) {
        movingInfo.current = {
          startAt: Date.now(),
          origin: prevStatus.current,
          delta: { x: 0, y: dy },
        }
      } else if (dy === 0 && Math.abs(dx) === 1) {
        movingInfo.current = {
          startAt: Date.now(),
          origin: prevStatus.current,
          delta: { x: dx, y: 0 },
        }
      } else {
        movingInfo.current = null
        onAnimation(status)
      }

      if (movingInfo.current) onWalking(true)
    }

    prevStatus.current = {...status}
  }, [status, onWalking, onAnimation])

  useTick(() => {
    if (movingInfo.current) {
      const { startAt, origin, delta } = movingInfo.current
      const progress = (Date.now() - startAt) * profile.walkingSpeed / 1000
      if (
        progress < 1 ||
        (onStatusChange && canMoveTo && isStillMovingSameDirection(delta, pressedKey))
      ) {
        // Progress animation.
        onAnimation({
          x: origin.x + progress * delta.x,
          y: origin.y + progress * delta.y,
        })
        if (progress >= 1) {
          // This section make moving smoother
          // when keeping pressing the same
          // direction key.
          const newProgress = progress - 1
          const newOrigin: Point = {
            x: origin.x + delta.x,
            y: origin.y + delta.y,
          }
          const newPosition: Point = {
            x: newOrigin.x + delta.x,
            y: newOrigin.y + delta.y,
          }
          if (canMoveTo!(newPosition.x, newPosition.y)) {
            movingInfo.current = {
              startAt: Date.now() - (newProgress * 1000 / profile.walkingSpeed),
              origin: newOrigin,
              delta,
            }
            onStatusChange!(
              {
                ...status,
                ...newPosition,
                direction: deltaToDirection(delta, status),
              },
              true,
            )
          } else {
            movingInfo.current = null
            onAnimation(status)
            onWalking(false)
          }
        }
      } else {
        // Stop animation.
        movingInfo.current = null
        onAnimation(status)
        onWalking(false)
      }
    } else if (pressedKey && onStatusChange && canMoveTo) {
      // Trigger animation by keyboard.
      let dx = 0
      let dy = 0
      switch (pressedKey) {
        case PlayerKey.Up:
          dy = -1
          break
        case PlayerKey.Down:
          dy = 1
          break
        case PlayerKey.Left:
          dx = -1
          break
        case PlayerKey.Right:
          dx = 1
          break
      }

      const newPosition: Point = {
        x: status.x + dx,
        y: status.y + dy,
      }
      const newDirection = deltaToDirection({ x: dx, y: dy }, status)

      if (canMoveTo(newPosition.x, newPosition.y)) {
        onStatusChange(
          {
            ...status,
            ...newPosition,
            direction: newDirection,
          },
          true,
        )
      } else if (status.direction !== newDirection) {
        onStatusChange(
          {
            ...status,
            direction: newDirection,
          },
          false,
        )
      }
    }
  })

  return null
}

export default Moving
