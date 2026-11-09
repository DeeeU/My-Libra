import { describe, expect, it, vi } from 'vitest'
import { cleanQuery, createApi, formatApiError, type Fetcher } from '~/utils/api'

function setup() {
  const fetcher = vi.fn().mockResolvedValue({})
  return { fetcher, api: createApi('http://localhost:8000/api/', fetcher as unknown as Fetcher) }
}

describe('createApi', () => {
  it('一覧取得では空の条件を送らない', async () => {
    const { fetcher, api } = setup()
    await api.listItems({ status: '保有中', category: undefined, search: '' })
    expect(fetcher).toHaveBeenCalledWith('http://localhost:8000/api/items/', { query: { status: '保有中' } })
  })

  it('売却は POST /items/:id/sell/', async () => {
    const { fetcher, api } = setup()
    await api.sellItem('abc', { sale_price: 1000, sale_date: '2026-05-01' })
    expect(fetcher).toHaveBeenCalledWith('http://localhost:8000/api/items/abc/sell/', {
      method: 'POST',
      body: { sale_price: 1000, sale_date: '2026-05-01' },
    })
  })

  it('編集は PATCH、削除は DELETE', async () => {
    const { fetcher, api } = setup()
    await api.updateItem('abc', { name: 'x' })
    await api.deleteItem('abc')
    expect(fetcher).toHaveBeenNthCalledWith(1, 'http://localhost:8000/api/items/abc/', { method: 'PATCH', body: { name: 'x' } })
    expect(fetcher).toHaveBeenNthCalledWith(2, 'http://localhost:8000/api/items/abc/', { method: 'DELETE' })
  })

  it('集計は期間を渡す', async () => {
    const { fetcher, api } = setup()
    await api.getSummary('this_year')
    expect(fetcher).toHaveBeenCalledWith('http://localhost:8000/api/stats/summary/', { query: { period: 'this_year' } })
  })
})

describe('cleanQuery', () => {
  it('null・undefined・空文字を除く', () => {
    expect(cleanQuery({ a: 'x', b: '', c: undefined, d: null })).toEqual({ a: 'x' })
  })
})

describe('formatApiError', () => {
  it('DRF のフィールドエラーを文章にする', () => {
    expect(formatApiError({ data: { name: ['商品名を入力してください。'] } })).toBe('name: 商品名を入力してください。')
    expect(formatApiError({ data: { detail: 'Not found.' } })).toBe('Not found.')
  })

  it('接続できないときの文言', () => {
    expect(formatApiError(new Error('fetch failed'))).toContain('backend が起動しているか')
  })
})
