package graph

import 
(
	"fmt"
)

func PrintResults() {
	for !Finish {
		msg := <- Messages
		fmt.Println(msg)
	}
}