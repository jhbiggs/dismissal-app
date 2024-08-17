package tests

import (
	"bytes"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
	"github.com/stretchr/testify/assert"
	"dismissal.com/m/v2/database_service" 
	"dismissal.com/m/v2/go_objects"
	"database/sql"	
)

const schema_id = "test123"

func setupTestDB() {
	var conninfo string = "dbname=localdatabase user=justinbiggs password=Pcvh35$79 sslmode=disable"

	var err error
	database_service.DB, err = sql.Open("postgres", conninfo)
	if err != nil {
			panic(err)
	}


    // Create the dismissal_schema schema
    _, err = database_service.DB.Exec("CREATE SCHEMA IF NOT EXISTS " + schema_id + ";")
    if err != nil {
        panic(err)
    }

    // Create the teachers table within the dismissal_schema schema
		_, err = database_service.DB.Exec(`DROP TABLE IF EXISTS `+ schema_id + `.teachers`)
    _, err = database_service.DB.Exec(`CREATE TABLE IF NOT EXISTS `+ schema_id + `.teachers (
        teacherid INTEGER PRIMARY KEY,
        teachername TEXT,
        grade TEXT,
        arrived BOOLEAN
    )`)
	if err != nil {
			panic(err)
	}
}

func TestAddTeacher(t *testing.T) {
	// Set up the test database
	setupTestDB()

	// Set Gin to Test Mode
	gin.SetMode(gin.TestMode)

	// Create a new router
	router := gin.Default()
	router.POST("/:account_code/addTeacher", database_service.AddTeacher)

	// Create a new teacher
	newTeacher := go_objects.Teacher{
			TeacherID:      1,
			Name:    "John Doe",
			Grade:   "5th",
			Arrived: false,
	}
	jsonValue, _ := json.Marshal(newTeacher)
    // Create a response recorder
    w := httptest.NewRecorder()

    // Create a test context
    gin.CreateTestContext(w)

    // Create a mock request with the "dismissal_schema" query parameter
    req, err := http.NewRequest(http.MethodPost, "/"+ schema_id +"/addTeacher", bytes.NewBuffer(jsonValue))
    if err != nil {
        t.Fatalf("Couldn't create request: %v\n", err)
    }
	req.Header.Set("Content-Type", "application/json")

	// Perform the request
	router.ServeHTTP(w, req)

	// Check the status code
	assert.Equal(t, http.StatusOK, w.Code)

	// Check the response body
	var responseTeacher go_objects.Teacher
	err = json.Unmarshal(w.Body.Bytes(), &responseTeacher)
	if err != nil {
			t.Fatalf("Couldn't parse response body: %v\n", err)
	}
	assert.Equal(t, newTeacher, responseTeacher)

	// Check the state change in the database
	var dbTeacher go_objects.Teacher
	err = database_service.DB.QueryRow("SELECT teacherid, teachername, grade, arrived FROM "+schema_id+".teachers WHERE teacherid = $1", newTeacher.TeacherID).Scan(&dbTeacher.TeacherID, &dbTeacher.Name, &dbTeacher.Grade, &dbTeacher.Arrived)
	if err != nil {
			t.Fatalf("Couldn't query database: %v\n", err)
	}
	assert.Equal(t, newTeacher, dbTeacher)
}