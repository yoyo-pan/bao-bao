import { useCallback, useEffect, useRef } from 'react'

import { PlayerKey } from '../../app/types'

interface Props {
  readonly onChange: (pressedKey: PlayerKey | null) => void
  readonly onPutBomb: () => void
}

const filterMovingEvent = (evt: KeyboardEvent): PlayerKey | null => {
  switch (evt.key) {
    case PlayerKey.Up:
      return PlayerKey.Up
    case PlayerKey.Down:
      return PlayerKey.Down
    case PlayerKey.Left:
      return PlayerKey.Left
    case PlayerKey.Right:
      return PlayerKey.Right
  }
  return null
}

export default function KeyboardHandler(props: Props) {
  const { onChange, onPutBomb } = props
  const lastKey = useRef<PlayerKey | null>(null)

  const onKeyDown = useCallback((evt: KeyboardEvent) => {
    if (evt.key === PlayerKey.PutBomb) {
      onPutBomb()
      return
    }

    const key = filterMovingEvent(evt)
    if (key) {
      onChange(key)
      lastKey.current = key
    }
  }, [onChange, onPutBomb])

  const onKeyUp = useCallback((evt: KeyboardEvent) => {
    if (filterMovingEvent(evt) === lastKey.current) {
      onChange(null)
      lastKey.current = null
    }
  }, [onChange])

  useEffect(() => {
    window.addEventListener('keydown', onKeyDown)
    window.addEventListener('keyup', onKeyUp)
    return () => {
      window.removeEventListener('keydown', onKeyDown)
      window.removeEventListener('keyup', onKeyUp)
    }
  }, [onKeyDown, onKeyUp])

  return null
}
