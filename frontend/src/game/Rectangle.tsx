import React, { useCallback } from 'react'
import { Graphics } from 'pixi.js'
import { Graphics as GraphicsComponent } from '@inlet/react-pixi'

interface Props {
  readonly x: number
  readonly y: number
  readonly width: number
  readonly height: number
  readonly fill: number
}

export default function Rectangle(props: Props) {
  const { x, y, width, height, fill } = props

  const draw = useCallback((g: Graphics) => {
    g.clear()
    g.moveTo(0, 0)
    g.beginFill(fill)
    g.drawRect(0, 0, width, height)
    g.endFill()
  }, [width, height, fill])

  return (
    <GraphicsComponent
      x={x}
      y={y}
      width={width}
      height={height}
      draw={draw}
    />
  )
}
