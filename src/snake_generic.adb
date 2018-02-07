package body snake_generic with SPARK_Mode is

   procedure DoTick (rand : Lin_t) is
      next_head : Position_t := (Row_t'First, Column_t'First);
      eating : Boolean := False;
   begin
      if not is_running or is_won or is_lost then
         return;
      end if;

      case direction is
         when UP =>
            if head.row = Row_t'First then
               is_lost := True;
               is_running := False;
            else
               next_head.row := Row_t'Pred (head.row);
               next_head.column := head.column;
            end if;
         when DOWN =>
            if head.row = Row_t'Last then
               is_lost := True;
               is_running := False;
            else
               next_head.row := Row_t'Succ (head.row);
               next_head.column := head.column;
            end if;
         when LEFT =>
            if head.column = Column_t'First then
               is_lost := True;
               is_running := False;
            else
               next_head.row := head.row;
               next_head.column := Column_t'Pred (head.column);
            end if;
         when RIGHT =>
            if head.column = Column_t'Last then
               is_lost := True;
               is_running := False;
            else
               next_head.row := head.row;
               next_head.column := Column_t'Succ (head.column);
            end if;
      end case;
      direction_consumed := True;

      if is_lost then
         pragma Assert (not is_running);
         return;
      end if;

      if GetState (next_head) = SNAKE then
         is_lost := True;
         is_running := False;
         return;
      end if;

      if GetState (next_head) = FOOD then
         eating := True;
         --- make gnatprove happy
         if nr_eaten /= Natural'Last then
            nr_eaten := Natural'Succ (nr_eaten);
         end if;
      end if;

      --  move the head forward
      SetState (next_head, SNAKE);
      SetNext (head, next_head);
      head := next_head;

      --  shrink the tail if not eating
      if not eating then
         SetState (tail, NONE);
         tail := GetNext (tail);
      end if;

      pragma Assert ((not is_won) and (not is_lost) and is_running);
      --  try to find a new place for food. If none found -> won
      if eating then
         DetermineNewFoodPosition (rand);
      end if;

   end DoTick;
   procedure Reset (rand : Lin_t) is
   begin
      is_running := True;
      is_won := False;
      is_lost := False;
      nr_eaten := 0;
      --  clear the board and reinitialize
      for l in board'Range loop
         board (l) := (NONE, (Row_t'First, Column_t'First));
      end loop;
      --  the snake starts at lower right corner
      head := (Row_t'Last, Column_t'Last);
      tail := (Row_t'Last, Column_t'Last);
      SetState (head, SNAKE);
      direction := UP;
      direction_consumed := False;
      --  find first random position for our food
      DetermineNewFoodPosition (rand);
   end Reset;
   function GetState (position : Position_t) return State_t is
   begin
      return board (PosToLin (position)).usage;
   end GetState;
   procedure SetState (position : Position_t; usage : State_t) is
   begin
      board (PosToLin (position)).usage := usage;
   end SetState;
   function GetNext (position : Position_t) return Position_t is
   begin
      return board (PosToLin (position)).next;
   end GetNext;
   procedure SetNext (position : Position_t; next : Position_t) is
   begin
      board (PosToLin (position)).next := next;
   end SetNext;
   function PosToLin (position : Position_t) return Lin_t is
   begin
      return (position.row - 1) * Column_t'Last + position.column;
   end PosToLin;
   function IsWon return Boolean is
   begin
      return is_won;
   end IsWon;
   function IsLost return Boolean is
   begin
      return is_lost;
   end IsLost;
   function GetNrEaten return Natural is
   begin
      return nr_eaten;
   end GetNrEaten;
   procedure SetNextDirection (new_direction : Direction_t) is
   begin
      --  ignore oposite direction
      if direction = UP and new_direction = DOWN then
         return;
      elsif direction = DOWN and new_direction = UP then
         return;
      elsif direction = LEFT and new_direction = RIGHT then
         return;
      elsif direction = RIGHT and new_direction = LEFT then
         return;
      end if;

      if direction_consumed then
         direction := new_direction;
         direction_consumed := False;
      end if;
   end SetNextDirection;
   procedure DetermineNewFoodPosition (rand : Lin_t) is
   begin
      --- start searching from our random position, wrapping around
      for l in Lin_t range rand .. Lin_t'Last loop
         if board (l).usage = NONE then
               board (l).usage := FOOD;
               return;
         end if;
      end loop;
      --- Iterate the whole array although up to 'rand' would be sufficient.
      --- This is necessary so gnatprove is able to prove the postcondition.
      for l in Lin_t range Lin_t'Range loop
         if board (l).usage = NONE then
            board (l).usage := FOOD;
            return;
         end if;
         pragma Loop_Invariant
           (for all lin in Lin_t range Lin_t'First .. l =>
              board (lin).usage /= NONE);
      end loop;
      is_running := False;
      is_won := True;
   end DetermineNewFoodPosition;
end snake_generic;
