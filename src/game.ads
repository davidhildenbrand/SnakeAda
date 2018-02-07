with Glib.Object; use Glib.Object;
with Gdk.Event; use Gdk.Event;
with Gtk.Widget; use Gtk.Widget;
with Gtk.Drawing_Area; use Gtk.Drawing_Area;
with game_spark; use game_spark;
with Cairo; use Cairo;

package game is
   function On_Key_Press (Ent   : access GObject_Record'Class;
                          Event : Gdk_Event_Key) return Boolean;
   function On_Draw (Self : access Gtk_Widget_Record'Class;
                     Cr   : Cairo.Cairo_Context) return Boolean;
   task type GameTask is
   end GameTask;

   protected type game_control_t is
      procedure start;
      function is_started return Boolean;
      --- serialize access to out SPARK implementation
      procedure DoTick (rand : snake.Lin_t);
      procedure Reset (rand : snake.Lin_t);
      function GetState (position : snake.Position_t) return snake.State_t;
      function IsWon return Boolean;
      function IsLost return Boolean;
      function GetNrEaten return Natural;
      procedure SetNextDirection (new_direction : snake.Direction_t);
   private
      started : Boolean := False;
   end game_control_t;

   type game_control_a is access all game_control_t;
   function GetGameControl return game_control_a;

   function TriggerRedraw return Boolean;

   Draw : Gtk_Drawing_Area;
private
   game_task : GameTask;
   game_control : aliased game_control_t;
end game;
