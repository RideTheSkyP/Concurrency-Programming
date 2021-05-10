package graph

import 
(
	"math/rand"
	"time"
	"strconv"
	"parameters"
)

func Sender() {
	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1) 
	r := rand.New(rand.NewSource(r1.Int63()))
	countPackages := 0

	for countPackages < parameters.PackagesAmount {
		if !Vertices[0].isObtained {
			Vertices[0].packageId = countPackages
			Vertices[0].packagesVisited = append(Vertices[0].packagesVisited, countPackages)
			Packages[countPackages].verticesVisited = append(Packages[countPackages].verticesVisited, 0)
			msg := "Packet " + strconv.Itoa(countPackages) + " currently at vertex: " + strconv.Itoa(0)
			Vertices[0].isObtained = true
			countPackages++
			Messages <- msg
		} 
		time.Sleep(time.Duration(r.Float64() * float64(time.Second)))
	}
	time.Sleep(parameters.SenderDelay * time.Duration(5))
	defer waitGroup.Done()
}