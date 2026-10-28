import s from './KpiTile.module.css'

export function KpiTile({ label, value }: { label: string; value?: string }) {
  return (
    <div className={s.tile}>
      <div className={s.label}>{label}</div>
      {value === undefined ? <div className={s.skeleton} /> : <div className={`${s.value} tabular`}>{value}</div>}
    </div>
  )
}
