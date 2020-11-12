import React, { FC, useCallback } from 'react'

import DelayedUnmountingRenderer from '../DelayedUnmountingRenderer'
import Bomb from './Bomb'
import Explosion from './Explosion'

import {
  Bomb as BombProps,
  Bombs as BombPropsList,
  CanExplode,
} from '../types'

const EXPLOSION_ANIMATION_TIME = 0.7  // in seconds

interface Props {
  readonly bombs: BombPropsList
  readonly canExplode: CanExplode
}

const Bombs: FC<Props> = ({ bombs, canExplode }) => {
  const renderer = useCallback((bomb: BombProps, isDying: boolean) => {
    if (isDying) {
      return bomb.isPredicted ? null : (
        <Explosion
          bomb={bomb}
          canExplode={canExplode}
        />
      )
    } else {
      return (
        <Bomb {...bomb} />
      )
    }
  }, [canExplode])

  return (
    <DelayedUnmountingRenderer
      items={bombs}
      timeout={EXPLOSION_ANIMATION_TIME}
      renderer={renderer}
    />
  )
}

export default Bombs
