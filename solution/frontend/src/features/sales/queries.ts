import { useQuery } from '@tanstack/react-query'
import { api, type ApiParams } from '@/api'

// Ключи общие для блоков и выгрузки CSV
export const salesKeys = {
  kpi: (p: ApiParams) => ['sales', 'kpi', p],
  monthly: (p: ApiParams) => ['sales', 'monthly', p],
  categories: (p: ApiParams) => ['sales', 'categories', p],
  topSellers: (p: ApiParams) => ['sales', 'top-sellers', p],
}

export const useSalesKpi = (p: ApiParams) => useQuery({ queryKey: salesKeys.kpi(p), queryFn: () => api.getSalesKpi(p) })
export const useSalesMonthly = (p: ApiParams) =>
  useQuery({ queryKey: salesKeys.monthly(p), queryFn: () => api.getSalesMonthly(p) })
export const useSalesCategories = (p: ApiParams) =>
  useQuery({ queryKey: salesKeys.categories(p), queryFn: () => api.getSalesCategories(p) })
export const useTopSellers = (p: ApiParams) =>
  useQuery({ queryKey: salesKeys.topSellers(p), queryFn: () => api.getTopSellers(p) })
