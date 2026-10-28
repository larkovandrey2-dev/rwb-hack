// Контракт API. Доли — дробью 0..1, деньги — числом в BRL, месяцы — YYYY-MM.

export interface ApiParams {
  from?: string
  to?: string
  state?: string
  category?: string
}

export interface FiltersResponse {
  months: string[]
  states: { code: string; name: string }[]
  categories: { code: string; label: string }[]
}

export interface SalesKpi {
  revenue: number
  orders: number
  avg_check: number
  avg_lines_per_order: number
  avg_units_per_order: number
  customers: number
  repeat_customers_share: number
}

export interface MonthlySales {
  month: string
  orders: number
  revenue: number
}

export interface CategoryRevenue {
  code: string
  label: string
  revenue: number
  share: number
}

export interface CategoriesResponse {
  total: number
  items: CategoryRevenue[]
  other: { count: number; revenue: number; share: number }
  uncategorized: { revenue: number; share: number }
}

export interface TopSeller {
  rank: number
  seller_id: string
  city: string
  state: string
  orders: number
  units: number
  revenue: number
  /** null — бэк не отдаёт показатель */
  handover_breach_share: number | null
}

export interface ApiClient {
  /** Принимает ли бэк фильтры from / to / state / category */
  supportsFilters: boolean
  getFilters(): Promise<FiltersResponse>
  getSalesKpi(params: ApiParams): Promise<SalesKpi>
  getSalesMonthly(params: ApiParams): Promise<MonthlySales[]>
  getSalesCategories(params: ApiParams): Promise<CategoriesResponse>
  getTopSellers(params: ApiParams): Promise<TopSeller[]>
}
