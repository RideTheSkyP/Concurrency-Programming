package graph

import 
(
	"math/rand"
	"time"
	"strconv"
	"parameters"
)

func Recipient() {

	countPackages := 0
	s1 := rand.NewSource(time.Now().UnixNano())
	r1 := rand.New(s1) 
	r := rand.New(rand.NewSource(r1.Int63()))

	for !Finish {
		if Vertices[parameters.VerticesAmount - 1].isObtained {
			msg := "Packet " + strconv.Itoa(Vertices[parameters.VerticesAmount - 1].packageId) + " has been received."
			Messages <- msg
			Vertices[parameters.VerticesAmount - 1].packageId = -1
			Vertices[parameters.VerticesAmount - 1].isObtained = false
			countPackages++
		} 

		if countPackages == parameters.PackagesAmount {
			close(Messages)
			Finish = true
		}
		time.Sleep(time.Duration(r.Float64() * float64(time.Second)))
	}
	time.Sleep(parameters.RecipientDelay * time.Duration(5))
	defer waitGroup.Done()
}