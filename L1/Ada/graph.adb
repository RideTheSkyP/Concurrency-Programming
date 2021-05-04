with Ada.Text_IO;
use Ada.Text_IO;
with Parameters;
use Parameters;
with Ada.Numerics.Discrete_Random;
with Ada.Numerics.Float_Random;

package body Graph is

    function GetRandomDelay return Duration is
        G      : Ada.Numerics.Float_Random.Generator;
        Result : Float;
    begin
        Ada.Numerics.Float_Random.Reset(G);
        Result := Ada.Numerics.Float_Random.Random(G);
        return Duration(Result);
    end GetRandomDelay;


    procedure Start is
        Type Edges_array is array (0..AdditionalEdgesCount + 2) of Integer;
        Type PHistory is array (0..PackagesAmount) of Integer;
        Type VHistory is array (0..VerticesAmount) of Integer;

        Type Vertex is record
            Edges           : Edges_array;
            EdgesAmount     : Integer;
            PackageId       : Integer := -1;
            VerticesVisited : Integer := -1;
            PackagesVisited : PHistory;
            isPoached       : Boolean := false;
        End record;

        Type Packet is record
            VerticesVisited         : VHistory;
            AmountOfVisitedVertices : Integer := -1;
            Lifetime                : Integer := 0;
        End record;

        Type VerticesHistory is array (0..VerticesAmount - 1) of Vertex;
        Type PackageHistory is array (0..PackagesAmount - 1) of Packet;

        subtype PossibleRangeOfEdges is Integer range 0..VerticesAmount - 1;
        package GenerateRandomEdges is new Ada.Numerics.Discrete_Random(PossibleRangeOfEdges);
        use GenerateRandomEdges;
        RandomEdgesGenerator        : GenerateRandomEdges.Generator;

        Vertices                    : VerticesHistory;
        Packages                    : PackageHistory;
        PacketIsSent                : Boolean := False;
        EdgesAmountCounter          : Integer := 0;
        ReverseEdgesAmountCounter   : Integer := 0;
        StartEdge                   : Integer;
        FinishEdge                  : Integer;
        Temporary                   : Integer;
        WrongEdge                   : Boolean := false;

        subtype VerticesRange is Positive;
        package RandomVertices is new Ada.Numerics.Discrete_Random(VerticesRange);
        use RandomVertices;
        RandomVerticesGenerator : RandomVertices.Generator;

        Task PrintPackageFlow is
            entry PrintForPackageInVertex(packageId : in Integer; vertexId : in Integer);
            entry PrintPackageReceived(packageId : in Integer);
            entry PrintPackageDead(packageId : in Integer; vertexId : in Integer);
            entry PrintPackageStolen(packageId : in Integer; vertexId : in Integer);
            entry PrintPoacherAtVertex(vertexId : in Integer);
        end PrintPackageFlow;

        Task Body PrintPackageFlow is
        begin
            loop
                select
                    accept PrintForPackageInVertex (packageId : in Integer; vertexId : in Integer) do
                        Put_Line("Packet" & Integer'Image(packageId) & " currently at vertex" & Integer'Image(vertexId));
                    end PrintForPackageInVertex;
                or
                    accept PrintPackageReceived (packageId : in Integer) do
                        Put_Line("Packet" & Integer'Image(packageId) & " has been received.");
                    end PrintPackageReceived;
                or
                    accept PrintPackageDead (packageId : in Integer; vertexId : in Integer) do
                        Put_Line("Packet" & Integer'Image(packageId) & " dead at vertex " & Integer'Image(vertexId));
                    end PrintPackageDead;
                or
                    accept PrintPackageStolen (packageId : in Integer; vertexId : in Integer) do
                        Put_Line("Packet" & Integer'Image(packageId) & " has been stolen at vertex " & Integer'Image(vertexId));
                    end PrintPackageStolen;
                or
                    accept PrintPoacherAtVertex (vertexId : in Integer) do
                        Put_Line("Poacher set at vertex" & Integer'Image(vertexId));
                    end PrintPoacherAtVertex;
                or
                    delay 1.0;
                    exit when PacketIsSent;
                end select;
            end loop;
        end PrintPackageFlow;

        Task Type CreateSender;
        Task Body CreateSender is
            countPackages : Integer := 0;
        begin
            loop
                if Vertices(0).PackageId = -1 and countPackages < PackagesAmount then
                    Vertices(0).PackageId := countPackages;
                    Vertices(0).VerticesVisited := Vertices(0).VerticesVisited + 1;
                    Vertices(0).PackagesVisited(Vertices(0).VerticesVisited) := countPackages;

                    Packages(countPackages).AmountOfVisitedVertices := Packages(countPackages).AmountOfVisitedVertices + 1;
                    Packages(countPackages).VerticesVisited(Packages(countPackages).AmountOfVisitedVertices) := 0;

                    PrintPackageFlow.PrintForPackageInVertex(countPackages, 0);
                    countPackages := countPackages + 1;
                end if;

                exit when PacketIsSent;

                delay SenderDelay * GetRandomDelay;
            end loop;
        end CreateSender;

        Task Type CreateRecipient;
        Task Body CreateRecipient is
            countPackages : Integer := 0;
        begin
            loop
                if Vertices(VerticesAmount - 1).PackageId /= -1 then
                    PrintPackageFlow.PrintPackageReceived(Vertices(VerticesAmount-1).PackageId);
                    Vertices(VerticesAmount - 1).PackageId := -1;
                    countPackages := countPackages + 1;
                end if;

                if countPackages = PackagesAmount then
                    PacketIsSent := true;
                end if;
                exit when PacketIsSent;

                delay RecipientDelay * GetRandomDelay;
            end loop;
        end CreateRecipient;

        Task Type CreatePoacher;
        Task Body CreatePoacher is
            subtype PossibleRangeOfVertices is Integer range 1..VerticesAmount - 1;
            package GenerateRandomVertex is new Ada.Numerics.Discrete_Random(PossibleRangeOfVertices);
            use GenerateRandomVertex;
            RandomVertexGenerator   : GenerateRandomVertex.Generator;
            RandomVertex            : Integer := 1;
        begin
            loop
                if not PacketIsSent then
                    reset(RandomVertexGenerator);
                    RandomVertex := Random(RandomVertexGenerator);
                    PrintPackageFlow.PrintPoacherAtVertex(RandomVertex);
                    Vertices(RandomVertex).isPoached := true;
                end if;

                exit when PacketIsSent;

                delay PoacherDelay * GetRandomDelay;    
            end loop;
        end CreatePoacher;

        Task Type VerticesController(vertexId : Integer);
        Task Body VerticesController is
            currentVertex   : Integer := vertexId;
            nextVertex      : Integer;
        begin
            loop
                delay PackageDelay * GetRandomDelay;
                if Vertices(currentVertex).PackageId /= -1 then
                    reset(RandomVerticesGenerator);
                    nextVertex := Vertices(currentVertex).Edges(Random(RandomVerticesGenerator) mod Vertices(currentVertex).EdgesAmount);
                    loop
                        if Vertices(nextVertex).PackageId = -1 then

                            Vertices(nextVertex).PackageId := Vertices(currentVertex).PackageId;
                            Packages(Vertices(currentVertex).PackageId).Lifetime := Packages(Vertices(nextVertex).PackageId).Lifetime + 1;

                            if Packages(Vertices(currentVertex).PackageId).Lifetime = PacketLifetime + 1 then
                                Vertices(nextVertex).PackageId := -1;
                                PrintPackageFlow.PrintPackageDead(Vertices(currentVertex).PackageId, currentVertex);
                                Vertices(currentVertex).PackageId := -1;
                                PackagesAmount := PackagesAmount - 1;
                                exit;
                            end if;

                            if Vertices(currentVertex).isPoached then
                                Vertices(nextVertex).PackageId := -1;
                                Vertices(currentVertex).isPoached := false;
                                PrintPackageFlow.PrintPackageStolen(Vertices(currentVertex).PackageId, currentVertex);
                                Vertices(currentVertex).packageId := -1;
                                PackagesAmount := PackagesAmount - 1;
                                exit;
                            end if;

                            Vertices(nextVertex).VerticesVisited := Vertices(nextVertex).VerticesVisited + 1;
                            Vertices(nextVertex).PackagesVisited(Vertices(nextVertex).VerticesVisited) := Vertices(currentVertex).PackageId;
                            Packages(Vertices(nextVertex).PackageId).AmountOfVisitedVertices := Packages(Vertices(nextVertex).PackageId).AmountOfVisitedVertices + 1;
                            Packages(Vertices(nextVertex).PackageId).VerticesVisited(Packages(Vertices(nextVertex).PackageId).AmountOfVisitedVertices) := nextVertex;
                            Vertices(currentVertex).PackageId := -1;
                            PrintPackageFlow.PrintForPackageInVertex(Vertices(nextVertex).PackageId, nextVertex);
                            exit;
                            
                        else
                            delay PackageDelay * GetRandomDelay;
                        end if;
                    end loop;
                end if;
                exit when PacketIsSent;
            end loop;
        end VerticesController;

        Task Type ExecutionFinished(VA : Integer; PA : Integer);
        Task Body ExecutionFinished is
            V   : Integer := VA;
            P   : Integer := PA;
        begin
            loop
                if PacketIsSent then
                    New_Line;
                    Put_Line("Vertex Report");
                    for I in 0..VA - 1 loop
                        Put("Vertex:" & Integer'Image(I) & ". Visited packages:");
                        If Vertices(I).VerticesVisited = -1 then
                            Put(" Not visited");
                        else
                            For J in 0..Vertices(I).VerticesVisited loop
                            Put(Integer'Image(Vertices(I).PackagesVisited(J)));
                            end loop;
                        end if;
                        New_Line;
                    end loop;

                    New_Line;
                    Put_Line("Packages Report");
                    for I in 0..PA - 1 loop
                        Put("Package:" & Integer'Image(I) & ". Visited vertices:");
                        For J in 0..Packages(I).AmountOfVisitedVertices loop
                            Put(Integer'Image(Packages(I).VerticesVisited(J)));
                        end loop;
                        New_Line;
                    end loop;
                    exit;
                else
                    delay 3.0;
                end if;
            end loop;
        end ExecutionFinished;

        Sender          : access CreateSender;
        Recipient       : access CreateRecipient;
        Poacher         : access CreatePoacher;
        Controller      : array (0..VerticesAmount - 2) of access VerticesController;
        PrintResults    : access ExecutionFinished;
        VA              : Integer;
        PA              : Integer;

    begin
        Vertices(VerticesAmount - 1).EdgesAmount := 0;

        VA := VerticesAmount;
        PA := PackagesAmount;

        For I in 0..VerticesAmount-2 loop
            Vertices(I).EdgesAmount := 1;
            Vertices(I).Edges(0) := I + 1;
        end loop;

        while EdgesAmountCounter < AdditionalEdgesCount loop
            reset(RandomEdgesGenerator);
            WrongEdge   := false;
            StartEdge   := Random(RandomEdgesGenerator);
            FinishEdge  := Random(RandomEdgesGenerator);

            If (StartEdge /= FinishEdge) then 
                If (StartEdge > FinishEdge) then 
                    Temporary   := StartEdge;
                    StartEdge   := FinishEdge;
                    FinishEdge  := Temporary;
                end if;

                for I in 0..Vertices(StartEdge).EdgesAmount - 1 loop
                    if Vertices(StartEdge).Edges(I) = FinishEdge then
                        WrongEdge := true;
                    end if;
                end loop;
                If not WrongEdge then
                    Vertices(StartEdge).Edges(Vertices(StartEdge).EdgesAmount) := FinishEdge;
                    Vertices(StartEdge).EdgesAmount := Vertices(StartEdge).EdgesAmount + 1;
                    EdgesAmountCounter := EdgesAmountCounter + 1;
                end if;
            end if;
        end loop;

        while ReverseEdgesAmountCounter < AdditionalReverseEdgesAmount loop
            reset(RandomEdgesGenerator);
            WrongEdge   := false;
            StartEdge   := Random(RandomEdgesGenerator);
            FinishEdge  := Random(RandomEdgesGenerator);

            If (StartEdge /= FinishEdge) then 
                If (StartEdge < FinishEdge) then 
                    Temporary   := StartEdge;
                    StartEdge   := FinishEdge;
                    FinishEdge  := Temporary;
                end if;

                for I in 0..Vertices(StartEdge).EdgesAmount - 1 loop
                    if Vertices(StartEdge).Edges(I) = FinishEdge then
                        WrongEdge := true;
                    end if;
                end loop;
                If not WrongEdge then
                    Vertices(StartEdge).Edges(Vertices(StartEdge).EdgesAmount) := FinishEdge;
                    Vertices(StartEdge).EdgesAmount := Vertices(StartEdge).EdgesAmount + 1;
                    ReverseEdgesAmountCounter := ReverseEdgesAmountCounter + 1;
                end if;
            end if;
        end loop;

        For I in 0..VerticesAmount - 1 loop
            Put("Vertex:" & Integer'Image(I) & ". Connected to edges:");
            For J in 0..Vertices(I).EdgesAmount - 1 loop
                Put(Integer'Image(Vertices(I).Edges(J)));
            end loop;
            New_Line;
        end loop;
        New_Line;

        Sender      := new CreateSender;
        Recipient   := new CreateRecipient;
        Poacher     := new CreatePoacher;
        for I in 0..VerticesAmount - 2 loop
            Controller(I) := new VerticesController(I);
        end loop;
        PrintResults := new ExecutionFinished(VA, PA);
    end Start;
end Graph;