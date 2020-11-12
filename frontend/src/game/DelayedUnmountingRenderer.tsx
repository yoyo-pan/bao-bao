import React, {
  Fragment,
  ReactNode,
  useCallback,
  useEffect,
  useRef,
  useState,
  useMemo,
} from 'react'
import { useTick } from '@inlet/react-pixi'

import { Point } from '../app/types'
import XYRecord from '../app/XYRecord'

interface Props<T extends Point> {
  readonly items: ReadonlyArray<T>
  readonly timeout: number          // in seconds
  readonly renderer: (item: T, isDying: boolean) => ReactNode
  readonly disableCache?: boolean
}

interface TimedItem<T> {
  readonly data: T
  readonly startAt: number
}

const getCacheID = (item: Point, isDying: boolean) =>
  `${item.x},${item.y},${isDying}`

export default function DelayedUnmountingRenderer<T extends Point>(props: Props<T>) {
  const { items, timeout, renderer, disableCache } = props
  const [dyingItems, setDyingItems] = useState<ReadonlyArray<T>>([])
  const dyingTimedItems = useRef<ReadonlyArray<TimedItem<T>>>([])
  const prevItems = useRef<ReadonlyArray<T>>(items)
  const cache = useRef<Partial<Record<string, ReactNode>>>({})

  const getItemNode = useCallback((item: T, isDying: boolean) => {
    if (disableCache) {
      return renderer(item, isDying)
    } else {
      const id = getCacheID(item, isDying)
      if (cache.current[id] === undefined) {
        cache.current[id] = renderer(item, isDying)
      }
      return cache.current[id]!
    }
  }, [renderer, disableCache])

  useEffect(() => {
    const record = new XYRecord<T>(items)
    const disappearedItems: T[] = []
    prevItems.current.forEach(item => {
      const { x, y } = item
      if (!record.has(x, y)) {
        disappearedItems.push(item)
        delete cache.current[getCacheID(item, false)]
      }
    })
    const now = Date.now()
    dyingTimedItems.current = dyingTimedItems.current.concat(
      disappearedItems.map((item): TimedItem<T> => ({
        data: item,
        startAt: now,
      }),
    ))
    setDyingItems(dyingTimedItems.current.map(item => item.data))
    prevItems.current = items
  }, [items])

  useTick(() => {
    const now = Date.now()
    let count: number = 0
    for (const item of dyingTimedItems.current) {
      if (item.startAt + timeout * 1000 <= now) count += 1
      else break
      delete cache.current[getCacheID(item.data, true)]
    }
    if (count > 0) {
      dyingTimedItems.current = dyingTimedItems.current.slice(count)
      setDyingItems(dyingTimedItems.current.map(item => item.data))
    }
  })

  const child = useMemo(() => (
    <>
      {items.map((item, i) => (
        <Fragment key={i}>
          {getItemNode(item, false)}
        </Fragment>
      ))}
      {dyingItems.map((item, i) => (
        <Fragment key={i}>
          {getItemNode(item, true)}
        </Fragment>
      ))}
    </>
  ), [items, dyingItems, getItemNode])

  return child
}
