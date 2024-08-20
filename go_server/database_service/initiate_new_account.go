package database_service

import (
	"fmt"
	"github.com/gin-gonic/gin"
	"math/rand"
	"time"
	"net/http"
	"io/ioutil"
	// "log"

)

// Perform the functions from the launch screen including
// creating a new account and receiving buses and teachers.

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
	_, err = GetDB().Exec(fmt.Sprintf("SET search_path TO %s", accountCodeStr))
	triggerSetupInstructions, err := ioutil.ReadFile("sql_files/trigger.sql")
	_, err = GetDB().Exec(string(triggerSetupInstructions))
	databaseSetupInstructions, err := ioutil.ReadFile("sql_files/dismissalStructureModifyPG.sql")
	_, err = GetDB().Exec(string(databaseSetupInstructions))

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