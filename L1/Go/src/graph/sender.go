package graph

import 
(
	"math/rand"
	"time"
	"strconv"
)

func Sender() {
	countPackages := 0
	for countPackages < PackagesAmount {
		if Vertices[0].packageId == -1 {
			Vertices[0].packageId = countPackages
			Vertices[0].packagesVisited = append(Vertices[0].packagesVisited, countPackages)
			Packages[countPackages].verticesVisited = append(Packages[countPackages].verticesVisited, 0)
			msg := "Packet " + strconv.Itoa(countPackages) + " currently at vertex: " + strconv.Itoa(0)
			Messages <- msg
			countPackages++
		} 
		time.Sleep(SenderDelay * time.Duration(rand.Intn(5)))
	}
	time.Sleep(SenderDelay * time.Duration(5))
	defer waitGroup.Done()
}