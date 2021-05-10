package Parameters is

	VerticesAmount					: Integer := 20;
	AdditionalEdgesCount			: Integer := 10;
	PackagesAmount					: Integer := 20;
	PacketLifetime 					: Integer := 20;
	AdditionalReverseEdgesAmount 	: Integer := 10;
   
	SenderDelay			: Duration := 2.0;
	RecipientDelay   	: Duration := 3.0;
	PackageDelay     	: Duration := 1.0;
	PoacherDelay 		: Duration := 15.0;
end Parameters;
