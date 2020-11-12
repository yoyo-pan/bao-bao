import { Point } from './types'

export default class XYRecord<T extends Point> {
  private data: Partial<Record<string, T>>

  constructor(items: ReadonlyArray<T>) {
    this.data = {}
    items.forEach(item => {
      this.data[this.getItemID(item)] = item
    })
  }

  public readonly getKeys = (): ReadonlyArray<string> => Object.keys(this.data)

  public readonly has = (x: number, y: number): boolean => !!this.getItem(x, y)

  public readonly getItem = (x: number, y: number): T | undefined => this.data[this.generateID(x, y)]

  public readonly getItemByKey = (key: string): T | undefined => this.data[key]

  private readonly getItemID = (item: T) => this.generateID(item.x, item.y)

  private readonly generateID = (x: number, y: number) => `${x},${y}`
}
