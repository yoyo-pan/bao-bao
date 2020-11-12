import React, { FC, useMemo, ReactNode } from 'react'
import { Container, Sprite, useApp } from '@inlet/react-pixi'
import { getTextureFromApp } from '../app/util'
import { MapProfile, Size } from '../app/types'
import { BLOCK_UNIT } from '../app/constants'

interface Props {
  readonly profile: MapProfile
  readonly mapWidth: number
  readonly mapHeight: number
  readonly onSize: (size: Size) => void
}

const Background: FC<Props> = props => {
  const { profile, mapWidth, mapHeight, onSize, children } = props
  const app = useApp()

  const backgroundTexture = useMemo(
    () => getTextureFromApp(app, profile.background),
    [app, profile],
  )

  const tileTextures = useMemo(
    () => profile.tiles.map(item => getTextureFromApp(app, item)),
    [app, profile],
  )

  const containerSize = useMemo<Size>(
    () => ({
      width: mapWidth * BLOCK_UNIT,
      height: mapHeight * BLOCK_UNIT,
    }),
    [mapWidth, mapHeight],
  )

  const rootSize = useMemo<Size>(() => {
    const { paddingLeft, paddingTop } = profile
    const { orig } = backgroundTexture
    const aspectRatio = orig.width / orig.height

    let { width, height } = containerSize
    if (paddingLeft) {
      width += paddingLeft * BLOCK_UNIT * 2
      height = width / aspectRatio
    } else if (paddingTop) {
      height += paddingTop * BLOCK_UNIT * 2
      width = height * aspectRatio
    }

    const size: Size = { width, height }
    onSize(size)
    return size
  }, [profile, backgroundTexture, containerSize, onSize])

  const tiles = useMemo(() => {
    const result: ReactNode[] = []
    for (let y = 0; y < mapHeight; y += 1) {
      for (let x = 0; x < mapWidth; x += 1) {
        const index = (x + y) % tileTextures.length
        result.push(
          <Sprite
            key={`${x},${y}`}
            texture={tileTextures[index]}
            x={x * BLOCK_UNIT}
            y={y * BLOCK_UNIT}
            width={BLOCK_UNIT}
            height={BLOCK_UNIT}
          />
        )
      }
    }
    return result
  }, [tileTextures, mapWidth, mapHeight])

  return (
    <>
      <Sprite
        texture={backgroundTexture}
        width={rootSize.width}
        height={rootSize.height}
      />
      <Container
        x={(rootSize.width - containerSize.width) / 2}
        y={(rootSize.height - containerSize.height) / 2}
        width={containerSize.width}
        height={containerSize.height}
      >
        {tiles}
        {children}
      </Container>
    </>
  )
}

export default Background
