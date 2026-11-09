import { describe, expect, it } from 'vitest'
import { formatDate, formatSignedYen, formatYen, profitClass, toISODate } from '~/utils/format'

describe('format', () => {
  it('円表記にする', () => {
    expect(formatYen(1500)).toBe('￥1,500')
    expect(formatYen(null)).toBe('-')
  })

  it('損益はプラスに + を付ける', () => {
    expect(formatSignedYen(800)).toBe('+￥800')
    expect(formatSignedYen(-300)).toBe('-￥300')
    expect(formatSignedYen(0)).toBe('￥0')
    expect(formatSignedYen(undefined)).toBe('-')
  })

  it('損益の色分け用クラス', () => {
    expect(profitClass(1)).toBe('profit-plus')
    expect(profitClass(-1)).toBe('profit-minus')
    expect(profitClass(0)).toBe('profit-zero')
    expect(profitClass(null)).toBe('profit-zero')
  })

  it('日付の変換', () => {
    expect(toISODate(new Date(2026, 0, 5))).toBe('2026-01-05')
    expect(formatDate('2026-01-05')).toBe('2026/01/05')
    expect(formatDate(null)).toBe('-')
  })
})
