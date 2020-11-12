import {
  AnimatedSpriteSet,
  CharacterProfile,
  MapProfile,
  TilesetItem,
} from './types'

import ImgBackground from '../assets/img/util/background_no_tile.png'

import ImgTile1 from '../assets/img/util/tile1.png'
import ImgTile2 from '../assets/img/util/tile2.png'

import ImgBlocker1 from '../assets/img/util/blocker1.png'
import ImgBlocker2 from '../assets/img/util/blocker2.png'
import ImgBlocker3 from '../assets/img/util/blocker3.png'

import ImgBomb1 from '../assets/img/bomb/effect_100.png'
import ImgBomb2 from '../assets/img/bomb/effect_101.png'
import ImgBomb3 from '../assets/img/bomb/effect_102.png'
import ImgBomb4 from '../assets/img/bomb/effect_103.png'
import ImgBomb5 from '../assets/img/bomb/effect_104.png'
import ImgBomb6 from '../assets/img/bomb/effect_105.png'
import ImgBomb7 from '../assets/img/bomb/effect_106.png'

import ImgExplosion01 from '../assets/img/bomb/effect_107.png'
import ImgExplosion02 from '../assets/img/bomb/effect_108.png'
import ImgExplosion03 from '../assets/img/bomb/effect_109.png'
import ImgExplosion04 from '../assets/img/bomb/effect_110.png'
import ImgExplosion05 from '../assets/img/bomb/effect_111.png'
import ImgExplosion06 from '../assets/img/bomb/effect_112.png'
import ImgExplosion07 from '../assets/img/bomb/effect_113.png'
import ImgExplosion08 from '../assets/img/bomb/effect_114.png'
import ImgExplosion09 from '../assets/img/bomb/effect_115.png'
import ImgExplosion10 from '../assets/img/bomb/effect_116.png'
import ImgExplosion11 from '../assets/img/bomb/effect_117.png'
import ImgExplosion12 from '../assets/img/bomb/effect_118.png'
import ImgExplosion13 from '../assets/img/bomb/effect_119.png'
import ImgExplosion14 from '../assets/img/bomb/effect_120.png'
import ImgExplosion15 from '../assets/img/bomb/effect_121.png'
import ImgExplosion16 from '../assets/img/bomb/effect_122.png'
import ImgExplosion17 from '../assets/img/bomb/effect_123.png'

import ImgCharacterFront1 from '../assets/img/character/character_front0.png'
import ImgCharacterFront2 from '../assets/img/character/character_front1.png'
import ImgCharacterFront3 from '../assets/img/character/character_front2.png'
import ImgCharacterFront4 from '../assets/img/character/character_front3.png'
import ImgCharacterFront5 from '../assets/img/character/character_front4.png'
import ImgCharacterFront6 from '../assets/img/character/character_front5.png'

import ImgCharacterBack1 from '../assets/img/character/character_back0.png'
import ImgCharacterBack2 from '../assets/img/character/character_back1.png'
import ImgCharacterBack3 from '../assets/img/character/character_back2.png'
import ImgCharacterBack4 from '../assets/img/character/character_back3.png'
import ImgCharacterBack5 from '../assets/img/character/character_back4.png'
import ImgCharacterBack6 from '../assets/img/character/character_back5.png'

import ImgCharacterLeft1 from '../assets/img/character/character_left0.png'
import ImgCharacterLeft2 from '../assets/img/character/character_left1.png'
import ImgCharacterLeft3 from '../assets/img/character/character_left2.png'
import ImgCharacterLeft4 from '../assets/img/character/character_left3.png'
import ImgCharacterLeft5 from '../assets/img/character/character_left4.png'
import ImgCharacterLeft6 from '../assets/img/character/character_left5.png'

import ImgCharacterRight1 from '../assets/img/character/character_right1.png'
import ImgCharacterRight2 from '../assets/img/character/character_right2.png'
import ImgCharacterRight3 from '../assets/img/character/character_right3.png'
import ImgCharacterRight4 from '../assets/img/character/character_right4.png'
import ImgCharacterRight5 from '../assets/img/character/character_right5.png'
import ImgCharacterRight6 from '../assets/img/character/character_right6.png'

import ImgDownArrow from '../assets/img/down_arrow.png'

export const BLOCK_UNIT = 30

