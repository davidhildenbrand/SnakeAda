with snake_generic;

--- We have to put this into a separate package, as the generic is instantiated
--- here, so SPARK_Mode is required at this point. However, GTKADA is not
--- compatible with SPARK_MODE, so we can't move this e.g. to package game.
package game_spark with SPARK_Mode is
   --- Snake with 20 columns and 40 rows
   package snake is new snake_generic (20, 40);
end game_spark;
