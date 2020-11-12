// This component loads all image resources
// into GPU's memory.

import { FC, useEffect } from 'react'
import { Loader } from 'pixi.js'
import { useApp } from '@inlet/react-pixi'

import { TilesetItem } from '../app/types'
import {
  BombSpriteSet,
  Characters,
  ExplosionSpriteSet,
  Maps,
  DownArrowTilesetItem,
} from '../app/constants'

// Please list all image resources here.
const IMAGES: ReadonlyArray<TilesetItem> = [
  ...BombSpriteSet.items,
  ...ExplosionSpriteSet.items,
  ...Characters.map(
    character => [
      ...character.walkingUp.items,
      ...character.walkingDown.items,
      ...character.walkingLeft.items,
      ...character.walkingRight.items,
    ],
  ).flat(),
  ...Object.keys(Maps).map(name => {
    const map = Maps[name]!
    return [
      map.background,
      ...map.tiles,
      ...Object.keys(map.obstacles).map(id => map.obstacles[parseInt(id)]!),
    ]
  }).flat(),
  DownArrowTilesetItem,
]

const loadTextureIfNeed = (loader: Loader, item: TilesetItem) => {
  const { imageSrc } = item
  return loader.resources[imageSrc] ? loader : loader.add(imageSrc)
}

interface Props {
  readonly onLoad: () => void
}

const TextureLoader: FC<Props> = ({ onLoad }) => {
  const app = useApp()

  useEffect(() => {
    let { loader } = app
    let canceled: boolean = false
    IMAGES.forEach(item => {
      loader = loadTextureIfNeed(loader, item)
    })
    loader.load(() => !canceled && onLoad())
    return () => {
      canceled = true
    }
  }, [onLoad, app])

  return null
}

export default TextureLoader