export const Characters: ReadonlyArray<CharacterProfile> = [
  {
    // 'walkingSpeed' need to be smaller than
    // server's config to prevent state conflicts
    // between server and client.
    // '3.5' is a tested safe value.
    walkingSpeed: 3.5,
    walkingUp: {
      startIndex: 0,
      speed: 0.3,
      items: [
        { imageSrc: ImgCharacterBack1 },
        { imageSrc: ImgCharacterBack2 },
        { imageSrc: ImgCharacterBack3 },
        { imageSrc: ImgCharacterBack4 },
        { imageSrc: ImgCharacterBack5 },
        { imageSrc: ImgCharacterBack6 },
      ],
    },
    walkingDown: {
      startIndex: 1,
      speed: 0.3,
      items: [
        { imageSrc: ImgCharacterFront1 },
        { imageSrc: ImgCharacterFront2 },
        { imageSrc: ImgCharacterFront3 },
        { imageSrc: ImgCharacterFront4 },
        { imageSrc: ImgCharacterFront5 },
        { imageSrc: ImgCharacterFront6 },
      ],
    },
    walkingLeft: {
      startIndex: 1,
      speed: 0.3,
      items: [
        { imageSrc: ImgCharacterLeft1 },
        { imageSrc: ImgCharacterLeft2 },
        { imageSrc: ImgCharacterLeft3 },
        { imageSrc: ImgCharacterLeft4 },
        { imageSrc: ImgCharacterLeft5 },
        { imageSrc: ImgCharacterLeft6 },
      ],
    },
    walkingRight: {
      startIndex: 0,
      speed: 0.3,
      items: [
        { imageSrc: ImgCharacterRight1 },
        { imageSrc: ImgCharacterRight2 },
        { imageSrc: ImgCharacterRight3 },
        { imageSrc: ImgCharacterRight4 },
        { imageSrc: ImgCharacterRight5 },
        { imageSrc: ImgCharacterRight6 },
      ],
    },
  },
]

export const BombSpriteSet: AnimatedSpriteSet = {
  startIndex: 0,
  speed: 0.5,
  items: [
    { imageSrc: ImgBomb1 },
    { imageSrc: ImgBomb2 },
    { imageSrc: ImgBomb3 },
    { imageSrc: ImgBomb4 },
    { imageSrc: ImgBomb5 },
    { imageSrc: ImgBomb6 },
    { imageSrc: ImgBomb7 },
  ],
}

export const ExplosionSpriteSet: AnimatedSpriteSet = {
  speed: 0.5,
  startIndex: 0,
  items: [
    { imageSrc: ImgExplosion01 },
    { imageSrc: ImgExplosion02 },
    { imageSrc: ImgExplosion03 },
    { imageSrc: ImgExplosion04 },
    { imageSrc: ImgExplosion05 },
    { imageSrc: ImgExplosion06 },
    { imageSrc: ImgExplosion07 },
    { imageSrc: ImgExplosion08 },
    { imageSrc: ImgExplosion09 },
    { imageSrc: ImgExplosion10 },
    { imageSrc: ImgExplosion11 },
    { imageSrc: ImgExplosion12 },
    { imageSrc: ImgExplosion13 },
    { imageSrc: ImgExplosion14 },
    { imageSrc: ImgExplosion15 },
    { imageSrc: ImgExplosion16 },
    { imageSrc: ImgExplosion17 },
  ],
}

export const Tints: ReadonlyArray<number> = [
  0xff9999,
  0xffe699,
  0xccff99,
  0x99ffb3,
  0x99ffff,
  0x99b3ff,
  0xcc99ff,
  0xff99e6,
]

export const Maps: Partial<Record<string, MapProfile>> = {
  // "map.name" -> "MapProfile"
  'Village 10': {
    background: { imageSrc: ImgBackground },
    tiles: [
      { imageSrc: ImgTile1 },
      { imageSrc: ImgTile2 },
    ],
    obstacles: {
      // "objectId" -> "TilesetItem"
      1: { imageSrc: ImgBlocker2 },
      2: { imageSrc: ImgBlocker1 },
      3: { imageSrc: ImgBlocker3 },
    },
    paddingTop: 2,
  },
}

export const DownArrowTilesetItem: TilesetItem = {
  imageSrc: ImgDownArrow,
}
