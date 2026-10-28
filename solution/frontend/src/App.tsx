import { QueryClient, QueryClientProvider, useQueryClient } from '@tanstack/react-query'
import { BrowserRouter, Navigate, NavLink, Route, Routes, useLocation } from 'react-router-dom'
import { DeliveryPage } from '@/features/delivery/DeliveryPage'
import { FilterBar } from '@/features/filters/FilterBar'
import { exportSalesCsv } from '@/features/sales/exportCsv'
import { SalesPage } from '@/features/sales/SalesPage'
import { texts } from '@/shared/texts'
import { useFilters } from '@/shared/useFilters'
import s from './App.module.css'

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 5 * 60_000, retry: 1, refetchOnWindowFocus: false } },
})

function Layout() {
  const { pathname, search } = useLocation()
  const { params } = useFilters()
  const client = useQueryClient()
  // CSV пока есть только у вкладки «Продажи»
  const onExport = pathname === '/sales' ? () => void exportSalesCsv(client, params) : undefined

  return (
    <div className={s.shell}>
      <header className={s.header}>
        <nav className={s.tabs}>
          {/* search переносим, чтобы фильтры сохранялись при смене вкладки */}
          <NavLink to={{ pathname: '/sales', search }} className={({ isActive }) => (isActive ? s.tabActive : s.tab)}>
            {texts.nav.sales}
          </NavLink>
          <NavLink to={{ pathname: '/delivery', search }} className={({ isActive }) => (isActive ? s.tabActive : s.tab)}>
            {texts.nav.delivery}
          </NavLink>
        </nav>
        <button type="button" className={s.csv} onClick={onExport} disabled={!onExport}>
          {texts.nav.csv}
        </button>
      </header>

      <FilterBar onExport={onExport} />

      <main>
        <Routes>
          <Route path="/sales" element={<SalesPage />} />
          <Route path="/delivery" element={<DeliveryPage />} />
          <Route path="*" element={<Navigate to={{ pathname: '/sales', search }} replace />} />
        </Routes>
      </main>

      <footer className={s.footer}>{texts.footer.source}</footer>
    </div>
  )
}

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Layout />
      </BrowserRouter>
    </QueryClientProvider>
  )
}
