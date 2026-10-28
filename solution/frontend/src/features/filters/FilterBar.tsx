import { useEffect, useState } from 'react'
import { useIsFetching, useQuery } from '@tanstack/react-query'
import { api } from '@/api'
import { texts } from '@/shared/texts'
import { useFilters, type Filters } from '@/shared/useFilters'
import s from './FilterBar.module.css'

const t = texts.filters

/** Фильтры применяются по кнопке и сохраняются в URL */
export function FilterBar({ onExport }: { onExport?: () => void }) {
  const { filters, apply, reset } = useFilters()
  const [draft, setDraft] = useState<Filters>(filters)
  const options = useQuery({ queryKey: ['filters'], queryFn: api.getFilters })
  const fetching = useIsFetching({ queryKey: ['sales'] }) > 0
  const off = !api.supportsFilters

  const key = JSON.stringify(filters)
  // Подтягиваем черновик, если фильтры сменились через URL или «Сбросить»
  useEffect(() => setDraft(filters), [key]) // eslint-disable-line react-hooks/exhaustive-deps

  const set = (patch: Partial<Filters>) => setDraft({ ...draft, ...patch })
  const months = options.data?.months ?? []

  return (
    <form
      className={s.bar}
      onSubmit={(e) => {
        e.preventDefault()
        apply(draft)
      }}
    >
      <div className={s.period}>
        <span className={s.periodLabel}>{t.period}</span>
        <select disabled={off} className={`${s.select} ${s.month}`} value={draft.from} onChange={(e) => set({ from: e.target.value })}>
          {months.filter((m) => m <= draft.to).map((m) => <option key={m}>{m}</option>)}
        </select>
        <span className={s.dash}>—</span>
        <select disabled={off} className={`${s.select} ${s.month}`} value={draft.to} onChange={(e) => set({ to: e.target.value })}>
          {months.filter((m) => m >= draft.from).map((m) => <option key={m}>{m}</option>)}
        </select>
      </div>

      <div className={s.divider} />

      <select disabled={off} className={`${s.select} ${s.state}`} value={draft.state} onChange={(e) => set({ state: e.target.value })}>
        <option value="">{t.allStates}</option>
        {options.data?.states.map((st) => (
          <option key={st.code} value={st.code}>
            {st.code} · {st.name}
          </option>
        ))}
      </select>

      <select disabled={off} className={`${s.select} ${s.category}`} value={draft.category} onChange={(e) => set({ category: e.target.value })}>
        <option value="">{t.allCategories}</option>
        {options.data?.categories.map((c) => (
          <option key={c.code} value={c.code}>
            {c.label}
          </option>
        ))}
      </select>

      <button type="submit" className={s.apply} disabled={off}>
        {t.apply}
      </button>
      <button type="button" className={s.reset} onClick={reset} disabled={off}>
        {t.reset}
      </button>

      <div className={s.status}>
        {fetching ? t.fetching : off ? t.unsupported : t.done}
        {onExport && (
          <>
            {' · '}
            <button type="button" className={s.link} onClick={onExport}>
              CSV
            </button>
          </>
        )}
      </div>
    </form>
  )
}
