import React, { FC, useMemo } from 'react'
import { Texture } from 'pixi.js'
import { AnimatedSprite, useApp } from '@inlet/react-pixi'

import { BombSpriteSet, BLOCK_UNIT } from '../../app/constants'
import { getTextureFromApp } from '../../app/util'

import { Bomb as BombProps } from '../types'

const Bomb: FC<BombProps> = props => {
  const { x, y } = props
  const app = useApp()
  const {
    items: tilesetItems,
    speed,
    startIndex,
  } = BombSpriteSet
  const textures = useMemo<Texture[]>(
    () => tilesetItems.map(item => getTextureFromApp(app, item)),
    [app, tilesetItems],
  )
  return (
    <AnimatedSprite
      textures={textures}
      x={x * BLOCK_UNIT}
      y={y * BLOCK_UNIT}
      width={BLOCK_UNIT}
      height={BLOCK_UNIT}
      animationSpeed={speed}
      initialFrame={startIndex}
      isPlaying
    />
  )
}

export default Bomb
