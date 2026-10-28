import { texts } from '@/shared/texts'
import s from './DeliveryPage.module.css'

/** Вкладка «Обещание доставки» — пока заглушка, маршрут уже настоящий */
export function DeliveryPage() {
  return (
    <section className={s.stub}>
      <h2 className={s.title}>{texts.stub}</h2>
    </section>
  )
}
