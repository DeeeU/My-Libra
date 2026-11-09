import { ITEM_CONDITIONS, type ItemInput, type SellInput } from '~/types/api'

export type FieldErrors = Partial<Record<string, string>>

const DATE_RE = /^\d{4}-\d{2}-\d{2}$/

function isValidPrice(value: number | null): value is number {
  return typeof value === 'number' && Number.isFinite(value)
}

/** 仕様書 8.3: 必須チェック・価格の負数チェック・日付の妥当性チェック */
export function validateItemInput(input: ItemInput, today: string): FieldErrors {
  const errors: FieldErrors = {}
  if (!input.name.trim()) errors.name = '商品名を入力してください'
  if (!input.category) errors.category = 'カテゴリーを選択してください'
  if (!isValidPrice(input.purchase_price)) errors.purchase_price = '購入価格を入力してください'
  else if (input.purchase_price < 0) errors.purchase_price = '購入価格は0円以上にしてください'
  if (!DATE_RE.test(input.purchase_date)) errors.purchase_date = '購入日を入力してください'
  else if (input.purchase_date > today) errors.purchase_date = '未来の日付は指定できません'
  if (!ITEM_CONDITIONS.includes(input.condition)) errors.condition = '状態を選択してください'
  return errors
}

export function validateSellInput(input: SellInput, purchaseDate: string, today: string): FieldErrors {
  const errors: FieldErrors = {}
  if (!isValidPrice(input.sale_price)) errors.sale_price = '売却価格を入力してください'
  else if (input.sale_price < 0) errors.sale_price = '売却価格は0円以上にしてください'
  if (!DATE_RE.test(input.sale_date)) errors.sale_date = '売却日を入力してください'
  else if (input.sale_date > today) errors.sale_date = '未来の日付は指定できません'
  else if (input.sale_date < purchaseDate) errors.sale_date = '売却日は購入日以降にしてください'
  return errors
}

export function hasErrors(errors: FieldErrors): boolean {
  return Object.keys(errors).length > 0
}
