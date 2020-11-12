import React, { useEffect, useMemo, useState } from 'react'
import { AnimatedSprite, useTick } from '@inlet/react-pixi'

import { CharacterProfile, AnimatedSpriteSet, Size, Point } from '../../app/types'
import { BLOCK_UNIT } from '../../app/constants'
import { fitInBlock, sinByTime } from '../../app/util'

import { Player as CharacterStatus, Direction, TextureBank, Textures } from '../types'

const BLINKING_RATE = 2.5         // in Hz
const BLINKING_ALPHA_MIN = 0.25

interface Props {
  readonly textureBank: TextureBank
  readonly profile: CharacterProfile
  readonly status: CharacterStatus
  readonly isWalking: boolean
  readonly animatedPosition: Point
  readonly tint?: number
  readonly blinking?: boolean
}

interface AnimationInfo {
  readonly textures: Textures
  readonly speed: number
  readonly startIndex: number
}

interface SpriteAdjustment {
  readonly offset: Point
  readonly rotation: number
  readonly anchor: number | [number, number]
}

export default function SpriteHandler(props: Props) {
  const {
    profile,
    status,
    isWalking,
    textureBank,
    tint,
    animatedPosition,
    blinking,
  } = props

  const [alpha, setAlpha] = useState<number>(1)

  const size = useMemo<Size>(
    () => fitInBlock(textureBank.down[0]),
    [textureBank],
  )

  const animationInfo = useMemo<AnimationInfo>(() => {
    let textures: Textures = textureBank.up
    let spriteSet: AnimatedSpriteSet = profile.walkingUp

    if (status.isAlive) {
      switch (status.direction) {
        case Direction.Down:
          textures = textureBank.down
          spriteSet = profile.walkingDown
          break
        case Direction.Left:
          textures = textureBank.left
          spriteSet = profile.walkingLeft
          break
        case Direction.Right:
          textures = textureBank.right
          spriteSet = profile.walkingRight
          break
      }
    } else {
      textures = textureBank.left
      spriteSet = profile.walkingLeft
    }

    if (isWalking && status.isAlive) {
      return {
        textures,
        speed: spriteSet.speed,
        startIndex: spriteSet.startIndex,
      }
    } else {
      return {
        textures: [textures[0]],
        speed: 0,
        startIndex: 0,
      }
    }
  }, [profile, status, isWalking, textureBank])

  const spriteAdjustment = useMemo<SpriteAdjustment>(
    () => status.isAlive ? {
      offset: { x: 0, y: 1 },
      rotation: 0,
      anchor: [0, 1],
    } : {
      offset: { x: 0.5, y: 0.5 },
      rotation: Math.PI / 2,
      anchor: [0.5, 0.5],
    },
    [status.isAlive],
  )

  useEffect(() => {
    if (!blinking) {
      setAlpha(1)
    }
  }, [blinking])

  useTick(() => {
    if (blinking) {
      setAlpha(sinByTime(BLINKING_RATE, BLINKING_ALPHA_MIN, 1))
    }
  })

  const { textures, speed, startIndex } = animationInfo
  const { offset, rotation, anchor } = spriteAdjustment

  return (
    // The prop 'key' is used to
    // prevent some issues.
    <AnimatedSprite
      key={`${isWalking} ${status.direction}`}
      x={(animatedPosition.x + offset.x) * BLOCK_UNIT}
      y={(animatedPosition.y + offset.y) * BLOCK_UNIT}
      width={size.width}
      height={size.height}
      textures={textures}
      animationSpeed={speed}
      initialFrame={startIndex}
      tint={tint === undefined ? 0xFFFFFF : tint}
      isPlaying
      rotation={rotation}
      anchor={anchor}
      alpha={alpha}
    />
  )
}
