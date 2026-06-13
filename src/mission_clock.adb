--  mission_clock.adb
--
--  High-resolution time tracking with overflow safety for mission-critical applications
--
--  Copyright (c) 2026 Sternenfisch
--  License: MIT (see LICENSE file)

with Ada.Real_Time; use Ada.Real_Time;

package body mission_clock is

   --  Epoch for mission clock
   Mission_Epoch : constant Time := Clock_Epoch;

   --  Nanoseconds per second
   Nanoseconds_Per_Second : constant := 1_000_000_000;

   --  Convert Time to Mission_Time (nanoseconds since mission epoch)
   function To_Mission_Time (T : Time) return Mission_Time is
      Time_Diff : constant Time_Span := T - Mission_Epoch;
      Total_Seconds : constant Integer := Integer (Time_Diff / Seconds (1));
      Remainder : constant Time_Span := Time_Diff - Time_Span (Total_Seconds) * Seconds (1);
      Total_Millis : constant Integer := Integer (Remainder / Milliseconds (1));
      Remainder2 : constant Time_Span := Remainder - Time_Span (Total_Millis) * Milliseconds (1);
      Total_Micros : constant Integer := Integer (Remainder2 / Microseconds (1));
      Remainder3 : constant Time_Span := Remainder2 - Time_Span (Total_Micros) * Microseconds (1);
      Total_Nanos : constant Integer := Integer (Remainder3 / Nanoseconds (1));
      Total_Nanos_All : constant Long_Integer := 
        Long_Integer (Total_Seconds) * Nanoseconds_Per_Second +
        Long_Integer (Total_Millis) * 1_000_000 +
        Long_Integer (Total_Micros) * 1_000 +
        Long_Integer (Total_Nanos);
   begin
      return Mission_Time (Total_Nanos_All);
   end To_Mission_Time;

   --  Convert Mission_Time to Time
   function To_Time (MT : Mission_Time) return Time is
      Total_Nanos : constant Long_Integer := Long_Integer (MT);
      Seconds : constant Long_Integer := Total_Nanos / Nanoseconds_Per_Second;
      Remainder_Nanos : constant Long_Integer := Total_Nanos mod Nanoseconds_Per_Second;
   begin
      return Mission_Epoch + 
        Time_Span (Seconds) * Seconds (1) + 
        Time_Span (Remainder_Nanos) * Nanoseconds (1);
   end To_Time;

   --  Get current mission time
   function Now return Mission_Time is
   begin
      return To_Mission_Time (Clock);
   end Now;

   --  Convert Time_Span to Mission_Time
   function To_Mission_Time (D : Time_Span) return Mission_Time is
      Total_Seconds : constant Integer := Integer (D / Seconds (1));
      Remainder : constant Time_Span := D - Time_Span (Total_Seconds) * Seconds (1);
      Total_Millis : constant Integer := Integer (Remainder / Milliseconds (1));
      Remainder2 : constant Time_Span := Remainder - Time_Span (Total_Millis) * Milliseconds (1);
      Total_Micros : constant Integer := Integer (Remainder2 / Microseconds (1));
      Remainder3 : constant Time_Span := Remainder2 - Time_Span (Total_Micros) * Microseconds (1);
      Total_Nanos : constant Integer := Integer (Remainder3 / Nanoseconds (1));
      Total_Nanos_All : constant Long_Integer := 
        Long_Integer (Total_Seconds) * Nanoseconds_Per_Second +
        Long_Integer (Total_Millis) * 1_000_000 +
        Long_Integer (Total_Micros) * 1_000 +
        Long_Integer (Total_Nanos);
   begin
      return Mission_Time (Total_Nanos_All);
   end To_Mission_Time;

   --  Convert Mission_Time to Time_Span
   function To_Time_Span (MT : Mission_Time) return Time_Span is
      Total_Nanos : constant Long_Integer := Long_Integer (MT);
      Seconds : constant Long_Integer := Total_Nanos / Nanoseconds_Per_Second;
      Remainder_Nanos : constant Long_Integer := Total_Nanos mod Nanoseconds_Per_Second;
   begin
      return Time_Span (Seconds) * Seconds (1) + 
             Time_Span (Remainder_Nanos) * Nanoseconds (1);
   end To_Time_Span;

   --  Addition
   function "+" (Left, Right : Mission_Time) return Mission_Time is
   begin
      return Left + Right;
   end "+";

   --  Subtraction
   function "-" (Left, Right : Mission_Time) return Mission_Time is
   begin
      return Left - Right;
   end "-";

   --  Less than
   function "<" (Left, Right : Mission_Time) return Boolean is
   begin
      return Left < Right;
   end "<";

   --  Less than or equal
   function "<=" (Left, Right : Mission_Time) return Boolean is
   begin
      return Left <= Right;
   end "<=";

   --  Equality
   function "=" (Left, Right : Mission_Time) return Boolean is
   begin
      return Left = Right;
   end "=";

   --  Check for overflow in addition
   function Will_Overflow (Left, Right : Mission_Time) return Boolean is
      Sum : constant Mission_Time := Left + Right;
   begin
      --  If sum is less than either operand, overflow occurred (modular arithmetic wrap-around)
      return Sum < Left or Sum < Right;
   end Will_Overflow;

   --  Safe addition with overflow detection
   procedure Safe_Add (
      Left, Right : Mission_Time;
      Result      : out Mission_Time;
      Overflow    : out Boolean) is
   begin
      if Will_Overflow (Left, Right) then
         Overflow := True;
         Result := Mission_Time_Zero;
      else
         Overflow := False;
         Result := Left + Right;
      end if;
   end Safe_Add;

   --  Format mission time as string
   function Image (MT : Mission_Time) return String is
      Total_Nanos : constant Long_Integer := Long_Integer (MT);
      Seconds : constant Long_Integer := Total_Nanos / Nanoseconds_Per_Second;
      Remainder_Nanos : constant Long_Integer := Total_Nanos mod Nanoseconds_Per_Second;

      Hours : constant Long_Integer := Seconds / 3600;
      Minutes : constant Long_Integer := (Seconds mod 3600) / 60;
      Secs : constant Long_Integer := Seconds mod 60;
   begin
      return "Mission_Time(" & 
             Hours'Image & ":" & 
             Minutes'Image & ":" & 
             Secs'Image & "." & 
             Remainder_Nanos'Image & ")";
   end Image;

end mission_clock;
