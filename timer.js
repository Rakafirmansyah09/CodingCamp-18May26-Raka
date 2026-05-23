// timer.js - FocusTimerWidget for To-Do Life Dashboard

export const FocusTimerWidget = {
  /**
   * formatDisplay(totalSeconds) -> "MM:SS"
   * Pure function. Converts a non-negative integer (0-3600) to a zero-padded
   * MM:SS string.
   *
   * @param {number} totalSeconds - Integer in range 0-3600
   * @returns {string} Zero-padded "MM:SS" string
   */
  formatDisplay(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    const mm = String(minutes).padStart(2, '0');
    const ss = String(seconds).padStart(2, '0');
    return `${mm}:${ss}`;
  },

  /**
   * validateDuration(input) -> integer | null
   * Pure function. Returns the integer value if input is a whole number
   * between 1 and 60 inclusive; returns null for anything outside that range,
   * including non-integers, negative numbers, zero, and values > 60.
   *
   * @param {*} input - Value to validate
   * @returns {number|null} Integer 1-60, or null
   */
  validateDuration(input) {
    const n = Number(input);
    if (!Number.isInteger(n)) return null;
    if (n < 1 || n > 60) return null;
    return n;
  },
};
