import type { ApiParams } from '@/api'
import { formatInt, formatMoney } from '@/shared/format'
import { texts } from '@/shared/texts'
import { KpiTile } from '@/shared/ui/KpiTile/KpiTile'
import { useSalesKpi } from '../queries'
import s from './SalesKpis.module.css'

export function SalesKpis({ params }: { params: ApiParams }) {
  const { data, isError, refetch } = useSalesKpi(params)
  const t = texts.kpi

  return (
    <section className={s.row}>
      <KpiTile label={t.revenue} value={data && formatMoney(data.revenue)} />
      <KpiTile label={t.orders} value={data && formatInt(data.orders)} />
      <KpiTile label={t.avgCheck} value={data && formatMoney(data.avg_check)} />
      <KpiTile label={t.customers} value={data && formatInt(data.customers)} />
      {isError && (
        <button type="button" className={s.error} onClick={() => void refetch()}>
          {texts.state.error} · {texts.state.retry}
        </button>
      )}
    </section>
  )
}
