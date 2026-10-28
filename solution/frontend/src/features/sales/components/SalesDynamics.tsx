import { Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from 'recharts'
import type { ApiParams, MonthlySales } from '@/api'
import { formatAmount, formatInt, formatMillions, formatMonthLong, formatMonthShort, formatMonthsCount } from '@/shared/format'
import { texts } from '@/shared/texts'
import { Block } from '@/shared/ui/Block/Block'
import { ChartCard } from '@/shared/ui/ChartCard/ChartCard'
import { DataTable } from '@/shared/ui/DataTable/DataTable'
import { useSalesMonthly } from '../queries'
import s from './SalesDynamics.module.css'

const t = texts.dynamics
const axisTick = { fill: '#888', fontSize: 12 }

interface ChartProps {
  data: MonthlySales[]
  metric: 'revenue' | 'orders'
  title: string
  formatAxis: (n: number) => string
  formatValue: (n: number) => string
}

function MonthlyChart({ data, metric, title, formatAxis, formatValue }: ChartProps) {

  const top = Math.max(1, ...data.map((d) => d[metric])) * 1.15
  const yTicks = [0, top / 3, (top * 2) / 3, top]

  const xTicks = data.map((d) => d.month).filter((_, i) => i % 3 === 0 || i === data.length - 1)

  return (
    <figure className={s.figure}>
      <figcaption className={s.caption}>{title}</figcaption>
      <ResponsiveContainer width="100%" height={150}>
        <BarChart data={data} syncId="dynamics" margin={{ top: 8, right: 8, bottom: 0, left: 0 }}>
          <CartesianGrid vertical={false} stroke="#e9e9e9" />
          <XAxis dataKey="month" ticks={xTicks} interval={0} tickFormatter={formatMonthShort} tickLine={false} axisLine={{ stroke: '#e9e9e9' }} tick={axisTick} />
          <YAxis ticks={yTicks} domain={[0, top]} tickFormatter={formatAxis} tickLine={false} axisLine={false} tick={axisTick} width={76} />
          <Tooltip
            cursor={{ fill: 'rgba(0,0,0,0.04)' }}
            isAnimationActive={false}
            labelFormatter={(m: string) => formatMonthLong(m)}
            formatter={(v: number) => [formatValue(v), title]}
            contentStyle={{ border: '1px solid #ddd', fontSize: 12 }}
          />
          <Bar dataKey={metric} fill="#888" activeBar={{ fill: '#5f5f5f' }} maxBarSize={38} isAnimationActive={false} />
        </BarChart>
      </ResponsiveContainer>
    </figure>
  )
}

export function SalesDynamics({ params }: { params: ApiParams }) {
  const query = useSalesMonthly(params)
  const isEmpty = (rows: MonthlySales[]) => rows.every((r) => r.orders === 0)

  const chart = (
    <Block query={query} isEmpty={isEmpty} rows={10}>
      {(rows) => (
        <>
          <MonthlyChart data={rows} metric="revenue" title={t.revenue} formatAxis={formatMillions} formatValue={formatAmount} />
          <MonthlyChart data={rows} metric="orders" title={t.orders} formatAxis={formatInt} formatValue={formatInt} />
        </>
      )}
    </Block>
  )

  const table = (
    <Block query={query} isEmpty={isEmpty}>
      {(rows) => (
        <DataTable
          compact
          rows={rows}
          rowKey={(r) => r.month}
          columns={[
            { header: t.month, render: (r) => formatMonthLong(r.month) },
            { header: t.revenue, align: 'right', render: (r) => formatAmount(r.revenue) },
            { header: t.orders, align: 'right', render: (r) => formatInt(r.orders) },
          ]}
        />
      )}
    </Block>
  )


  return <ChartCard title={t.title} meta={query.data && formatMonthsCount(query.data.length)} chart={chart} table={table} />
}
