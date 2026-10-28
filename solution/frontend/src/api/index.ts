import { httpApi } from './httpApi'
import { mockApi } from './mock/mockApi'
import type { ApiClient } from './types'

// VITE_API_MODE=http — настоящий бэк (solution/api), иначе заглушки
export const api: ApiClient = import.meta.env.VITE_API_MODE === 'http' ? httpApi : mockApi

export type * from './types'
