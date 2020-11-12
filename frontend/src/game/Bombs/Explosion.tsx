import React, { FC, useMemo } from 'react'
import { Texture } from 'pixi.js'
import { AnimatedSprite, useApp } from '@inlet/react-pixi'

import { getTextureFromApp } from '../../app/util'
import { ExplosionSpriteSet, BLOCK_UNIT } from '../../app/constants'
import { Point } from '../../app/types'

import { Bomb, CanExplode, CanExplodeType } from '../types'

const POWER = 3

interface Props {
  readonly bomb: Bomb
  readonly canExplode: CanExplode
}

const Explosion: FC<Props> = props => {
  const app = useApp()
  const {
    items: tilesetItems,
    speed,
    startIndex,
  } = ExplosionSpriteSet
  const textures = useMemo<Texture[]>(
    () => tilesetItems.map(item => getTextureFromApp(app, item)),
    [app, tilesetItems],
  )
  const positions = useMemo<ReadonlyArray<Point>>(
    () => {
      const {
        bomb: { x, y },
        canExplode,
      } = props
      const result: Point[] = []

      const push = (x: number, y: number): boolean => {
        const type = canExplode(x, y)
        if (type !== CanExplodeType.No) {
          result.push({ x, y })
        }
        return type === CanExplodeType.Yes
      }

      for (let i = x; i <= x + POWER; i += 1) {
        if (!push(i, y)) break
      }
      for (let i = x - 1; i >= x - POWER; i -= 1) {
        if (!push(i, y)) break
      }
      for (let i = y + 1; i <= y + POWER; i += 1) {
        if (!push(x, i)) break
      }
      for (let i = y - 1; i >= y - POWER; i -= 1) {
        if (!push(x, i)) break
      }
      return result
    },
    [props],
  )
  return (
    <>
      {positions.map(pos => (
        <AnimatedSprite
          key={`${pos.x},${pos.y}`}
          textures={textures}
          x={pos.x * BLOCK_UNIT}
          y={pos.y * BLOCK_UNIT}
          width={BLOCK_UNIT}
          height={BLOCK_UNIT}
          animationSpeed={speed}
          initialFrame={startIndex}
          loop={false}
          isPlaying
        />
      ))}
    </>
  )
}

export default Explosion
