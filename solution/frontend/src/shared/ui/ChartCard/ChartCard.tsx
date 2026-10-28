import { useState, type ReactNode } from 'react'
import { texts } from '@/shared/texts'
import s from './ChartCard.module.css'

interface ChartCardProps {
  title: string
  subtitle?: string
  meta?: ReactNode

  chart?: ReactNode
  table?: ReactNode
  children?: ReactNode
  footer?: ReactNode
}

export function ChartCard({ title, subtitle, meta, chart, table, children, footer }: ChartCardProps) {
  const [view, setView] = useState<'chart' | 'table'>('chart')

  return (
    <section className={s.card}>
      <header className={s.header}>
        <div>
          <h2 className={s.title}>{title}</h2>
          {subtitle && <div className={s.subtitle}>{subtitle}</div>}
        </div>
        {meta && <div className={s.meta}>{meta}</div>}
      </header>

      <div className={s.body}>{children ?? (view === 'chart' ? chart : table)}</div>

      {chart && table && (
        <div className={s.toggle}>
          {(['chart', 'table'] as const).map((v) => (
            <button key={v} type="button" className={view === v ? s.toggleActive : s.toggleBtn} onClick={() => setView(v)}>
              {texts.view[v]}
            </button>
          ))}
        </div>
      )}

      {footer && <footer className={s.footer}>{footer}</footer>}
    </section>
  )
}
