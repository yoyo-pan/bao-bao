import { Texture } from 'pixi.js'

import { Point } from '../app/types'

export interface Obstacle extends Point {
  readonly objectId: number
}

export interface GameStateObstacle extends Point {
  readonly id: number
}

export type GameStateObstacles = ReadonlyArray<GameStateObstacle>

export enum Direction {
  Up = 'up',
  Down = 'down',
  Left = 'left',
  Right = 'right',
}

export interface Bomb extends Point {
  readonly isPredicted?: true
}

export type Bombs = ReadonlyArray<Bomb>

export interface Player extends Point {
  readonly bombs: number
  readonly direction: Direction
  readonly isAlive: boolean
}

export type Players = Partial<Record<string, Player>>

export interface GameState {
  readonly bombs: Bombs
  readonly players: Players
  readonly objects: GameStateObstacles
}

export interface GameStateResponse {
  readonly state: GameState
  readonly time: number
}

export interface PlayerSummary {
  readonly nickname: string
  readonly wins: number
  readonly losses: number
  readonly draws: number
}

export type PlayerSummaryRecord = Partial<Record<string, PlayerSummary>>

export interface GameOverData {
  readonly winners: PlayerSummaryRecord
  readonly losers: PlayerSummaryRecord
  readonly time: number
}

export enum CommandName {
  KeyDown = 'key_down',
  KeyUp = 'key_up',
  PlaceBomb = 'place_bomb',
}

export interface CommandPayload {
  [CommandName.KeyDown]: Direction
  [CommandName.KeyUp]: Direction
  [CommandName.PlaceBomb]: null
}

export interface Command<T extends CommandName> {
  name: T
  payload: CommandPayload[T]
}

export type Textures = Texture[]

export interface TextureBank {
  readonly up: Textures
  readonly down: Textures
  readonly left: Textures
  readonly right: Textures
}

export enum CanExplodeType {
  No = 0,     // do not render explosion and stop here.
  StopHere,   // render explosion but stop here.
  Yes,        // render explosion here and continue.
}

export type CanExplode = (x: number, y: number) => CanExplodeType
