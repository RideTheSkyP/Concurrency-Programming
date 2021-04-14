with Ada.Text_IO; 
use Ada.Text_IO;  
with Ada.Command_Line;
with Graph;
with Parameters;

procedure Main is
	use Graph;
	ArgsAmount : Natural;
begin
	
	Ada.Text_IO.Put(Item => Ada.Command_Line.Command_Name);
	ArgsAmount := Ada.Command_Line.Argument_Count;
	IF ArgsAmount = 0 THEN
		Put_Line("\nUsage is: ./main [amount of vertices] [additional edges amount] [packages amount]");
	ELSE
		Ada.Text_IO.Put_Line(Item => ": The command line arguments are: ");

		FOR Count IN 1..ArgsAmount LOOP
			IF Count = 1 THEN
				Parameters.VerticesAmount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSIF Count = 2 THEN
				Parameters.AdditionalEdgesCount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSIF Count = 3 THEN
				Parameters.PackagesAmount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSE
				Put_Line("\nUsage is: ./main [amount of vertices] [additional edges amount] [packages amount]");
				exit;
			END IF;
		END LOOP;
		Put("Building graph with" &  Integer'Image(Parameters.VerticesAmount));
		Put(" vertices," & Integer'Image(Parameters.AdditionalEdgesCount));
		Put_Line(" additional edges and" & Integer'Image(Parameters.PackagesAmount) & " packages");
    	Start;
	END IF;
    
end Main;
