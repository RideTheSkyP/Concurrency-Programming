package graph

import 
(
	"fmt"
	"math/rand"
)

func BuildGraph() [VerticesAmount]Vertex {
	Vertices := [VerticesAmount]Vertex{}
	for i := 0; i < VerticesAmount - 1; i++ {
		Vertices[i].edges = append (Vertices[i].edges, i + 1)
		Vertices[i].packageId = -1
	} 

	Vertices[VerticesAmount-1].packageId = -1


	for i:=0 ; i < AdditionalEdgesCount; i++ {
		StartEdge := rand.Intn(VerticesAmount)
		FinishEdge := rand.Intn(VerticesAmount)
		wrongEdge := false
		if StartEdge != FinishEdge {
			if StartEdge > FinishEdge {
				StartEdge, FinishEdge = FinishEdge, StartEdge
			}

			for _, z := range Vertices[StartEdge].edges {
				if z == FinishEdge {
					wrongEdge = true
				}
			}

			if wrongEdge {
				i--
			} else {
				Vertices[StartEdge].edges = append(Vertices[StartEdge].edges, FinishEdge)
			}

		} else {
			i--
		}
	}

	for i := 0; i < VerticesAmount; i++ {
		fmt.Println("Vertex:", i, ". Connected to edges:", Vertices[i].edges)
	}
	fmt.Println()

	return Vertices
}