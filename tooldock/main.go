package main

import (
	"os"

	"github.com/Saurav-Paul/tooldock/cmd"
)

func main() {
	if err := cmd.Execute(); err != nil {
		os.Exit(1)
	}
}
