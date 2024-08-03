package database_service

import (
	"database/sql"
	// "log"
	"fmt"

	"github.com/gin-gonic/gin"
	_ "github.com/lib/pq"
	"unicode"
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

	fmt.Println("CheckSchemas called")
	var schemaName string
	schema_name := ctx.Param("account_code")
	if len(schema_name) != 6 {
		fmt.Println("Schema name is not required length")
		return
	}
	if !isAlphabetic(schema_name) {
		fmt.Println("Schema name should only contain alphabetic characters")
		return
	}
	db := GetDB()
	err := db.QueryRow("SELECT schema_name FROM information_schema.schemata WHERE schema_name = $1", schema_name).Scan(&schemaName)
	if err != nil {
		fmt.Println("Error querying the database: ", err)
		return
	}
	if err != nil {
		fmt.Println("Error scanning the row: ", err)
		return
	} else {
		fmt.Println("Schema name: ", schemaName)
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
