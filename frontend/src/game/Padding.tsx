import React, { FC } from 'react'

import { BLOCK_UNIT } from '../app/constants'

import Rectangle from './Rectangle'

export const SIZE = 14
const COLOR = 0x5c5c5c

interface Props {
  readonly width: number
  readonly height: number
}

const Padding: FC<Props> = ({ width, height }) => (
  <>
    <Rectangle
      x={0}
      y={0}
      width={width * BLOCK_UNIT + SIZE * 2}
      height={SIZE}
      fill={COLOR}
    />
    <Rectangle
      x={0}
      y={height * BLOCK_UNIT + SIZE}
      width={width * BLOCK_UNIT + SIZE * 2}
      height={SIZE}
      fill={COLOR}
    />
    <Rectangle
      x={0}
      y={0}
      width={SIZE}
      height={height * BLOCK_UNIT + SIZE * 2}
      fill={COLOR}
    />
    <Rectangle
      x={width * BLOCK_UNIT + SIZE}
      y={0}
      width={SIZE}
      height={height * BLOCK_UNIT + SIZE * 2}
      fill={COLOR}
    />
  </>
)

export default Padding
