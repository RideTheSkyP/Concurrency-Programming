package graph

import 
(
	"math/rand"
	"time"
	"strconv"
	"parameters"

)

func VerticesController(vertexId int) {
	for !Finish {
		if Vertices[vertexId].isObtained {
			nextVertex := Vertices[vertexId].edges[rand.Intn(len(Vertices[vertexId].edges))]
			for {
				if !Vertices[nextVertex].isObtained {
					
					Packages[Vertices[vertexId].packageId].lifetime++

					if Packages[Vertices[vertexId].packageId].lifetime > parameters.PacketLifetime {
						msg := "Packet " + strconv.Itoa(Vertices[vertexId].packageId) + " dead at vertex " + strconv.Itoa(vertexId) + ", due to lifetime end."
						Vertices[vertexId].isObtained = false
						Messages <- msg
						Vertices[vertexId].packageId = -1
						parameters.PackagesAmount--
						break
					}

					if Vertices[vertexId].isPoached {
						msg := "Packet " + strconv.Itoa(Vertices[vertexId].packageId) + " got stolen at vertex " + strconv.Itoa(vertexId)
						Vertices[vertexId].isPoached = false
						Vertices[vertexId].isObtained = false
						Messages <- msg
						Vertices[vertexId].packageId = -1
						parameters.PackagesAmount--
						break
					}

					Vertices[nextVertex].packageId = Vertices[vertexId].packageId
					Vertices[nextVertex].packagesVisited = append(Vertices[nextVertex].packagesVisited, Vertices[nextVertex].packageId)
					Packages[Vertices[nextVertex].packageId].verticesVisited = append(Packages[Vertices[nextVertex].packageId].verticesVisited, nextVertex)
					Vertices[vertexId].packageId = -1
					Vertices[nextVertex].isObtained = true
					Vertices[vertexId].isObtained = false

					msg := "Packet " + strconv.Itoa(Vertices[nextVertex].packageId) + " currently at vertex: " + strconv.Itoa(nextVertex)
					Messages <- msg

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
