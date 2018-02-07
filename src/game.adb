with Gdk.Types;                  use Gdk.Types;
with Gdk.Types.Keysyms;          use Gdk.Types.Keysyms;
with Ada.Real_Time; use Ada.Real_Time;
with Gtk.Main;
with Gdk; use Gdk;
with Glib; use Glib;
with Ada.Numerics;
with Ada.Numerics.Discrete_Random;

package body game is
   use snake;

   package rand is new Ada.Numerics.Discrete_Random (Lin_t);
   seed : rand.Generator;

   function On_Key_Press
     (Ent   : access GObject_Record'Class;
      Event : Gdk_Event_Key) return Boolean
   is
      pragma Unreferenced (Ent);
   begin
      if Event.Keyval = GDK_KP_Down
        or else Event.Keyval = GDK_Down
        or else Event.Keyval = GDK_LC_s
      then
         game_control.SetNextDirection (DOWN);
      elsif Event.Keyval = GDK_KP_Up
        or else Event.Keyval = GDK_Up
        or else Event.Keyval = GDK_LC_w
      then
         game_control.SetNextDirection (UP);
      elsif Event.Keyval = GDK_KP_Left
        or else Event.Keyval = GDK_Left
        or else Event.Keyval = GDK_LC_a
      then
         game_control.SetNextDirection (LEFT);
      elsif Event.Keyval = GDK_KP_Right
        or else Event.Keyval = GDK_Right
        or else Event.Keyval = GDK_LC_d
      then
         game_control.SetNextDirection (RIGHT);
      elsif Event.Keyval = GDK_LC_r then
         game_control.Reset (rand.Random (seed));
      elsif Event.Keyval = GDK_LC_q
        or else Event.Keyval = GDK_Escape
      then
         Gtk.Main.Main_Quit;
      end if;
      return False;
   end On_Key_Press;

   function On_Draw (Self : access Gtk_Widget_Record'Class;
                     Cr   : Cairo.Cairo_Context) return Boolean is
      pragma Unreferenced (Self);
      position : Position_t;
      state : State_t;
   begin
      --  clear the surface first
      Set_Source_Rgb (Cr, 0.7176, 0.7529, 0.0);
      Cairo.Paint (Cr);

      --  draw the border
      Set_Source_Rgb (Cr, 0.3961, 0.3098, 0.0471);
      for x in Integer range 0 .. (40 + 1) loop
         --  top line
         Cairo.Rectangle (Cr => Cr, X => Gdouble (x * 11), Y => Gdouble (0),
                          Width => Gdouble (10), Height => Gdouble (10));
         Cairo.Fill_Preserve (Cr);
         --  middle line
         Cairo.Rectangle (Cr => Cr, X => Gdouble (x * 11),
                          Y => Gdouble (11 * 21), Width => Gdouble (10),
                          Height => Gdouble (10));
         Cairo.Fill_Preserve (Cr);
         --  bottom line
         Cairo.Rectangle (Cr => Cr, X => Gdouble (x * 11),
                          Y => Gdouble (11 * 25), Width => Gdouble (10),
                          Height => Gdouble (10));
         Cairo.Fill_Preserve (Cr);
      end loop;
      for y in Integer range 0 .. (20 + 1 + 4) loop
         --  left line
         Cairo.Rectangle (Cr => Cr, X => Gdouble (0), Y => Gdouble (y * 11),
                          Width => Gdouble (10), Height => Gdouble (10));
         Cairo.Fill_Preserve (Cr);
         --  right line
         Cairo.Rectangle (Cr => Cr, X => Gdouble (11 * 41),
                          Y => Gdouble (y * 11), Width => Gdouble (10),
                          Height => Gdouble (10));
         Cairo.Fill_Preserve (Cr);
      end loop;

      --- draw some help text
      Cairo.Select_Font_Face (Cr, "Times", Cairo_Font_Slant_Normal,
                              Cairo_Font_Weight_Bold);
      Cairo.Set_Font_Size (Cr, Gdouble (14));
      Cairo.Move_To (Cr, Gdouble (22), Gdouble ((20 + 4) * 11));
      Cairo.Show_Text (Cr, "Use arrows to control the Snake. " &
                           "Press r to restart. Press q to quit.");

      if game_control.IsLost or game_control.IsWon then
         Cairo.Set_Font_Size (Cr, Gdouble (50));
         Cairo.Move_To (Cr, Gdouble (80), Gdouble (8 * 11));
         if game_control.IsLost then
            Cairo.Show_Text (Cr, "GAME OVER");
         else
            Cairo.Show_Text (Cr, "! YOU WON !");
         end if;

         Cairo.Set_Font_Size (Cr, Gdouble (40));
         Cairo.Move_To (Cr, Gdouble (20 * 11), Gdouble (14 * 11));
         Cairo.Show_Text (Cr, game_control.GetNrEaten'Image);
         Cairo.Set_Font_Size (Cr, Gdouble (30));
         Cairo.Move_To (Cr, Gdouble (15 * 11), Gdouble (18 * 11));
         Cairo.Show_Text (Cr, "Pieces eaten!");
         return False;
      end if;

      --- draw the snake and the food
      for x in Integer range 1 .. 40 loop
         for y in Integer range 1 .. 20 loop
            position := (Row_t (y), Column_t (x));
            state := game_control.GetState (position);
            if state = game_spark.snake.FOOD
              or state = game_spark.snake.SNAKE
            then
               Cairo.Rectangle (Cr => Cr, X => Gdouble (x * 11),
                                Y => Gdouble (y * 11), Width => Gdouble (10),
                                Height => Gdouble (10));
               Cairo.Fill_Preserve (Cr);
            end if;
         end loop;
      end loop;
      return False;
   end On_Draw;

   protected body game_control_t is
      procedure start is
      begin
         started := True;
      end start;
      function is_started return Boolean is
      begin
         return started;
      end is_started;
      procedure DoTick (rand : Lin_t) is
      begin
         game_spark.snake.DoTick (rand);
      end DoTick;
      procedure Reset (rand : Lin_t) is
      begin
         game_spark.snake.Reset (rand);
      end Reset;
      function GetState (position : Position_t) return State_t is
      begin
         return game_spark.snake.GetState (position);
      end GetState;
      function IsWon return Boolean is
      begin
         return game_spark.snake.IsWon;
      end IsWon;
      function IsLost return Boolean is
      begin
         return game_spark.snake.IsLost;
      end IsLost;
      function GetNrEaten return Natural is
      begin
         return game_spark.snake.GetNrEaten;
      end GetNrEaten;
      procedure SetNextDirection (new_direction : Direction_t) is
      begin
         game_spark.snake.SetNextDirection (new_direction);
      end SetNextDirection;
   end game_control_t;

   task body GameTask is
      next : Time := Clock;
   begin
      Reset (rand.Random (seed));
      loop
         next := next + Milliseconds (100);
         delay until next;
         if game_control.is_started then
            DoTick (rand.Random (seed));
         end if;
      end loop;
   end GameTask;

   function TriggerRedraw return Boolean is
   begin
      Draw.Queue_Draw;
      return True;
   end TriggerRedraw;

   function GetGameControl return game_control_a is
   begin
      return game_control'Unchecked_Access;
   end GetGameControl;
end game;
