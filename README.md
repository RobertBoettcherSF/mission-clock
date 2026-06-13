# mission-clock
High-resolution time tracking with overflow safety for mission-critical applications

# Mission Clock

> **High-resolution time tracking with overflow safety for mission-critical applications**

[License: MIT](https://opensource.org/licenses/MIT)  
[TypeScript](https://www.typescriptlang.org/)  
[Node.js](https://nodejs.org/)

Mission Clock provides **nanosecond-precision timing** with **built-in overflow protection** for applications where timing accuracy and reliability are non-negotiable. Whether you're building real-time systems, performance benchmarks, or financial trading platforms, Mission Clock ensures your time measurements remain accurate even during extended operations.

## ✨ Features

- **Nanosecond Resolution** – Track time with the highest precision available on your system
- **Overflow Safety** – Automatic detection and handling of integer overflow in time calculations
- **Monotonic Clock** – Immune to system clock adjustments (NTP updates, manual changes)
- **Cross-Platform** – Works consistently across different operating systems
- **Zero Dependencies** – Lightweight with no external dependencies
- **TypeScript First** – Fully typed API with comprehensive type definitions

## 📦 Installation

```bash
npm install mission-clock
# or
pnpm add mission-clock
# or
yarn add mission-clock
```

## 🚀 Usage

### Basic Timing

```typescript
import { MissionClock } from 'mission-clock';

const clock = new MissionClock();

// Start tracking
const start = clock.now();

// ... your operation ...

// Get elapsed time
const elapsed = clock.elapsed(start);
console.log(`Operation took: ${elapsed.nanoseconds} ns`);
console.log(`Operation took: ${elapsed.milliseconds} ms`);
console.log(`Operation took: ${elapsed.seconds} s`);
```

### Overflow-Safe Duration Calculations

```typescript
import { Duration, MissionClock } from 'mission-clock';

const clock = new MissionClock();

// Create durations safely
const duration1 = Duration.fromNanoseconds(9_000_000_000_000_000_000); // 9e18 ns
const duration2 = Duration.fromHours(24);

// Arithmetic operations are overflow-safe
const total = duration1.plus(duration2);
console.log(total.toString()); // Handles overflow gracefully
```

### Benchmarking

```typescript
import { MissionClock, Benchmark } from 'mission-clock';

const benchmark = new Benchmark();

// Run multiple iterations
const results = benchmark.measure(() => {
  // Your code to benchmark
  return expensiveOperation();
}, { iterations: 1000 });

console.log(`Average: ${results.average.nanoseconds} ns`);
console.log(`Min: ${results.min.nanoseconds} ns`);
console.log(`Max: ${results.max.nanoseconds} ns`);
console.log(`Std Dev: ${results.stdDev.nanoseconds} ns`);
```

### Timeout with Overflow Protection

```typescript
import { MissionClock, Timeout } from 'mission-clock';

const clock = new MissionClock();
const timeout = new Timeout(clock, { milliseconds: 5000 });

// Check if timeout has elapsed (safe for very long durations)
if (timeout.hasElapsed()) {
  console.log('Timeout reached!');
}

// Reset the timeout
timeout.reset();
```

## 🔧 API Reference

### MissionClock

The primary clock interface for high-resolution timing.

```typescript
class MissionClock {
  /** Get current time as a high-resolution timestamp */
  now(): HighResTimestamp;
  
  /** Calculate elapsed time since a timestamp */
  elapsed(since: HighResTimestamp): Duration;
  
  /** Create a timeout */
  createTimeout(duration: Duration): Timeout;
  
  /** Get the clock's resolution */
  readonly resolution: Duration;
}
```

### Duration

Represents a span of time with overflow-safe arithmetic.

```typescript
class Duration {
  // Factory methods
  static fromNanoseconds(ns: bigint | number): Duration;
  static fromMicroseconds(μs: bigint | number): Duration;
  static fromMilliseconds(ms: bigint | number): Duration;
  static fromSeconds(s: bigint | number): Duration;
  static fromMinutes(m: bigint | number): Duration;
  static fromHours(h: bigint | number): Duration;
  static fromDays(d: bigint | number): Duration;
  
  // Properties
  readonly nanoseconds: bigint;
  readonly microseconds: bigint;
  readonly milliseconds: bigint;
  readonly seconds: bigint;
  readonly minutes: bigint;
  readonly hours: bigint;
  readonly days: bigint;
  
  // Arithmetic (all overflow-safe)
  plus(other: Duration): Duration;
  minus(other: Duration): Duration;
  multiply(factor: number): Duration;
  divide(factor: number): Duration;
  
  // Comparison
  equals(other: Duration): boolean;
  lessThan(other: Duration): boolean;
  greaterThan(other: Duration): boolean;
  
  // Conversion
  toString(): string;
  toISOString(): string;
  toJSON(): string;
}
```

### Timeout

Overflow-safe timeout management.

```typescript
class Timeout {
  constructor(clock: MissionClock, options: { duration: Duration });
  
  /** Check if timeout has elapsed */
  hasElapsed(): boolean;
  
  /** Check if timeout has elapsed, updating internal state */
  checkElapsed(): boolean;
  
  /** Reset the timeout */
  reset(): void;
  
  /** Reset with a new duration */
  resetWith(duration: Duration): void;
  
  /** Get remaining time */
  remaining(): Duration | null;
  
  /** Get the timeout duration */
  readonly duration: Duration;
}
```

### Benchmark

Statistical benchmarking utilities.

```typescript
class Benchmark {
  /** Measure execution time of a function */
  measure(
    fn: () => any,
    options?: { iterations?: number; warmup?: number }
  ): BenchmarkResult;
  
  /** Measure async function */
  measureAsync(
    fn: () => Promise<any>,
    options?: { iterations?: number; warmup?: number }
  ): Promise<BenchmarkResult>;
}

interface BenchmarkResult {
  average: Duration;
  min: Duration;
  max: Duration;
  stdDev: Duration;
  median: Duration;
  percentile(p: number): Duration;
  all: Duration[];
}
```

## 📊 Performance

Mission Clock is designed for minimal overhead:

- **Clock resolution**: Platform-dependent (typically 1-100 nanoseconds)
- **Measurement overhead**: < 100 nanoseconds per call
- **Memory usage**: ~1KB per clock instance

## 🛡️ Overflow Safety

Mission Clock uses **BigInt** internally for all time calculations, ensuring:

- No precision loss for durations up to ±292 years
- Automatic overflow detection and handling
- Safe arithmetic operations (addition, subtraction, multiplication, division)
- Consistent behavior across 32-bit and 64-bit systems

### Overflow Handling Strategies

```typescript
// Strategy 1: Throw on overflow (default)
Duration.overflowStrategy = 'throw';
try {
  const huge = Duration.fromDays(1e100);
} catch (e) {
  console.log('Overflow detected!');
}

// Strategy 2: Clamp to max/min safe values
Duration.overflowStrategy = 'clamp';
const clamped = Duration.fromDays(1e100); // Clamped to MAX_SAFE_DURATION

// Strategy 3: Wrap around (modular arithmetic)
Duration.overflowStrategy = 'wrap';
const wrapped = Duration.fromDays(1e100); // Wraps around
```

## 🔌 Integration

### With Node.js Performance Hooks

```typescript
import { MissionClock } from 'mission-clock';
import { performance } from 'perf_hooks';

const clock = new MissionClock({ 
  source: performance 
});
```

### With Browser Performance API

```typescript
import { MissionClock } from 'mission-clock';

const clock = new MissionClock({ 
  source: window.performance 
});
```

### With Custom Clock Sources

```typescript
import { MissionClock } from 'mission-clock';

const customSource = {
  now: () => BigInt(Date.now()) * 1_000_000n,
  resolution: 1_000_000n // 1ms resolution
};

const clock = new MissionClock({ source: customSource });
```

## 🧪 Testing

```bash
# Run unit tests
npm test

# Run benchmarks
npm run benchmark

# Type checking
npm run typecheck
```

## 📝 Contributing

Contributions are welcome! Please follow these guidelines:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
git clone https://github.com/RobertBoettcherSF/mission-clock.git
cd mission-clock
npm install
npm run dev
```

### Code Style

- TypeScript strict mode
- ESLint for linting
- Prettier for formatting
- Commit messages follow [Conventional Commits](https://www.conventionalcommits.org/)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need for reliable timing in mission-critical systems
- Built with TypeScript for type safety and developer experience
- Designed for performance and correctness

---

© 2026 Robert Boettcher. All rights reserved.
