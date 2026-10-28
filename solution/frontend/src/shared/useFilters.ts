import { useSearchParams } from 'react-router-dom'
import type { ApiParams } from '@/api'

export interface Filters {
  from: string
  to: string
  state: string
  category: string
}

export const DEFAULT_FILTERS: Filters = { from: '2016-09', to: '2018-08', state: '', category: '' }

const KEYS = ['from', 'to', 'state', 'category'] as const

/** Применённые фильтры хранятся в query-параметрах URL */
export function useFilters() {
  const [search, setSearch] = useSearchParams()

  const filters: Filters = { ...DEFAULT_FILTERS }
  for (const key of KEYS) filters[key] = search.get(key) ?? filters[key]

  const params: ApiParams = {}
  for (const key of KEYS) if (filters[key]) params[key] = filters[key]

  const apply = (next: Filters) => {
    const s = new URLSearchParams()
    for (const key of KEYS) if (next[key]) s.set(key, next[key])
    setSearch(s)
  }

  return { filters, params, apply, reset: () => setSearch({}) }
}
