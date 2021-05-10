with Ada.Text_IO; 
use Ada.Text_IO;  
with Ada.Command_Line;
with Graph;
with Parameters;

procedure Main is
	use Graph;
	ArgsAmount : Natural;
begin
	ArgsAmount := Ada.Command_Line.Argument_Count;
	IF ArgsAmount = 0 THEN
		Put_Line("Usage is: ./main [amount of vertices] [additional edges amount] [packages amount] [lifetime] [additional reverse edges amount]");
	ELSE
		FOR Count IN 1..ArgsAmount LOOP
			IF Count = 1 THEN
				Parameters.VerticesAmount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSIF Count = 2 THEN
				Parameters.AdditionalEdgesCount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSIF Count = 3 THEN
				Parameters.PackagesAmount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSIF Count = 4 THEN
				Parameters.PacketLifetime := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSIF Count = 5 THEN
				Parameters.AdditionalReverseEdgesAmount := Integer'Value(Ada.Command_Line.Argument(Number => Count));
			ELSE
				Put_Line("Usage is: ./main [amount of vertices] [additional edges amount] [packages amount] [lifetime] [additional reverse edges amount]");
				EXIT;
			END IF;
		END LOOP;

		IF (Parameters.AdditionalEdgesCount + Parameters.AdditionalReverseEdgesAmount) + (Parameters.VerticesAmount - 1) >= Parameters.VerticesAmount * (Parameters.VerticesAmount - 1) / 2 THEN
			Put_Line("Not appropriate amount of additional edges given");
		ELSE
			Put("Building graph with" &  Integer'Image(Parameters.VerticesAmount));
			Put(" vertices," & Integer'Image(Parameters.AdditionalEdgesCount));
			Put(" additional edges and" & Integer'Image(Parameters.PackagesAmount) & " packages. ");
			Put("Lifetime " & Integer'Image(Parameters.PacketLifetime));
			Put_Line(" additional reverse edges amount " & Integer'Image(Parameters.AdditionalReverseEdgesAmount));
	    	Start;
		END IF;
	END IF;
    
end Main;
