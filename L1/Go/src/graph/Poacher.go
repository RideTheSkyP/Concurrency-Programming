package graph

import
(
	"math/rand"
	"time"
	"strconv"
	"parameters"
)

func Poacher() {
	for !Finish {
		randomVertice := rand.Intn(parameters.VerticesAmount)
		msg := "Poacher set at vertex " + strconv.Itoa(randomVertice)
		Vertices[randomVertice].isPoached = true
		Messages <- msg
		time.Sleep(parameters.PoacherDelay * time.Duration(5))
	}
	defer waitGroup.Done()
}
