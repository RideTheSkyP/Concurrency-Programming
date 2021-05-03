package graph

import
(
	"fmt"
	"sync"
	"parameters"
)

type Vertex struct
{
	edges []int
	packageId int
	packagesVisited []int
	isObtained bool
}

type Packet struct
{
	verticesVisited []int
	lifetime int
}

var (
	Vertices = make([]Vertex, parameters.VerticesAmount)
	Packages = make([]Packet, parameters.PackagesAmount)
	Messages = make(chan string)
	Finish = false
	waitGroup sync.WaitGroup
)

func InitializeGraph() {
	Vertices = BuildGraph()

	VerticesAmount := parameters.VerticesAmount
	PackagesAmount := parameters.PackagesAmount

	go PrintResults()

	go Sender()
	waitGroup.Add(1)
	go Recipient()
	waitGroup.Add(1)
	for i:=0 ; i < parameters.VerticesAmount - 1; i++ {
		waitGroup.Add(1)
		go VerticesController(i)
	}
	
	waitGroup.Wait()

	fmt.Println("\nVertex Report")
	for i:= 0; i < VerticesAmount; i++ {
		fmt.Println("Vertex: ", i, ". Visited packages:", Vertices[i].packagesVisited)
	}

	fmt.Println("\nPackages Report")
	for i:= 0; i < PackagesAmount; i++ {
		fmt.Println("Packet: ", i, ". Visited vertices:", Packages[i].verticesVisited)
	}
}
