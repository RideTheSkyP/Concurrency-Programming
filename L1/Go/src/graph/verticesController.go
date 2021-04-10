package graph

import 
(
	"math/rand"
	"time"
	"strconv"
)

func VerticesController(vertexId int) {
	for !Finish {
		if Vertices[vertexId].packageId != -1 {
			next_vertex := Vertices[vertexId].edges[rand.Intn(len(Vertices[vertexId].edges))]
			for {
				if Vertices[next_vertex].packageId == -1 {
					Vertices[next_vertex].packageId = Vertices[vertexId].packageId
					Vertices[vertexId].packageId = -1
					Vertices[next_vertex].packagesVisited = append(Vertices[next_vertex].packagesVisited, Vertices[next_vertex].packageId)
					Packages[Vertices[next_vertex].packageId].verticesVisited = append(Packages[Vertices[next_vertex].packageId].verticesVisited, next_vertex)

					msg := "Packet " + strconv.Itoa(Vertices[next_vertex].packageId) + " currently at vertex " + strconv.Itoa(next_vertex)
					Messages <- msg
					break;
				} else {
					time.Sleep(PackageDelay * time.Duration(rand.Intn(10)))
					continue
				}
			}
		}
		time.Sleep(PackageDelay * time.Duration(rand.Intn(5)))
	}
	time.Sleep(PackageDelay * time.Duration(5))
	defer waitGroup.Done()
}