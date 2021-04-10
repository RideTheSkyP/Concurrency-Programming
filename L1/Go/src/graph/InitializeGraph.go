package graph

import 
(
	"fmt"
	"sync"
)

type Vertex struct 
{
	edges []int
	packageId int
	packagesVisited []int
}

type Packet struct 
{
	verticesVisited []int
}

var (
	Vertices = [VerticesAmount]Vertex{}
	Packages = [PackagesAmount]Packet{}
	Messages = make(chan string)
	Finish = false
	waitGroup sync.WaitGroup
)

func InitializeGraph(){	
	Vertices = BuildGraph()
	go PrintResults()
	waitGroup.Add(1)
	go Sender()
	waitGroup.Add(1)
	go Recipient()
	waitGroup.Add(1)
	for i:=0 ; i < VerticesAmount - 1; i++ {
		waitGroup.Add(1)
		go VerticesController(i)
	}
	
	waitGroup.Wait()

	fmt.Println("\nVertex Report");
	for i:= 0; i < VerticesAmount; i++ {
		fmt.Println("Vertex: ", i, ". Visited packages: ", Vertices[i].packagesVisited)
	}

	fmt.Println("\nPackages Report");
	for i:= 0; i < PackagesAmount; i++ {
		fmt.Println("Packet: ", i, ". Visited vertices: ", Packages[i].verticesVisited)
	}
}
