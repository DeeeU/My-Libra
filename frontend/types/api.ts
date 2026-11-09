// backend (Django REST Framework) のレスポンス型

export const ITEM_CONDITIONS = ['新品', '中古', '傷あり', 'ジャンク'] as const
export type ItemCondition = (typeof ITEM_CONDITIONS)[number]

export const ITEM_STATUSES = ['保有中', '売却済み'] as const
export type ItemStatus = (typeof ITEM_STATUSES)[number]

export interface Category {
  id: string
  name: string
  icon_name: string
  is_custom: boolean
  sort_order: number
}

export interface Item {
  id: string
  name: string
  category: string
  purchase_price: number
  purchase_date: string // YYYY-MM-DD
  condition: ItemCondition
  memo: string
  status: ItemStatus
  sale_price: number | null
  sale_date: string | null
  profit: number | null
  created_at: string
  updated_at: string
}

export interface ItemInput {
  name: string
  category: string
  purchase_price: number | null
  purchase_date: string
  condition: ItemCondition
  memo: string
}

export interface SellInput {
  sale_price: number | null
  sale_date: string
}

export type ItemOrdering =
  | 'purchase_date' | '-purchase_date'
  | 'purchase_price' | '-purchase_price'
  | 'name' | '-name'

export interface ItemQuery {
  status?: ItemStatus
  category?: string
  condition?: ItemCondition
  search?: string
  ordering?: ItemOrdering
}

export const PERIODS = [
  { value: 'this_month', label: '今月' },
  { value: '3_months', label: '3ヶ月' },
  { value: '6_months', label: '6ヶ月' },
  { value: 'this_year', label: '今年' },
  { value: 'all', label: '全期間' },
] as const
export type Period = (typeof PERIODS)[number]['value']

export interface Summary {
  period: Period
  start_date: string | null
  total_purchase: number
  total_sale: number
  total_profit: number
  owned_count: number
  sold_count: number
  by_category: { category: string; amount: number }[]
  monthly: { month: string; purchase: number; profit: number }[]
}
