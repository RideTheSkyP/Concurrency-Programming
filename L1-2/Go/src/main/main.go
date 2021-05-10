package main

import 
(
	"graph"
	"os"
	"fmt"
	"parameters"
	"strconv"
)

func main() {
	fmt.Println("Usage is: ./main [amount of vertices] [additional edges amount] [packages amount] [lifetime] [additional reverse edges amount]")
	argsWithoutProg := os.Args[1:]
	num1, err1 := strconv.Atoi(argsWithoutProg[0])
	num2, err2 := strconv.Atoi(argsWithoutProg[1])
	num3, err3 := strconv.Atoi(argsWithoutProg[2])
	num4, err4 := strconv.Atoi(argsWithoutProg[3])
	num5, err5 := strconv.Atoi(argsWithoutProg[4])

	if err1 != nil || err2 != nil || err3 != nil || err4 != nil || err5 != nil{ 
		fmt.Println("Usage is: ./main [amount of vertices] [additional edges amount] [packages amount] [lifetime] [additional reverse edges amount]")
	} else {
		if (num2+num5)+(num1-1) >= num1*(num1-1)/2 {
			fmt.Println("Not appropriate amount of additional edges given")
		} else {
			parameters.VerticesAmount = num1
			parameters.AdditionalEdgesAmount = num2
			parameters.PackagesAmount = num3
			parameters.PacketLifetime = num4
			parameters.AdditionalReverseEdgesAmount = num5
			graph.InitializeGraph()
		}
	}
}
