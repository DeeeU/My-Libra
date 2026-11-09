const yen = new Intl.NumberFormat('ja-JP', { style: 'currency', currency: 'JPY', maximumFractionDigits: 0 })

export function formatYen(value: number | null | undefined): string {
  if (value === null || value === undefined) return '-'
  return yen.format(value)
}

/** 損益用。プラスには + を付ける */
export function formatSignedYen(value: number | null | undefined): string {
  if (value === null || value === undefined) return '-'
  return value > 0 ? `+${yen.format(value)}` : yen.format(value)
}

/** プラス=緑、マイナス=赤（仕様書 3.3.1） */
export function profitClass(value: number | null | undefined): string {
  if (!value) return 'profit-zero'
  return value > 0 ? 'profit-plus' : 'profit-minus'
}

/** ローカル日付を YYYY-MM-DD で返す */
export function toISODate(date: Date): string {
  const y = date.getFullYear()
  const m = String(date.getMonth() + 1).padStart(2, '0')
  const d = String(date.getDate()).padStart(2, '0')
  return `${y}-${m}-${d}`
}

export function todayISO(): string {
  return toISODate(new Date())
}

export function formatDate(iso: string | null | undefined): string {
  if (!iso) return '-'
  const [y, m, d] = iso.split('-')
  return `${y}/${m}/${d}`
}
