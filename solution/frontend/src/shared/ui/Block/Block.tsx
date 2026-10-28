import type { ReactNode } from 'react'
import type { UseQueryResult } from '@tanstack/react-query'
import { texts } from '@/shared/texts'
import s from './Block.module.css'

interface BlockProps<T> {
  query: UseQueryResult<T>
  isEmpty?: (data: T) => boolean

  rows?: number
  children: (data: T) => ReactNode
}


export function Block<T>({ query, isEmpty, rows = 6, children }: BlockProps<T>) {
  if (query.isPending) {
    return (
      <div className={s.lines}>
        {Array.from({ length: rows }, (_, i) => (
          <div key={i} className={s.skeleton} />
        ))}
      </div>
    )
  }
  if (query.isError) {
    return (
      <div className={s.state}>
        {texts.state.error}
        <button type="button" className={s.retry} onClick={() => void query.refetch()}>
          {texts.state.retry}
        </button>
      </div>
    )
  }
  if (isEmpty?.(query.data)) return <div className={s.state}>{texts.state.empty}</div>
  return <>{children(query.data)}</>
}
