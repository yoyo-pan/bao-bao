import React, { FC, useMemo, useState } from 'react'
import { Sprite, useApp, useTick } from '@inlet/react-pixi'

import { Point } from '../../app/types'
import { DownArrowTilesetItem, BLOCK_UNIT } from '../../app/constants'
import { getTextureFromApp, sinByTime } from '../../app/util'

const ALPHA = 0.65
const ANIMATION_SPEED = 0.5     // in Hz
const ANIMATION_DISTANCE = 0.3  // in blocks
const OFFSET_Y = -0.7           // in blocks

interface Props extends Point {}

const DownArrow: FC<Props> = props => {
  const { x, y } = props
  const app = useApp()

  const [animationOffsetY, setAnimationOffsetY] = useState<number>(0)

  const texture = useMemo(
    () => getTextureFromApp(app, DownArrowTilesetItem),
    [app],
  )

  useTick(() => {
    setAnimationOffsetY(-sinByTime(ANIMATION_SPEED, 0, ANIMATION_DISTANCE))
  })

  return (
    <Sprite
      texture={texture}
      x={(x + 0.5) * BLOCK_UNIT}
      y={(y + OFFSET_Y + animationOffsetY) * BLOCK_UNIT}
      width={BLOCK_UNIT}
      height={BLOCK_UNIT}
      anchor={[0.5, 1]}
      alpha={ALPHA}
    />
  )
}

export default DownArrow
