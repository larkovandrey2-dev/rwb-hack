




import categoryList from './mock/data/categories.json'
import extraCategories from './mock/data/extra-categories.json'
import type { ApiClient, CategoriesResponse } from './types'

const baseUrl = import.meta.env.VITE_API_URL ?? ''

type Decimal = string | number | null

interface Overview {
  revenue: Decimal
  average_order_value: Decimal
  average_lines: Decimal
  average_units: Decimal
  delivered_orders: number
  customers: number
  repeat_customers: number
  repeat_pct: Decimal
}

interface MonthRow {
  month: string
  delivered_orders: number
  revenue: Decimal
}

interface CategoryRow {
  category_name: string
  category_english: string | null
  revenue: Decimal
  revenue_pct: Decimal
}

interface SellerRow {
  seller_id: string
  seller_city: string | null
  seller_state: string | null
  delivered_orders: number
  units: number
  revenue: Decimal
}


const UNKNOWN_CATEGORY = 'UNKNOWN'
const TOP_CATEGORIES = 10
const TOP_SELLERS = 10

const num = (v: Decimal) => (v === null ? 0 : Number(v))
const round2 = (n: number) => Math.round(n * 100) / 100


const labels = new Map([...categoryList.items, ...extraCategories].map((c) => [c.code, c.label]))
const categoryLabel = (row: CategoryRow) =>
  labels.get(row.category_name) ?? (row.category_english ?? row.category_name).replace(/_/g, ' ')

async function get<T>(path: string): Promise<T[]> {
  const res = await fetch(`${baseUrl}/api/${path}`)
  if (!res.ok) throw new Error(`${res.status} ${res.statusText}`)
  const body = (await res.json()) as { data: T[] }
  return body.data
}

const getMonthly = async () =>
  (await get<MonthRow>('sales/monthly')).map((m) => ({
    month: m.month.slice(0, 7),
    orders: m.delivered_orders,
    revenue: num(m.revenue),
  }))

export const httpApi: ApiClient = {
  supportsFilters: false,

  getFilters: async () => ({
    months: (await getMonthly()).map((m) => m.month),
    states: [],
    categories: [],
  }),

  getSalesKpi: async () => {
    const [o] = await get<Overview>('overview')
    if (!o) throw new Error('Пустой ответ /api/overview')
    return {
      revenue: num(o.revenue),
      orders: o.delivered_orders,
      avg_check: num(o.average_order_value),
      avg_lines_per_order: num(o.average_lines),
      avg_units_per_order: num(o.average_units),
      customers: o.customers,
      repeat_customers_share: num(o.repeat_pct) / 100,
    }
  },

  getSalesMonthly: getMonthly,

  getSalesCategories: async (): Promise<CategoriesResponse> => {
    const rows = await get<CategoryRow>('categories')
    const known = rows.filter((r) => r.category_name !== UNKNOWN_CATEGORY)
    const unknown = rows.find((r) => r.category_name === UNKNOWN_CATEGORY)
    const rest = known.slice(TOP_CATEGORIES)
    return {
      total: round2(rows.reduce((sum, r) => sum + num(r.revenue), 0)),
      items: known.slice(0, TOP_CATEGORIES).map((r) => ({
        code: r.category_name,
        label: categoryLabel(r),
        revenue: num(r.revenue),
        share: num(r.revenue_pct) / 100,
      })),
      other: {
        count: rest.length,
        revenue: round2(rest.reduce((sum, r) => sum + num(r.revenue), 0)),
        share: rest.reduce((sum, r) => sum + num(r.revenue_pct), 0) / 100,
      },
      uncategorized: {
        revenue: num(unknown?.revenue ?? 0),
        share: num(unknown?.revenue_pct ?? 0) / 100,
      },
    }
  },

  getTopSellers: async () =>
    (await get<SellerRow>(`sellers?limit=${TOP_SELLERS}`)).map((s, i) => ({
      rank: i + 1,
      seller_id: s.seller_id,
      city: s.seller_city ?? '',
      state: s.seller_state ?? '',
      orders: s.delivered_orders,
      units: s.units,
      revenue: num(s.revenue),
      handover_breach_share: null,
    })),
}
