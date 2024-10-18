package main
import "fmt"
import "time"
func main() {
    for {
    fmt.Println("hello world")
    time.Sleep(30 * time.Second)
}
}