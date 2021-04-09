with Ada.Text_IO; 
use Ada.Text_IO;  
with Parameters; 
use Parameters;
with Ada.Numerics.Discrete_Random;

package body Graph is 
    Type Edges_array is array (0 .. ExtraEdgesAmount + 2) of Integer;
    Type PHistory is array (0..PackagesAmount) of Integer;
    Type VHistory is array (0..VerticesAmount) of Integer;

    Type Vertex is record
            EdgesAmount     : Integer;
            Edges           : Edges_array;
            PackageId       : Integer := -1;
            PackageAmount   : Integer := -1;
            PackagesHistory : PHistory; 
    End record;

    Type Packages is record
            AmountOfVisitedVertices : Integer := -1;
            VisitedVertices         : VHistory;
    End record;

    Type VerticesHistory is array (0..VerticesAmount - 1) of Vertex;
    Type PackageHistory is array (0..PackagesAmount - 1) of Packages;
    
    subtype PossibleRangeOfEdges is Integer range 0..VerticesAmount - 1;
    package GenerateRandomEdges is new Ada.Numerics.Discrete_Random(PossibleRangeOfEdges); 
    use GenerateRandomEdges;
    RandomEdgesGenerator : GenerateRandomEdges.Generator;
    

    procedure BuildGraph(graph : in out VerticesHistory) is
        EdgesAmountCounter : Integer := 0;
        StartEdge   : Integer;
        FinishEdge  : Integer;
        Temporary   : Integer;
        WrongEdge   : Boolean := false;
    begin

        graph(VerticesAmount - 1).EdgesAmount := 0;

        For I in 0..VerticesAmount-2 loop
            graph(I).EdgesAmount := 1;
            graph(I).Edges(0) := I + 1;
        end loop;

        while EdgesAmountCounter < ExtraEdgesAmount loop
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

                for I in 0..graph(StartEdge).EdgesAmount - 1 loop
                    if graph(StartEdge).Edges(I) = FinishEdge then 
                        WrongEdge := true;
                    end if;  
                end loop;
                If not WrongEdge then
                    graph(StartEdge).Edges(graph(StartEdge).EdgesAmount) := FinishEdge;
                    graph(StartEdge).EdgesAmount := graph(StartEdge).EdgesAmount + 1;
                    EdgesAmountCounter := EdgesAmountCounter + 1;
                end if;
            end if;
        end loop;

        For I in 0..VerticesAmount - 1 loop
            Put("Vertex:" & Integer'Image(I) & ". Connected to edges:");
            For J in 0..graph(I).EdgesAmount - 1 loop
                Put(Integer'Image(graph(I).Edges(J)));
            end loop;
            New_Line;
        end loop;
        New_Line;
    end BuildGraph;    


    procedure Start is
        Vertices    : VerticesHistory;
        Packages    : PackageHistory;
        PacketSent  : Boolean := False;

        subtype RangeOfDelay is Integer range 1..10;
        package RandomDelay is new Ada.Numerics.Discrete_Random(RangeOfDelay); 
        use RandomDelay;
        DelayGenerator : RandomDelay.Generator;

        subtype VerticesRange is Positive;
        package RandomVertices is new Ada.Numerics.Discrete_Random(VerticesRange); 
        use RandomVertices;
        RandomVerticesGenerator : RandomVertices.Generator;         

        Task PrintPackageFlow is
            entry PrintForPackageInVertex(packageId : in Integer; vertexId : in Integer);
            entry PrintPackageReceived(packageId : in Integer);
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
                        Put_Line("Packet:" & Integer'Image(packageId) & " has been received.");   
                    end PrintPackageReceived; 
                or 
                    delay 1.0;  
                    exit when PacketSent; 
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
                    Vertices(0).PackageAmount := Vertices(0).PackageAmount + 1;
                    Vertices(0).PackagesHistory(Vertices(0).PackageAmount) := countPackages;

                    Packages(countPackages).AmountOfVisitedVertices := Packages(countPackages).AmountOfVisitedVertices + 1;
                    Packages(countPackages).VisitedVertices(Packages(countPackages).AmountOfVisitedVertices) := 0;

                    PrintPackageFlow.PrintForPackageInVertex(countPackages, 0);
                    countPackages := countPackages + 1;
                end if;   

                exit when PacketSent;

                Reset(DelayGenerator);
                delay SenderDelay * Random(DelayGenerator); 
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
                    PacketSent := true;
                end if;
                exit when PacketSent; 

                Reset(DelayGenerator);
                delay RecipientDelay * Random(DelayGenerator);
            end loop;
        end CreateRecipient;

        Task Type VertexController(vertexId : Integer);
        Task Body VertexController is
            currentVertex   : Integer := vertexId;
            nextVertex      : Integer;
        begin
            loop
                delay PackageDelay * Random(DelayGenerator);
                if Vertices(currentVertex).PackageId /= -1 then 
                    reset(RandomVerticesGenerator);
                    nextVertex := Vertices(currentVertex).Edges(Random(RandomVerticesGenerator) mod Vertices(currentVertex).EdgesAmount);
                    loop
                        if Vertices(nextVertex).PackageId = -1 then
                            Vertices(nextVertex).PackageId := Vertices(currentVertex).PackageId;
                            Vertices(nextVertex).PackageAmount := Vertices(nextVertex).PackageAmount + 1;
                            Vertices(nextVertex).PackagesHistory(Vertices(nextVertex).PackageAmount) := Vertices(currentVertex).PackageId;

                            Packages(Vertices(nextVertex).PackageId).AmountOfVisitedVertices := Packages(Vertices(nextVertex).PackageId).AmountOfVisitedVertices + 1;
                            Packages(Vertices(nextVertex).PackageId).VisitedVertices(Packages(Vertices(nextVertex).PackageId).AmountOfVisitedVertices) := nextVertex;

                            Vertices(currentVertex).PackageId := -1;
                            PrintPackageFlow.PrintForPackageInVertex(Vertices(nextVertex).PackageId, nextVertex);
                            exit;
                        else
                            Reset(DelayGenerator);
                            delay PackageDelay * Random(DelayGenerator);
                        end if;
                    end loop;    
                end if;
                exit when PacketSent;
                Reset(DelayGenerator);
            end loop;
        end VertexController;

        Task Type ExcutionFinished;
        Task Body ExcutionFinished is
        begin
            loop
                if PacketSent then
                    New_Line;
                    Put_Line("Vertex Report");
                    for I in 0..VerticesAmount - 1 loop
                        Put("Vertex:" & Integer'Image(I) & ". Visited packages:");
                        If Vertices(I).PackageAmount = -1 then
                            Put(" Not visited");
                        else 
                            For J in 0..Vertices(I).PackageAmount loop
                            Put(Integer'Image(Vertices(I).PackagesHistory(J)));
                            end loop;
                        end if;
                        New_Line;
                    end loop;

                    New_Line;
                    Put_Line("Packages Report");
                    for I in 0..PackagesAmount - 1 loop
                        Put("Package:" & Integer'Image(I) & ". Visited vertices:");
                        For J in 0..Packages(I).AmountOfVisitedVertices loop
                            Put(Integer'Image(Packages(I).VisitedVertices(J)));
                        end loop;
                        New_Line;
                    end loop;
                    exit;
                else
                    delay 3.0;
                end if;
            end loop;    
        end ExcutionFinished;

        Sender : access CreateSender;
        Recipient : access CreateRecipient;
        Controller : array (0..VerticesAmount - 2) of access VertexController;
        PrintResults : access ExcutionFinished;
    begin
        BuildGraph(Vertices);
        Sender := new CreateSender;
        Recipient := new CreateRecipient;
        for I in 0..VerticesAmount - 2 loop
            Controller(I) := new VertexController(I);
        end loop;
        PrintResults := new ExcutionFinished;
    end Start;
end Graph;