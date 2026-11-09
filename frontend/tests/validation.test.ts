import { describe, expect, it } from 'vitest'
import type { ItemInput } from '~/types/api'
import { hasErrors, validateItemInput, validateSellInput } from '~/utils/validation'

const TODAY = '2026-05-31'
const valid: ItemInput = {
  name: 'スニーカー',
  category: '靴・スニーカー',
  purchase_price: 12000,
  purchase_date: '2026-05-01',
  condition: '新品',
  memo: '',
}

describe('validateItemInput', () => {
  it('正しい入力はエラーなし', () => {
    expect(hasErrors(validateItemInput(valid, TODAY))).toBe(false)
  })

  it('0円は許可する', () => {
    expect(validateItemInput({ ...valid, purchase_price: 0 }, TODAY)).toEqual({})
  })

  it.each([
    ['name', { name: '  ' }],
    ['category', { category: '' }],
    ['purchase_price', { purchase_price: null }],
    ['purchase_price', { purchase_price: -1 }],
    ['purchase_date', { purchase_date: '' }],
    ['purchase_date', { purchase_date: '2026-06-01' }],
  ] as const)('%s のエラー', (field, patch) => {
    expect(validateItemInput({ ...valid, ...patch }, TODAY)).toHaveProperty(field)
  })
})

describe('validateSellInput', () => {
  it('正しい入力はエラーなし', () => {
    expect(validateSellInput({ sale_price: 500, sale_date: '2026-05-10' }, '2026-05-01', TODAY)).toEqual({})
  })

  it('売却日が購入日より前ならエラー', () => {
    expect(validateSellInput({ sale_price: 500, sale_date: '2026-04-30' }, '2026-05-01', TODAY))
      .toHaveProperty('sale_date')
  })

  it('価格が空・負数ならエラー', () => {
    expect(validateSellInput({ sale_price: null, sale_date: TODAY }, '2026-05-01', TODAY)).toHaveProperty('sale_price')
    expect(validateSellInput({ sale_price: -1, sale_date: TODAY }, '2026-05-01', TODAY)).toHaveProperty('sale_price')
  })
})
