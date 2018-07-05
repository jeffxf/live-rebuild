package main

import (
	"github.com/gin-gonic/gin"
)

func main() {
	r := gin.Default()

	r.GET("/oldpath", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "Change this to see it rebuild :)",
		})
	})

	r.Run()
}
