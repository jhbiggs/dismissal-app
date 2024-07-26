package database_service

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"math/rand"
	"time"
	"net/http"
	// "github.com/lib/pq"
	// "sync"
)

func InitiateNewAccount(ctx *gin.Context)  {
	fmt.Println("InitiateNewAccount called")

	// get new account id

	rand.Seed(time.Now().UnixNano())

	var letterRunes = []rune("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

	accountCode := make([]rune, 6)
	for i := range accountCode {
		accountCode[i] = letterRunes[rand.Intn(len(letterRunes))]
	}
	fmt.Println("letterRunes: ", string(accountCode))


	// set up Postgres schema for new account
	accountCodeStr := string(accountCode)
	_, err := GetDB().Exec(fmt.Sprintf("CREATE SCHEMA %s", accountCodeStr))
	if err != nil {
		fmt.Println("Error updating the database: ", err)
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// return success message with shareable account id
	ctx.JSON(http.StatusOK, gin.H{
		"message": "Account created with code: ",
		"accountCode": accountCodeStr,
	})


	return 
}