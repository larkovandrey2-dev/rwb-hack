// Форматирование ru-RU: пробелы между разрядами, запятая в дробной части, деньги — R$.

const int = new Intl.NumberFormat('ru-RU', { maximumFractionDigits: 0 })
const money = new Intl.NumberFormat('ru-RU', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
const pct = new Intl.NumberFormat('ru-RU', { minimumFractionDigits: 1, maximumFractionDigits: 1 })

export const formatInt = (n: number) => int.format(n)
export const formatAmount = (n: number) => money.format(n)
const NBSP = ' '

export const formatMoney = (n: number) => `R$${NBSP}${money.format(n)}`
export const formatShare = (share: number) => `${pct.format(share * 100)}%`
export const formatMillions = (n: number) => `${money.format(n / 1_000_000)}${NBSP}млн`

const MONTHS_SHORT = ['янв', 'фев', 'март', 'апр', 'май', 'июнь', 'июль', 'авг', 'сент', 'окт', 'нояб', 'дек']
const MONTHS_LONG = ['январь', 'февраль', 'март', 'апрель', 'май', 'июнь', 'июль', 'август', 'сентябрь', 'октябрь', 'ноябрь', 'декабрь']

/** «2016-09» → «сент '16» */
export function formatMonthShort(month: string) {
  const [y = '', m = '1'] = month.split('-')
  return `${MONTHS_SHORT[Number(m) - 1]} '${y.slice(2)}`
}

/** «2016-09» → «сентябрь 2016» */
export function formatMonthLong(month: string) {
  const [y = '', m = '1'] = month.split('-')
  return `${MONTHS_LONG[Number(m) - 1]} ${y}`
}

/** 24 → «24 месяца» */
export function formatMonthsCount(n: number) {
  const rule = new Intl.PluralRules('ru-RU').select(n)
  return `${n} ${rule === 'one' ? 'месяц' : rule === 'few' ? 'месяца' : 'месяцев'}`
}
