// app.test.js - Test entry point for To-Do Life Dashboard
// Uses Vitest as the test runner and fast-check for property-based tests.
// Individual widget tests will be added in subsequent tasks.

import { describe, it, expect } from 'vitest';
import * as fc from 'fast-check';

describe('Dashboard bootstrap', () => {
  it('app module exports an init function', async () => {
    // Dynamic import so DOMContentLoaded listener does not fire in test env
    const mod = await import('./app.js');
    expect(typeof mod.init).toBe('function');
  });
});

import { GreetingWidget } from './greeting.js';

describe('GreetingWidget.formatTime', () => {
  it('formats midnight as 00:00:00', () => {
    const d = new Date(2025, 4, 26, 0, 0, 0);
    expect(GreetingWidget.formatTime(d)).toBe('00:00:00');
  });

  it('formats noon as 12:00:00', () => {
    const d = new Date(2025, 4, 26, 12, 0, 0);
    expect(GreetingWidget.formatTime(d)).toBe('12:00:00');
  });

  it('zero-pads single-digit hours, minutes, and seconds', () => {
    const d = new Date(2025, 4, 26, 9, 5, 3);
    expect(GreetingWidget.formatTime(d)).toBe('09:05:03');
  });

  it('formats end-of-day as 23:59:59', () => {
    const d = new Date(2025, 4, 26, 23, 59, 59);
    expect(GreetingWidget.formatTime(d)).toBe('23:59:59');
  });
});

describe('GreetingWidget.formatDate', () => {
  it('formats a known Monday correctly', () => {
    // 26 May 2025 is a Monday
    const d = new Date(2025, 4, 26);
    expect(GreetingWidget.formatDate(d)).toBe('Monday, 26 May 2025');
  });

  it('zero-pads single-digit day', () => {
    // 1 January 2025 is a Wednesday
    const d = new Date(2025, 0, 1);
    expect(GreetingWidget.formatDate(d)).toBe('Wednesday, 01 January 2025');
  });

  it('uses correct month name for December', () => {
    // 31 December 2025 is a Wednesday
    const d = new Date(2025, 11, 31);
    expect(GreetingWidget.formatDate(d)).toBe('Wednesday, 31 December 2025');
  });

  it('includes four-digit year', () => {
    const d = new Date(2000, 5, 15);
    const result = GreetingWidget.formatDate(d);
    expect(result).toMatch(/2000$/);
  });
});

describe('GreetingWidget.getGreetingPhrase', () => {
  it('returns "Good Morning" for hour 5', () => {
    expect(GreetingWidget.getGreetingPhrase(5)).toBe('Good Morning');
  });

  it('returns "Good Morning" for hour 11', () => {
    expect(GreetingWidget.getGreetingPhrase(11)).toBe('Good Morning');
  });

  it('returns "Good Afternoon" for hour 12', () => {
    expect(GreetingWidget.getGreetingPhrase(12)).toBe('Good Afternoon');
  });

  it('returns "Good Afternoon" for hour 17', () => {
    expect(GreetingWidget.getGreetingPhrase(17)).toBe('Good Afternoon');
  });

  it('returns "Good Evening" for hour 18', () => {
    expect(GreetingWidget.getGreetingPhrase(18)).toBe('Good Evening');
  });

  it('returns "Good Evening" for hour 21', () => {
    expect(GreetingWidget.getGreetingPhrase(21)).toBe('Good Evening');
  });

  it('returns "Good Night" for hour 22', () => {
    expect(GreetingWidget.getGreetingPhrase(22)).toBe('Good Night');
  });

  it('returns "Good Night" for hour 0 (midnight)', () => {
    expect(GreetingWidget.getGreetingPhrase(0)).toBe('Good Night');
  });

  it('returns "Good Night" for hour 4', () => {
    expect(GreetingWidget.getGreetingPhrase(4)).toBe('Good Night');
  });

  it('returns "Good Night" for hour 23', () => {
    expect(GreetingWidget.getGreetingPhrase(23)).toBe('Good Night');
  });
});

/**
 * Property 1: Time format is always HH:MM:SS
 * Validates: Requirements 1.1
 *
 * For any Date object, GreetingWidget.formatTime(date) SHALL return a string
 * matching the pattern HH:MM:SS where HH is 00-23, MM is 00-59, and SS is 00-59.
 *
 * Tag: "Feature: todo-life-dashboard, Property 1: Time format is always HH:MM:SS"
 */
describe('Property 1: Time format is always HH:MM:SS', () => {
  it('formatTime always returns a string matching HH:MM:SS with valid ranges', () => {
    fc.assert(
      fc.property(fc.date(), (date) => {
        const result = GreetingWidget.formatTime(date);

        // Must match the HH:MM:SS pattern
        expect(result).toMatch(/^\d{2}:\d{2}:\d{2}$/);

        // Parse each component and verify valid ranges
        const [hh, mm, ss] = result.split(':').map(Number);
        expect(hh).toBeGreaterThanOrEqual(0);
        expect(hh).toBeLessThanOrEqual(23);
        expect(mm).toBeGreaterThanOrEqual(0);
        expect(mm).toBeLessThanOrEqual(59);
        expect(ss).toBeGreaterThanOrEqual(0);
        expect(ss).toBeLessThanOrEqual(59);
      }),
      { numRuns: 100, verbose: true }
    );
  });
});
