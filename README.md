# RWB TECH-HACK/EMAE

Нужны Docker, Python 3.13 и Node.js 20+.

Терминал 1, из корня репозитория:

```bash
cd solution
python3 -m venv .venv
source .venv/bin/activate
pip install -r api/requirements.txt
bash scripts/setup.sh
bash bin/build.sh
python3 api/setup_access.py
bash api/run.sh
```

При уже загруженной базе пропустите `setup.sh`. API: http://127.0.0.1:8004/docs. База: localhost:5433, marketplace, hack/hack.

Терминал 2, из корня репозитория:

```bash
cd solution/frontend
npm ci
cp .env.example .env.local
npm run dev
```

Открыть http://localhost:5173. Используется настоящий API; доставка пока заглушка, фильтры в HTTP-режиме выключены.

Данные: CSV → raw → core → mart → API. Пять ответов из корня: `bash solution/bin/export_answers.sh`. Оборот — товары delivered без доставки; чек — заказ с доставкой; повторность — все статусы. Рейтинг однопродавцовых заказов не доказывает ответственность продавца.
