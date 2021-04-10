package graph

import 
(
	"math/rand"
	"time"
	"strconv"
)

func Recipient() {
	countPackages := 0
	for !Finish {
		if Vertices[VerticesAmount - 1].packageId != -1 {
			msg := "Packet " + strconv.Itoa(Vertices[VerticesAmount - 1].packageId) + " has been received."
			Messages <- msg
			Vertices[VerticesAmount - 1].packageId = -1
			countPackages++
		} 

		if countPackages == PackagesAmount {
			Finish = true
		}
		time.Sleep(RecipientDelay * time.Duration(rand.Intn(5)))
	}
	time.Sleep(RecipientDelay * time.Duration(5))
	defer waitGroup.Done()
}