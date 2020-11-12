import React, { FC, useCallback, useMemo } from 'react'
import { Texture } from 'pixi.js'
import { useApp } from '@inlet/react-pixi'

import { MapProfile, Size } from '../../app/types'
import { GameStateObstacle } from '../types'
import { getTextureFromApp, fitInBlock } from '../../app/util'

import DelayedUnmountingRenderer from '../DelayedUnmountingRenderer'
import Obstacle, { ANIMATION_TIME, Props as ItemProps } from './Obstacle'

interface Props {
  readonly profile: MapProfile
  readonly items: ReadonlyArray<GameStateObstacle>
}

interface RenderInfo extends Size {
  readonly texture: Texture
}

const Obstacles: FC<Props> = props => {
  const { profile, items } = props
  const app = useApp()

  const renderInfoRecord = useMemo(() => {
    const result: Partial<Record<number, RenderInfo>> = {}
    Object.keys(profile.obstacles).forEach(key => {
      const id = parseInt(key)
      if (!result[id]) {
        const texture = getTextureFromApp(app, profile.obstacles[id]!)
        result[id] = {
          texture,
          ...fitInBlock(texture),
        }
      }
    })
    return result
  }, [profile, app])

  const itemPropsList = useMemo(
    () => items.map((item): ItemProps => {
      const { texture, width, height } = renderInfoRecord[item.id]!
      return {
        x: item.x,
        y: item.y,
        width,
        height,
        texture,
        isDying: false,
      }
    }),
    [items, renderInfoRecord]
  )

  const renderer = useCallback((item: ItemProps, isDying: boolean) => (
    <Obstacle
      {...item}
      isDying={isDying}
    />
  ), [])

  return (
    <DelayedUnmountingRenderer<ItemProps>
      items={itemPropsList}
      timeout={ANIMATION_TIME}
      renderer={renderer}
    />
  )
}

export default Obstacles
