import { format } from 'date-fns'

let Hooks = {}

const FormatDate = {
  mounted() {
    const el = this.el
    const date = el.dataset.date
    const dateFormat = el.dataset.dateFormat || 'yyyy MMM dd, hh:mm aa'

    if (date) {
      const formattedDate = format(new Date(date), dateFormat)
      el.innerText = formattedDate
    }
  },
  updated() {
    this.mounted()
  },
}

Hooks.FormatDate = FormatDate

export default Hooks
