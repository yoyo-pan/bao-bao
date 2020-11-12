import React, { FC, useEffect, useRef, useState } from 'react'
import { Texture } from 'pixi.js'
import { Sprite, useTick } from '@inlet/react-pixi'

import { Point, Size } from '../../app/types'
import { BLOCK_UNIT } from '../../app/constants'

export const ANIMATION_TIME = 0.5  // in seconds

export interface Props extends Point, Size {
  readonly texture: Texture
  readonly isDying: boolean
}

const Obstacle: FC<Props> = props => {
  const { texture, x, y, width, height, isDying } = props
  const [alpha, setAlpha] = useState<number>(1)
  const dieAt = useRef<number | null>(null)

  useEffect(() => {
    dieAt.current = isDying ? Date.now() : null
  }, [isDying])

  useTick(() => {
    if (isDying && dieAt.current && alpha !== 0) {
      setAlpha(Math.max(1 - (Date.now() - dieAt.current) / 1000 / ANIMATION_TIME, 0))
    } else if (!isDying && alpha !== 1) {
      setAlpha(1)
    }
  })

  return (
    <Sprite
      texture={texture}
      anchor={[0, 1]}
      x={x * BLOCK_UNIT}
      y={(y + 1) * BLOCK_UNIT}
      width={width}
      height={height}
      alpha={alpha}
    />
  )
}

export default Obstacle
