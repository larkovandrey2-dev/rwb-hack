import type { ApiParams, CategoriesResponse } from '@/api'
import { formatAmount, formatMoney, formatShare } from '@/shared/format'
import { texts } from '@/shared/texts'
import { Block } from '@/shared/ui/Block/Block'
import { ChartCard } from '@/shared/ui/ChartCard/ChartCard'
import { DataTable } from '@/shared/ui/DataTable/DataTable'
import { useSalesCategories, useSalesKpi } from '../queries'
import s from './CategoryRevenue.module.css'

const t = texts.categories

interface Row {
  key: string
  label: string
  revenue: number
  share: number
  separated?: boolean
}

const toRows = (d: CategoriesResponse): Row[] => [
  ...d.items.map((c) => ({ key: c.code, label: c.label, revenue: c.revenue, share: c.share })),
  { key: 'other', label: t.other, revenue: d.other.revenue, share: d.other.share },
  { key: 'none', label: t.uncategorized, revenue: d.uncategorized.revenue, share: d.uncategorized.share, separated: true },
]

function Bars({ rows }: { rows: Row[] }) {
  const max = Math.max(...rows.map((r) => r.revenue))
  return (
    <ul className={s.list}>
      {rows.map((r) => (
        <li key={r.key} className={`${s.row} ${r.separated ? s.separated : ''}`}>
          <span className={s.label}>{r.label}</span>
          <span className={s.track}>
            <span className={`${s.bar} ${r.separated ? s.barLight : ''}`} style={{ width: `${(r.revenue / max) * 100}%` }} />
          </span>
          <span className={`${s.value} tabular`}>{formatAmount(r.revenue)}</span>
          <span className={`${s.share} tabular`}>{formatShare(r.share)}</span>
        </li>
      ))}
    </ul>
  )
}

export function CategoryRevenue({ params }: { params: ApiParams }) {
  const query = useSalesCategories(params)
  const kpi = useSalesKpi(params)
  const isEmpty = (d: CategoriesResponse) => d.total === 0

  // Сверка: сумма категорий из API должна совпасть с выручкой из KPI
  const total = query.data?.total
  const ok = total !== undefined && kpi.data !== undefined && Math.abs(total - kpi.data.revenue) < 0.005
  const footer =
    total !== undefined && kpi.data ? (
      ok ? (
        <span>
          ✓ <span className={s.muted}>{t.checkOk}</span> <b className="tabular">{formatMoney(total)}</b>
        </span>
      ) : (
        <span className={s.warn}>
          ⚠ {t.checkFail} {formatMoney(total)} ≠ {formatMoney(kpi.data.revenue)}
        </span>
      )
    ) : undefined

  return (
    <ChartCard
      title={t.title}
      subtitle={t.subtitle}
      footer={footer}
      chart={
        <Block query={query} isEmpty={isEmpty} rows={12}>
          {(d) => <Bars rows={toRows(d)} />}
        </Block>
      }
      table={
        <Block query={query} isEmpty={isEmpty} rows={12}>
          {(d) => (
            <DataTable
              compact
              rows={toRows(d)}
              rowKey={(r) => r.key}
              columns={[
                { header: t.category, render: (r) => r.label },
                { header: t.revenue, align: 'right', render: (r) => formatAmount(r.revenue) },
                { header: t.share, align: 'right', render: (r) => formatShare(r.share) },
              ]}
            />
          )}
        </Block>
      }
    />
  )
}
