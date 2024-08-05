package database_service

import (
	"database/sql"
	// "log"
	"fmt"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"unicode"
	"net/http"
)

var (
	DB *sql.DB
)

const (
	host     = "localhost"
	port     = 5432
	user     = "postgres"
	password = "Pcvh35$79"
	dbname   = "localdatabase"
)

func InitDB() {
	var err error
	psqlInfo := fmt.Sprintf("host=%s port=%d user=%s password=%s dbname=%s "+
		"sslmode=disable", host, port, user, password, dbname)
	//Opening Connection to local postgres database running on local port 5432.
	DB, err = sql.Open("postgres", psqlInfo)
	if err != nil {
		panic(err)
	}

	err = DB.Ping()
	if err != nil {
		panic(err)
	}
}

func GetDB() *sql.DB {
	fmt.Println("GetDB called")
	return DB
}

func CloseDB() {
	DB.Close()
}

func CheckSchemas(ctx *gin.Context) {

	// TODO: return the schema name if it exists

	fmt.Println("CheckSchemas called")
	var schemaName string
	schema_name := ctx.Param("account_code")
	if len(schema_name) != 6 {
		fmt.Println("Schema name is not required length")
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Schema name is not required length"})
		return
	}

	if !isAlphabetic(schema_name) {
		fmt.Println("Schema name should only contain alphabetic characters")
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": "Schema name should only contain alphabetic characters"})
		return
	}

	db := GetDB()
	err := db.QueryRow("SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1", schema_name).Scan(&schemaName)
	if err != nil {
		fmt.Println("Error querying the database: ", err)
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	if err != nil {
		fmt.Println("Error scanning the row: ", err)
		ctx.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return

	} else {
		fmt.Println("Schema name: ", schemaName)
		ctx.JSON(http.StatusOK, gin.H{"accountCode": schemaName})
	}

}

func isAlphabetic(str string) bool {
	for _, char := range str {
		if !unicode.IsLetter(char) {
			return false
		}
	}
	return true
}
