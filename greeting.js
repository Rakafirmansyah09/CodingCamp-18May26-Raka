// greeting.js - GreetingWidget for To-Do Life Dashboard

const DAY_NAMES = [
  'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday',
];

const MONTH_NAMES = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

export const GreetingWidget = {
  formatTime(date) {
    const hh = String(date.getHours()).padStart(2, '0');
    const mm = String(date.getMinutes()).padStart(2, '0');
    const ss = String(date.getSeconds()).padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
  },

  formatDate(date) {
    const dayName   = DAY_NAMES[date.getDay()];
    const dd        = String(date.getDate()).padStart(2, '0');
    const monthName = MONTH_NAMES[date.getMonth()];
    const yyyy      = date.getFullYear();
    return `${dayName}, ${dd} ${monthName} ${yyyy}`;
  },

  getGreetingPhrase(hour) {
    if (hour >= 5 && hour <= 11) return 'Good Morning';
    if (hour >= 12 && hour <= 17) return 'Good Afternoon';
    if (hour >= 18 && hour <= 21) return 'Good Evening';
    return 'Good Night';
  },
};
