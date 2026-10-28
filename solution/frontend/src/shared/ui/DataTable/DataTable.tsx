import type { ReactNode } from 'react'
import s from './DataTable.module.css'

export interface Column<T> {
  header: string
  render: (row: T) => ReactNode
  align?: 'right'
  muted?: boolean
}

interface DataTableProps<T> {
  columns: Column<T>[]
  rows: T[]
  rowKey: (row: T) => string

  compact?: boolean
}

export function DataTable<T>({ columns, rows, rowKey, compact }: DataTableProps<T>) {
  return (
    <div className={s.scroll}>
      <table className={`${s.table} ${compact ? s.compact : ''}`}>
        <thead>
          <tr>
            {columns.map((c) => (
              <th key={c.header} style={{ textAlign: c.align ?? 'left' }}>
                {c.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map((row) => (
            <tr key={rowKey(row)}>
              {columns.map((c) => (
                <td key={c.header} className={`tabular ${c.muted ? s.muted : ''}`} style={{ textAlign: c.align ?? 'left' }}>
                  {c.render(row)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
