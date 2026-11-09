import { mount } from '@vue/test-utils'
import { describe, expect, it } from 'vitest'
import ItemForm from '~/components/ItemForm.vue'
import SellForm from '~/components/SellForm.vue'
import SummaryCards from '~/components/SummaryCards.vue'
import type { Category, Summary } from '~/types/api'
import { todayISO } from '~/utils/format'

const categories: Category[] = [
  { id: '1', name: 'カードゲーム', icon_name: 'x', is_custom: false, sort_order: 0 },
  { id: '2', name: 'フィギュア', icon_name: 'y', is_custom: false, sort_order: 1 },
]

describe('ItemForm', () => {
  it('必須項目が空だと submit しない', async () => {
    const wrapper = mount(ItemForm, { props: { categories } })
    await wrapper.find('form').trigger('submit')
    expect(wrapper.emitted('submit')).toBeUndefined()
    expect(wrapper.text()).toContain('商品名を入力してください')
    expect(wrapper.text()).toContain('購入価格を入力してください')
  })

  it('入力が正しければ値を emit する', async () => {
    const wrapper = mount(ItemForm, { props: { categories } })
    await wrapper.find('input[name="name"]').setValue('  リザードン  ')
    await wrapper.find('select[name="category"]').setValue('カードゲーム')
    await wrapper.find('input[name="purchase_price"]').setValue('4500')
    await wrapper.find('select[name="condition"]').setValue('中古')
    await wrapper.find('form').trigger('submit')

    expect(wrapper.emitted('submit')?.[0]?.[0]).toEqual({
      name: 'リザードン',
      category: 'カードゲーム',
      purchase_price: 4500,
      purchase_date: todayISO(),
      condition: '中古',
      memo: '',
    })
  })

  it('initial の値で初期表示する（編集用）', () => {
    const wrapper = mount(ItemForm, {
      props: { categories, initial: { name: '既存', category: 'フィギュア', purchase_price: 100 } },
    })
    expect((wrapper.find('input[name="name"]').element as HTMLInputElement).value).toBe('既存')
    expect((wrapper.find('select[name="category"]').element as HTMLSelectElement).value).toBe('フィギュア')
  })
})

describe('SellForm', () => {
  it('入力中に損益をプレビューする', async () => {
    const wrapper = mount(SellForm, { props: { purchasePrice: 1000, purchaseDate: '2026-01-01' } })
    await wrapper.find('input[name="sale_price"]').setValue('1800')
    expect(wrapper.find('.preview').text()).toContain('+￥800')
    expect(wrapper.find('.preview span').classes()).toContain('profit-plus')
  })

  it('売却日が購入日より前だと submit しない', async () => {
    const wrapper = mount(SellForm, { props: { purchasePrice: 1000, purchaseDate: '2026-01-10' } })
    await wrapper.find('input[name="sale_price"]').setValue('500')
    await wrapper.find('input[name="sale_date"]').setValue('2026-01-09')
    await wrapper.find('form').trigger('submit')
    expect(wrapper.emitted('submit')).toBeUndefined()
    expect(wrapper.text()).toContain('売却日は購入日以降にしてください')
  })

  it('正しい入力を emit する', async () => {
    const wrapper = mount(SellForm, { props: { purchasePrice: 1000, purchaseDate: '2026-01-10' } })
    await wrapper.find('input[name="sale_price"]').setValue('700')
    await wrapper.find('input[name="sale_date"]').setValue('2026-01-20')
    await wrapper.find('form').trigger('submit')
    expect(wrapper.emitted('submit')?.[0]?.[0]).toEqual({ sale_price: 700, sale_date: '2026-01-20' })
  })
})

describe('SummaryCards', () => {
  it('集計値を表示し、損失は赤にする', () => {
    const summary: Summary = {
      period: 'all', start_date: null,
      total_purchase: 3800, total_sale: 3200, total_profit: -600,
      owned_count: 1, sold_count: 2, by_category: [], monthly: [],
    }
    const wrapper = mount(SummaryCards, { props: { summary } })
    expect(wrapper.find('[data-test="total-purchase"]').text()).toBe('￥3,800')
    expect(wrapper.find('[data-test="total-profit"] span').classes()).toContain('profit-minus')
    expect(wrapper.find('[data-test="sold-count"]').text()).toBe('2 件')
  })
})
