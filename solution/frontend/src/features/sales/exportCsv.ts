import type { QueryClient } from '@tanstack/react-query'
import { api, type ApiParams } from '@/api'
import { salesKeys } from './queries'

/** CSV вкладки «Продажи» для текущих фильтров. «;» и BOM — чтобы Excel открыл без мастера. */
export async function exportSalesCsv(client: QueryClient, p: ApiParams) {
  const [kpi, monthly, categories, sellers] = await Promise.all([
    client.ensureQueryData({ queryKey: salesKeys.kpi(p), queryFn: () => api.getSalesKpi(p) }),
    client.ensureQueryData({ queryKey: salesKeys.monthly(p), queryFn: () => api.getSalesMonthly(p) }),
    client.ensureQueryData({ queryKey: salesKeys.categories(p), queryFn: () => api.getSalesCategories(p) }),
    client.ensureQueryData({ queryKey: salesKeys.topSellers(p), queryFn: () => api.getTopSellers(p) }),
  ])

  const rows: (string | number | null)[][] = [
    ['metric', 'value'],
    ...Object.entries(kpi),
    [],
    ['month', 'revenue', 'orders'],
    ...monthly.map((m) => [m.month, m.revenue, m.orders]),
    [],
    ['category', 'revenue', 'share'],
    ...categories.items.map((c) => [c.label, c.revenue, c.share]),
    ['other', categories.other.revenue, categories.other.share],
    ['uncategorized', categories.uncategorized.revenue, categories.uncategorized.share],
    [],
    ['rank', 'seller_id', 'city', 'state', 'orders', 'units', 'revenue', 'handover_breach_share'],
    ...sellers.map((s) => [s.rank, s.seller_id, s.city, s.state, s.orders, s.units, s.revenue, s.handover_breach_share]),
  ]

  const csv = '﻿' + rows.map((r) => r.map((v) => String(v ?? '').replace('.', ',')).join(';')).join('\n')
  const a = document.createElement('a')
  a.href = URL.createObjectURL(new Blob([csv], { type: 'text/csv;charset=utf-8' }))
  a.download = `sales_${p.from ?? ''}_${p.to ?? ''}${p.state ? `_${p.state}` : ''}${p.category ? `_${p.category}` : ''}.csv`
  a.click()
  URL.revokeObjectURL(a.href)
}
