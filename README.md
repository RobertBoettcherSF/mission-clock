# Mission Clock

High-resolution time tracking with overflow safety for mission-critical applications.

## Overview

Mission Clock is an Ada library that provides a safe, high-resolution time representation for mission-critical systems. It uses modular arithmetic to prevent overflow and provides comprehensive conversion functions between Ada's time types.

## Features

- **Overflow-safe arithmetic**: Uses modular type (`mod 2**63`) to prevent overflow
- **Nanosecond precision**: High-resolution time tracking
- **Type safety**: Strong typing with conversion functions
- **SPARK compatible**: Designed for formal verification with gnatprove
- **Comprehensive operations**: Arithmetic, comparison, and conversion functions

## Types

### Mission_Time

The primary type representing time as nanoseconds since epoch. It is a private type with modular arithmetic to prevent overflow.

```ada
type Mission_Time is private;
```

## Constants

- `Mission_Time_Zero`: Zero time constant
- `Mission_Time_Max`: Maximum representable time before overflow

## Functions

### Time Retrieval

```ada
function Now return Mission_Time;
```
Returns the current mission time.

### Arithmetic Operations

```ada
function "+" (Left, Right : Mission_Time) return Mission_Time;
function "-" (Left, Right : Mission_Time) return Mission_Time;
function "<"  (Left, Right : Mission_Time) return Boolean;
function "<=" (Left, Right : Mission_Time) return Boolean;
function "="  (Left, Right : Mission_Time) return Boolean;
```

### Conversion Functions

```ada
-- Convert from Ada.Real_Time.Time
function To_Mission_Time (T : Time) return Mission_Time;

-- Convert to Ada.Real_Time.Time
function To_Time (MT : Mission_Time) return Time;

-- Convert from Ada.Real_Time.Time_Span
function To_Mission_Time (D : Time_Span) return Mission_Time;

-- Convert to Ada.Real_Time.Time_Span
function To_Time_Span (MT : Mission_Time) return Time_Span;
```

### Overflow Detection

```ada
-- Check if addition would overflow
function Will_Overflow (Left, Right : Mission_Time) return Boolean;

-- Safe addition with overflow detection
procedure Safe_Add (
   Left, Right : Mission_Time;
   Result      : out Mission_Time;
   Overflow    : out Boolean);
```

### Formatting

```ada
function Image (MT : Mission_Time) return String;
```
Returns a string representation in the format: `Mission_Time(HH:MM:SS.nanoseconds)`

## Usage Example

```ada
with Mission_Clock;
use Mission_Clock;

procedure Example is
   Start : Mission_Time := Now;
   Duration : Mission_Time := To_Mission_Time (Time_Span (5.0)); -- 5 seconds
   End_Time : Mission_Time;
   Overflow : Boolean;
begin
   -- Safe addition
   Safe_Add (Start, Duration, End_Time, Overflow);
   
   if Overflow then
      -- Handle overflow
   else
      -- Use End_Time
   end if;
end Example;
```

## Building

### Prerequisites

- GNAT (GNU Ada Translator)
- gnatprove (for SPARK verification)

### Build with GPR

```bash
# Compile the library
gprbuild -P mission_clock.gpr

# Run SPARK verification
gnatprove -P mission_clock.gpr --level=4
```

### Project File

The library uses `mission_clock.gpr` as the GNAT Project file. It is configured for:
- Ada 2022 standard
- Optimization level 2
- All warnings enabled
- Overflow checks enabled
- Style checking enabled

## Directory Structure

```
mission-clock/
├── README.md              # This file
├── mission_clock.gpr      # GNAT Project file
├── src/
│   ├── mission_clock.ads  # Package specification
│   └── mission_clock.adb  # Package implementation
```

## Implementation Details

### Epoch

The mission clock uses `Time_First` from `Ada.Real_Time` as the epoch (earliest representable time).

### Internal Representation

`Mission_Time` is internally represented as a modular integer type (`mod 2**63`), which provides:
- Automatic wrap-around on overflow
- Efficient arithmetic operations
- Well-defined comparison operators

### Precision

The library uses `Duration` for intermediate calculations, providing nanosecond-level precision through multiplication by `1_000_000_000`.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please ensure:
- All gnatprove checks pass with `--level=4`
- Code follows Ada 2022 standards
- No warnings are generated

## Acknowledgments

Developed for mission-critical applications requiring high-resolution, overflow-safe time tracking.
