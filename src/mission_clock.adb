--  mission_clock.adb
--
--  High-resolution time tracking with overflow safety for mission-critical applications
--
--  Copyright (c) 2026 Sternenfisch
--  License: MIT (see LICENSE file)

with Ada.Real_Time; use Ada.Real_Time;
with Ada.Calendar; use Ada.Calendar;
with Ada.Strings.Fixed;

package body Mission_Clock is

   --  Epoch for mission clock (2024-01-01 00:00:00 UTC)
   Mission_Epoch : constant Time := Time_Of (2024, 1, 1, 0, 0, 0, 0);

   --  Nanoseconds per second
   Nanoseconds_Per_Second : constant := 1_000_000_000;

   --  Convert Time to Mission_Time (nanoseconds since mission epoch)
   function To_Mission_Time (T : Time) return Mission_Time is
      Delta : constant Time_Span := T - Mission_Epoch;
      Seconds : constant Time_Span := Delta / 1.0;
      Sub_Seconds : constant Time_Span := Delta - Seconds * 1.0;
      Nanos : constant := Duration (Sub_Seconds) * Duration (Nanoseconds_Per_Second);
   begin
      return Mission_Time (Long_Integer (Seconds) * Long_Integer (Nanoseconds_Per_Second) + Long_Integer (Nanos));
   end To_Mission_Time;

   --  Convert Mission_Time to Time
   function To_Time (MT : Mission_Time) return Time is
      Total_Nanos : constant Long_Integer := Long_Integer (MT);
      Seconds : constant Long_Integer := Total_Nanos / Nanoseconds_Per_Second;
      Remainder : constant Long_Integer := Total_Nanos mod Nanoseconds_Per_Second;
   begin
      return Mission_Epoch + Time_Span (Seconds) + Time_Span (Remainder) / Time_Span (Nanoseconds_Per_Second);
   end To_Time;

   --  Get current mission time
   function Now return Mission_Time is
   begin
      return To_Mission_Time (Clock);
   end Now;

   --  Convert Time_Span to Mission_Time
   function To_Mission_Time (D : Time_Span) return Mission_Time is
      Seconds : constant Long_Integer := Long_Integer (D);
      Sub_Seconds : constant Time_Span := D - Time_Span (Seconds);
      Nanos : constant := Duration (Sub_Seconds) * Duration (Nanoseconds_Per_Second);
   begin
      return Mission_Time (Seconds * Long_Integer (Nanoseconds_Per_Second) + Long_Integer (Nanos));
   end To_Mission_Time;

   --  Convert Mission_Time to Time_Span
   function To_Time_Span (MT : Mission_Time) return Time_Span is
      Total_Nanos : constant Long_Integer := Long_Integer (MT);
      Seconds : constant Long_Integer := Total_Nanos / Nanoseconds_Per_Second;
      Remainder : constant Long_Integer := Total_Nanos mod Nanoseconds_Per_Second;
   begin
      return Time_Span (Seconds) + Time_Span (Remainder) / Time_Span (Nanoseconds_Per_Second);
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
      Remainder : constant Long_Integer := Total_Nanos mod Nanoseconds_Per_Second;

      Hours : constant Long_Integer := Seconds / 3600;
      Minutes : constant Long_Integer := (Seconds mod 3600) / 60;
      Secs : constant Long_Integer := Seconds mod 60;
      Nanos : constant Long_Integer := Remainder;

      package Long_Int_IO is new Ada.Text_IO.Integer_IO (Long_Integer);
   begin
      return "Mission_Time(" & 
             Hours'Image & ":" & 
             Minutes'Image & ":" & 
             Secs'Image & "." & 
             Nanos'Image & ")";
   end Image;

end Mission_Clock;
