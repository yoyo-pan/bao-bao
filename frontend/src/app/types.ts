export interface Chat {
  readonly name: string
  readonly message: string
  readonly receivedAt: string
}

export interface Point {
  readonly x: number
  readonly y: number
}

export interface Size {
  readonly width: number
  readonly height: number
}

export enum LocalStorageKeys {
  Token = 'token',
}

export enum PlayerKey {
  Up = 'ArrowUp',
  Down = 'ArrowDown',
  Left = 'ArrowLeft',
  Right = 'ArrowRight',
  PutBomb = 'z',
}

// TilesetItem contains informations
// of how to render an image.
// If rendering whole image,
// 'tilesetInfo' can be 'undefined'.
export interface TilesetItem {
  readonly imageSrc: string
  readonly tilesetInfo?: {
    readonly x: number
    readonly y: number
    readonly width: number
    readonly height: number
  }
}

export interface AnimatedSpriteSet {
  readonly items: ReadonlyArray<TilesetItem>
  readonly startIndex: number // first frame
  readonly speed: number
}

export interface CharacterProfile {
  readonly walkingSpeed: number // blocks per second
  readonly walkingUp: AnimatedSpriteSet
  readonly walkingDown: AnimatedSpriteSet
  readonly walkingLeft: AnimatedSpriteSet
  readonly walkingRight: AnimatedSpriteSet
}

export interface Player {
  readonly id: string
  readonly nickname: string | null
}

export interface MapProfile {
  readonly background: TilesetItem
  readonly tiles: ReadonlyArray<TilesetItem>
  readonly obstacles: Partial<Record<number, TilesetItem>>
  // in blocks
  readonly paddingLeft?: number
  readonly paddingTop?: number
  /////
}
