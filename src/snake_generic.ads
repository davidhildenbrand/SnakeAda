generic
   --- allow to specify the number of culomns and rows
   NR_ROWS : Positive;
   NR_COLUMNS : Positive;
package snake_generic with SPARK_Mode is
   type Direction_t is (UP, DOWN, LEFT, RIGHT);

   type State_t is (NONE, SNAKE, FOOD);

   --- Spark fails to prove 2D arrays, so let's use a 1D linearized one.
   type Lin_t is new Positive range 1 .. NR_COLUMNS * NR_ROWS;
   subtype Column_t is Lin_t range Lin_t'First .. Lin_t (NR_COLUMNS);
   subtype Row_t is Lin_t range Lin_t'First .. Lin_t (NR_ROWS);

   type Position_t is
      record
         row : Row_t;
         column : Column_t;
      end record;

   type Pixel_t is
      record
         usage : State_t := NONE;
         next : Position_t := (Row_t'First, Column_t'First);
      end record;

   --- Spark fails to prove 2D arrays, so let's use a 1D linearized one.
   type Board_t is array (Lin_t) of Pixel_t;

   procedure DoTick (rand : Lin_t) with
     Global => (In_Out => (is_lost, is_won, is_running, direction_consumed,
                           board, nr_eaten, head, tail),
                INPUT => direction),
     Pre => (not (is_lost and is_won)
             and (if (is_lost or is_won) then (not is_running))),
     Post => ((not (is_lost and is_won))
              and (if is_lost then (not is_running)));
   procedure Reset (rand : Lin_t) with
     Global => (Output => (is_lost, is_won, is_running, direction_consumed,
                           board, nr_eaten, head, tail, direction));

   function IsWon return Boolean with
     Global => (Input => is_won),
     Depends => (IsWon'Result => is_won);
   function IsLost return Boolean with
     Global => (Input => is_lost),
     Depends => (IsLost'Result => (is_lost));
   function GetNrEaten return Natural with
     Global => (Input => nr_eaten),
     Depends => (GetNrEaten'Result => (nr_eaten));
   procedure SetNextDirection (new_direction : Direction_t) with
     Global => (In_Out => (direction, direction_consumed)),
     Depends => (direction => (new_direction, direction_consumed, direction),
                 direction_consumed => (new_direction, direction_consumed,
                                        direction));
   function GetState (position : Position_t) return State_t with
     Global => (Input => board),
     Depends => (GetState'Result => (board, position));
   procedure SetState (position : Position_t; usage : State_t) with
     Global => (In_Out => board),
     Depends => (board => (board, position, usage));
   function GetNext (position : Position_t) return Position_t with
     Global => (Input => board),
     Depends => (GetNext'Result => (board, position));
   procedure SetNext (position : Position_t; next : Position_t) with
     Global => (In_Out => board),
     Depends => (board => (board, position, next));
   function PosToLin (position : Position_t) return Lin_t with
     Global => null,
     Depends => (PosToLin'Result => position);
   procedure DetermineNewFoodPosition (rand : Lin_t) with
     Global => (In_Out => (board, is_won, is_running)),
     Depends => (board => (rand, board),
                 is_won => (board, is_won, rand),
                 is_running => (board, is_running, rand)),
     Pre => (not is_won) and (is_running),
     Post => ((if is_won then
                  (for all l in Board_t'Range => board (l).usage /= NONE))
              and (if not is_won then True)
              and (if is_won then not is_running));
   --- our state, unfortunately package variables
   direction : Direction_t := UP;
   direction_consumed : Boolean := False;
   nr_eaten : Natural := 0;
   is_running : Boolean := False;
   is_lost : Boolean := False;
   is_won : Boolean := False;
   board : Board_t;
   head : Position_t := (Row_t'Last, Column_t'Last);
   tail : Position_t := (Row_t'Last, Column_t'Last);
end snake_generic;
