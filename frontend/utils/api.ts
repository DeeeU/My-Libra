import type { Category, Item, ItemInput, ItemQuery, Period, SellInput, Summary } from '~/types/api'

/** $fetch 互換の関数（テストではモックを渡す） */
export type Fetcher = <T>(
  url: string,
  options?: { method?: string; body?: unknown; query?: Record<string, unknown> },
) => Promise<T>

/** 空の検索条件を送らないようにする */
export function cleanQuery(query: object): Record<string, string> {
  return Object.fromEntries(
    Object.entries(query).filter(([, v]) => v !== undefined && v !== null && v !== ''),
  ) as Record<string, string>
}

export function createApi(baseURL: string, fetcher: Fetcher) {
  const url = (path: string) => `${baseURL.replace(/\/+$/, '')}${path}`

  return {
    listItems: (query: ItemQuery = {}) => fetcher<Item[]>(url('/items/'), { query: cleanQuery(query) }),
    getItem: (id: string) => fetcher<Item>(url(`/items/${id}/`)),
    createItem: (input: ItemInput) => fetcher<Item>(url('/items/'), { method: 'POST', body: input }),
    updateItem: (id: string, input: Partial<ItemInput>) =>
      fetcher<Item>(url(`/items/${id}/`), { method: 'PATCH', body: input }),
    deleteItem: (id: string) => fetcher<void>(url(`/items/${id}/`), { method: 'DELETE' }),
    sellItem: (id: string, input: SellInput) =>
      fetcher<Item>(url(`/items/${id}/sell/`), { method: 'POST', body: input }),
    unsellItem: (id: string) => fetcher<Item>(url(`/items/${id}/unsell/`), { method: 'POST' }),
    listCategories: () => fetcher<Category[]>(url('/categories/')),
    getSummary: (period: Period) => fetcher<Summary>(url('/stats/summary/'), { query: { period } }),
  }
}

export type Api = ReturnType<typeof createApi>

/**
 * DRF のエラーレスポンスを表示用の文章にする。
 * 例: { name: ["商品名を入力してください。"] } → "name: 商品名を入力してください。"
 */
export function formatApiError(error: unknown): string {
  const data = (error as { data?: unknown })?.data
  if (data && typeof data === 'object') {
    const messages = Object.entries(data as Record<string, unknown>).map(([key, value]) => {
      const text = Array.isArray(value) ? value.join(' ') : String(value)
      return key === 'detail' || key === 'non_field_errors' ? text : `${key}: ${text}`
    })
    if (messages.length) return messages.join('\n')
  }
  return 'サーバーに接続できませんでした。backend が起動しているか確認してください。'
}
