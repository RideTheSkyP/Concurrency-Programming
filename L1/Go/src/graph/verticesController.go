package graph

import 
(
	"math/rand"
	"time"
	"strconv"
	"parameters"
	"fmt"
)

func VerticesController(vertexId int) {
	for !Finish {
		if Vertices[vertexId].isObtained {
			nextVertex := Vertices[vertexId].edges[rand.Intn(len(Vertices[vertexId].edges))]
			for {
				if !Vertices[nextVertex].isObtained {
					Vertices[nextVertex].packageId = Vertices[vertexId].packageId
					Vertices[vertexId].packageId = -1

					Vertices[nextVertex].packagesVisited = append(Vertices[nextVertex].packagesVisited, Vertices[nextVertex].packageId)
					Packages[Vertices[nextVertex].packageId].verticesVisited = append(Packages[Vertices[nextVertex].packageId].verticesVisited, nextVertex)

					Vertices[nextVertex].isObtained = true
					Vertices[vertexId].isObtained = false

					if Packages[Vertices[nextVertex].packageId].lifetime > parameters.PacketLifetime+1 {
						msg := "Packet " + strconv.Itoa(Vertices[nextVertex].packageId) + " dead at vertex: " + strconv.Itoa(nextVertex) + " due to lifetime end."
						Vertices[nextVertex].packageId = -1
						Vertices[nextVertex].isObtained = false
						Messages <- msg
						parameters.PackagesAmount -= 1
						break
					}

					msg := "Packet " + strconv.Itoa(Vertices[nextVertex].packageId) + " currently at vertex " + strconv.Itoa(nextVertex)
					Messages <- msg
					fmt.Println(nextVertex, Vertices[nextVertex].packageId)
					Packages[Vertices[nextVertex].packageId].lifetime += 1

					break
				} else {
					time.Sleep(parameters.PackageDelay * time.Duration(rand.Intn(10)))
					continue
				}	
			}
		}
		time.Sleep(parameters.PackageDelay * time.Duration(rand.Intn(5)))
	}
	time.Sleep(parameters.PackageDelay * time.Duration(5))
	defer waitGroup.Done()
}