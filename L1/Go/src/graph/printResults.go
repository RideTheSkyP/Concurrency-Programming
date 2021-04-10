package graph

import 
(
	"fmt"
	"time"
)

func PrintResults() {
	for !Finish {
		time.Sleep(MessageDelay)
		msg := <- Messages
		fmt.Println(msg)
	}
	time.Sleep(MessageDelay * time.Duration(5))
	defer waitGroup.Done()
}