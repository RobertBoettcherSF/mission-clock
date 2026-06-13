--  mission_clock.ads
--
--  High-resolution time tracking with overflow safety for mission-critical applications
--
--  Copyright (c) 2026 Sternenfisch
--  License: MIT (see LICENSE file)

with Ada.Real_Time; use Ada.Real_Time;

package Mission_Clock is

   --  Clock type for mission-critical timing
   type Mission_Time is private;

   --  Zero time constant
   Mission_Time_Zero : constant Mission_Time;

   --  Maximum representable time before overflow
   Mission_Time_Max  : constant Mission_Time;

   --  Get current mission time
   function Now return Mission_Time;

   --  Time arithmetic
   function "+" (Left, Right : Mission_Time) return Mission_Time;
   function "-" (Left, Right : Mission_Time) return Mission_Time;
   function "<"  (Left, Right : Mission_Time) return Boolean;
   function "<=" (Left, Right : Mission_Time) return Boolean;
   function "="  (Left, Right : Mission_Time) return Boolean;

   --  Conversion functions
   function To_Mission_Time (T : Time) return Mission_Time;
   function To_Time (MT : Mission_Time) return Time;

   --  Duration operations
   function To_Mission_Time (D : Time_Span) return Mission_Time;
   function To_Time_Span (MT : Mission_Time) return Time_Span;

   --  Check for overflow in addition
   function Will_Overflow (Left, Right : Mission_Time) return Boolean;

   --  Safe addition with overflow detection
   procedure Safe_Add (
      Left, Right : Mission_Time;
      Result      : out Mission_Time;
      Overflow    : out Boolean);

   --  Format mission time as string
   function Image (MT : Mission_Time) return String;

private

   --  Internal representation using nanoseconds since epoch
   --  Using a modular type to prevent overflow
   type Mission_Time is mod 2**63;

   Mission_Time_Zero : constant Mission_Time := 0;
   Mission_Time_Max  : constant Mission_Time := Mission_Time'Last;

end Mission_Clock;
