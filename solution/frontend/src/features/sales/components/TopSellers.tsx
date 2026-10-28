import type { ApiParams } from '@/api'
import { formatAmount, formatInt, formatShare } from '@/shared/format'
import { texts } from '@/shared/texts'
import { Block } from '@/shared/ui/Block/Block'
import { ChartCard } from '@/shared/ui/ChartCard/ChartCard'
import { DataTable } from '@/shared/ui/DataTable/DataTable'
import { useTopSellers } from '../queries'
import s from './TopSellers.module.css'

const t = texts.sellers

export function TopSellers({ params }: { params: ApiParams }) {
  const query = useTopSellers(params)

  return (
    <ChartCard title={t.title}>
      <Block query={query} isEmpty={(rows) => rows.length === 0} rows={10}>
        {(rows) => (
          <div className={s.bleed}>
            <DataTable
              rows={rows}
              rowKey={(r) => r.seller_id}
              columns={[
                { header: '', muted: true, render: (r) => r.rank },
                { header: t.seller, render: (r) => r.seller_id.slice(0, 6) },
                {
                  header: t.city,
                  align: 'right',
                  render: (r) => (
                    <>
                      {r.city} <span className={s.state}>{r.state}</span>
                    </>
                  ),
                },
                { header: t.orders, align: 'right', render: (r) => formatInt(r.orders) },
                { header: t.units, align: 'right', render: (r) => formatInt(r.units) },
                { header: t.revenue, align: 'right', render: (r) => formatAmount(r.revenue) },
                { header: t.breach, align: 'right', render: (r) => (r.handover_breach_share === null ? '—' : formatShare(r.handover_breach_share)) },
              ]}
            />
          </div>
        )}
      </Block>
    </ChartCard>
  )
}
