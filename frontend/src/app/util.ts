import { Application, Rectangle, Texture } from 'pixi.js'
import { TilesetItem, Size } from './types'
import { BLOCK_UNIT } from './constants'

export const getTextureFromApp = (app: Application, item: TilesetItem) => {
  const { texture } = app.loader.resources[item.imageSrc]!
  const { tilesetInfo } = item

  if (!tilesetInfo) {
    return texture
  }

  const { x, y, width, height } = tilesetInfo

  return new Texture( texture.baseTexture, new Rectangle(x, y, width, height))
}

export const fitInBlock = (texture: Texture, isFitWidth: boolean = true): Size => {
  const { orig } = texture
  const aspectRatio = orig.width / orig.height
  if (isFitWidth) {
    return {
      width: BLOCK_UNIT,
      height: BLOCK_UNIT / aspectRatio,
    }
  } else {
    return {
      width: BLOCK_UNIT * aspectRatio,
      height: BLOCK_UNIT,
    }
  }
}

export const sinByTime = (
  frequency: number,
  min: number,
  max: number,
  time: number = Date.now(),
): number =>
  (Math.sin(time / 1000 * 2 * Math.PI * frequency) + 1) / 2 * (max - min) + min
