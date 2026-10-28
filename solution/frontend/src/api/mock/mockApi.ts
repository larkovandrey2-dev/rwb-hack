


import type { ApiClient, ApiParams, CategoriesResponse } from '../types'
import categories from './data/categories.json'
import extraCategories from './data/extra-categories.json'
import kpi from './data/kpi.json'
import monthly from './data/monthly.json'
import states from './data/states.json'
import topSellers from './data/top-sellers.json'

const DELAY_MS = 300

const round2 = (n: number) => Math.round(n * 100) / 100
const respond = <T>(build: () => T) => new Promise<T>((r) => setTimeout(() => r(build()), DELAY_MS))

const allCategories = [...categories.items, ...extraCategories]

function sliceFactor(p: ApiParams, withPeriod = true): number {
  const period = withPeriod
    ? monthly
        .filter((m) => (!p.from || m.month >= p.from) && (!p.to || m.month <= p.to))
        .reduce((sum, m) => sum + m.revenue, 0) / kpi.revenue
    : 1
  const state = p.state ? (states.find((s) => s.code === p.state)?.weight ?? 0) : 1
  const category = p.category
    ? (allCategories.find((c) => c.code === p.category)?.revenue ?? 0) / kpi.revenue
    : 1
  return period * state * category
}

function buildCategories(p: ApiParams): CategoriesResponse {
  const f = sliceFactor(p)
  const total = round2(kpi.revenue * f)
  const share = (revenue: number) => (total ? revenue / total : 0)

  if (p.category) {
    const label = allCategories.find((c) => c.code === p.category)?.label ?? p.category
    return {
      total,
      items: [{ code: p.category, label, revenue: total, share: 1 }],
      other: { count: 0, revenue: 0, share: 0 },
      uncategorized: { revenue: 0, share: 0 },
    }
  }

  const items = categories.items.map((c) => {
    const revenue = round2(c.revenue * f)
    return { ...c, revenue, share: share(revenue) }
  })
  const uncategorized = round2(categories.uncategorized.revenue * f)

  const other = round2(total - uncategorized - items.reduce((sum, c) => sum + c.revenue, 0))
  return {
    total,
    items,
    other: { count: categories.other.count, revenue: other, share: share(other) },
    uncategorized: { revenue: uncategorized, share: share(uncategorized) },
  }
}

export const mockApi: ApiClient = {
  supportsFilters: true,

  getFilters: () =>
    respond(() => ({
      months: monthly.map((m) => m.month),
      states: states.map(({ code, name }) => ({ code, name })),
      categories: allCategories.map(({ code, label }) => ({ code, label })),
    })),

  getSalesKpi: (p) =>
    respond(() => {
      const f = sliceFactor(p)
      return {
        ...kpi,
        revenue: round2(kpi.revenue * f),
        orders: Math.round(kpi.orders * f),
        customers: Math.round(kpi.customers * f),
      }
    }),

  getSalesMonthly: (p) =>
    respond(() => {
      const f = sliceFactor(p, false)
      return monthly
        .filter((m) => (!p.from || m.month >= p.from) && (!p.to || m.month <= p.to))
        .map((m) => ({ month: m.month, orders: Math.round(m.orders * f), revenue: round2(m.revenue * f) }))
    }),

  getSalesCategories: (p) => respond(() => buildCategories(p)),

  getTopSellers: (p) =>
    respond(() => {
      const f = sliceFactor(p)
      if (!f) return []
      return topSellers.map((s) => ({
        ...s,
        orders: Math.max(1, Math.round(s.orders * f)),
        units: Math.max(1, Math.round(s.units * f)),
        revenue: round2(s.revenue * f),
      }))
    }),
}
