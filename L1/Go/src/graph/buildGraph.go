package graph

import 
(
	"fmt"
	"math/rand"
	"parameters"
)

func BuildGraph() []Vertex {
	Vertices := make([]Vertex, parameters.VerticesAmount)
	
	for i := 0; i < parameters.VerticesAmount - 1; i++ {
		Vertices[i].edges = append(Vertices[i].edges, i + 1)
		Vertices[i].isObtained = false
		Vertices[i].packageId = -1
		Vertices[i].isPoached = false
	} 

	Vertices[parameters.VerticesAmount-1].packageId = -1
	Vertices[parameters.VerticesAmount-1].isObtained = false
	Vertices[parameters.VerticesAmount-1].isPoached = false

	addEdges := parameters.AdditionalEdgesAmount
	reverseAddEdges := parameters.AdditionalReverseEdgesAmount

	for i := 0 ; i < addEdges; i++ {
		StartEdge := rand.Intn(parameters.VerticesAmount)
		FinishEdge := rand.Intn(parameters.VerticesAmount)
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

	for i := 0 ; i < reverseAddEdges; i++ {
		StartEdge := rand.Intn(parameters.VerticesAmount)
		FinishEdge := rand.Intn(parameters.VerticesAmount)
		wrongEdge := false

		if StartEdge != FinishEdge {
			if StartEdge < FinishEdge {
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

	for i := 0; i < parameters.VerticesAmount; i++ {
		fmt.Println("Vertex:", i, ". Connected to edges:", Vertices[i].edges)
	}
	fmt.Println()

	return Vertices
}