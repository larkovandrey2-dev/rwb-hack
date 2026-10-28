# Capibara — дашборд (фронтенд)

Vite + React + TypeScript, TanStack Query, Recharts. Вкладка «Продажи» — пять обязательных вопросов кейса; «Обещание доставки» — заглушка.

## Запуск

Нужен Node.js 20+. Сначала поднять API по `solution/README.md` (по умолчанию http://127.0.0.1:8004), затем из папки `solution/frontend`:

```bash
npm install
cp .env.example .env.local
npm run dev
```

Открыть http://localhost:5173 — этот origin разрешён в CORS бэка.

Без бэка: в `.env.local` поставить `VITE_API_MODE=mock` — включатся встроенные заглушки (с работающими фильтрами).

## Как связано с API

`src/api/httpApi.ts` вызывает `GET /api/overview`, `/api/sales/monthly`, `/api/categories`, `/api/sellers?limit=10` и приводит ответы к типам `src/api/types.ts`: десятичные строки → числа, проценты 0–100 → доли, месяц `2016-09-01` → `2016-09`. Компоненты знают только эти типы.

Ограничения текущего API:

- фильтры (период, штат, категория) бэк не принимает — на фронте они выключены, показатели за весь период;
- «Срывы» продавцов бэк не считает — в колонке прочерк;
- топ-10 категорий, «Прочие» и «Без категории» (`UNKNOWN`) собираются из `/api/categories` на фронте; русские подписи — из словаря в `src/api/mock/data`, для остальных — английское название.

## Структура

```
src/api/            контракт, HTTP-адаптер, заглушки
src/features/       вкладки sales, delivery и панель фильтров
src/shared/ui/      KpiTile, ChartCard, DataTable, Block (загрузка / ошибка / пусто)
src/shared/         форматирование чисел, тексты, фильтры в URL
```
