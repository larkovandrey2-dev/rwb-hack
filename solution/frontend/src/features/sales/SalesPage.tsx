import { definitions, texts } from '@/shared/texts'
import { useFilters } from '@/shared/useFilters'
import { CategoryRevenue } from './components/CategoryRevenue'
import { SalesDynamics } from './components/SalesDynamics'
import { SalesKpis } from './components/SalesKpis'
import { TopSellers } from './components/TopSellers'
import s from './SalesPage.module.css'

export function SalesPage() {
  const { params } = useFilters()

  return (
    <div className={s.page}>
      <SalesKpis params={params} />
      <SalesDynamics params={params} />
      <div className={s.split}>
        <CategoryRevenue params={params} />
        <TopSellers params={params} />
      </div>
      <details className={s.details}>
        <summary className={s.summary}>{texts.footer.quality} ⌄</summary>
        <ul className={s.defs}>
          {definitions.map((d) => (
            <li key={d}>{d}</li>
          ))}
        </ul>
      </details>
    </div>
  )
}
