// storage.js - StorageService for To-Do Life Dashboard

export const StorageService = {
  KEYS: {
    USER_NAME:     'tld_userName',
    TASKS:         'tld_tasks',
    LINKS:         'tld_links',
    POMO_DURATION: 'tld_pomoDuration',
    THEME:         'tld_theme',
  },

  get(key) {
    try {
      const raw = localStorage.getItem(key);
      if (raw === null) return null;
      return JSON.parse(raw);
    } catch {
      return null;
    }
  },

  set(key, value) {
    try {
      localStorage.setItem(key, JSON.stringify(value));
      return true;
    } catch {
      return false;
    }
  },

  loadAll() {
    const u  = this.get(this.KEYS.USER_NAME);
    const t  = this.get(this.KEYS.TASKS);
    const l  = this.get(this.KEYS.LINKS);
    const p  = this.get(this.KEYS.POMO_DURATION);
    const th = this.get(this.KEYS.THEME);
    return {
      userName:     u  !== null ? u  : 'there',
      tasks:        t  !== null ? t  : [],
      links:        l  !== null ? l  : [],
      pomoDuration: p  !== null ? p  : 25,
      theme:        th !== null ? th : 'light',
    };
  },
};