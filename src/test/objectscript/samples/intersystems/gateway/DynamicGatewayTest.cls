/// This class is a refactored version of the %Net.Remote.Java.Test class that was previously
/// delivered with IRIS in the ./dev/java/samples folder.
/// </p>
/// <p>
/// This is implemented as a %UnitTest.TestCase that is expected to be run using IPMS.
Class samples.intersystems.gateway.DynamicGatewayTest Extends %UnitTest.TestCase
{

Property gateway As %External.JavaGateway;

Method OnBeforeAllTests() as %Status
{
	set jarPath = "/home/danp/community/projects/samples-dynamicgateway-java/target/samples-dynamicgateway-java-1.0.0.jar" // ..Manager.jarPath
	set ..gateway = $SYSTEM.external.getJavaGateway()
	do $$$LogMessage("OnBeforeAll: jarPath = " _ jarPath _ ", intersystems-jdbc version = '" _ ..gateway.getExternalLanguageVersion() _ "'")
	do ..gateway.addToPath(jarPath)
	do $$$LogMessage("OnBeforeAll: Added "_jarPath_" to Gateway Path")
	return $$$OK
}

method OnAfterAllTests() as %Status {
    return $$$OK
}

/// This shows how to use the Java Gateway with ObjectScript. There is no setup necessary, other than to
/// make certain that the default Java Gateway is properly configured and runs (use the SMP to check)
Method TestBasics() [ Final ]
{
	try {
    	do $$$LogMessage("intersystems-jdbc version = '" _ ..gateway.getProductVersion() _ "'")
	    try {
        	set student = ..createStudent(29, "976-01-6712")
        	do $$$AssertTrue($ISOBJECT(student),"samples.intersystems.gateway.Student - instantiated with args [29, '976-01-6712']")
        } catch se {
            do ..Manager.LOGGER.error(se.AsSQLMessage())
            do $$$AssertTrue(0, "Attempting to instantiate samples.intersystems.gateway.Student - failed")
        }

		// get, set Date
		set nextClassExpected = $ZDATE($HOROLOG,3)
		do $$$AssertTrue(0=student.setNextClass(nextClassExpected,$ZTIME($HOROLOG),"White Hall",3.0,0),"setNextClass() returned 0")
		set nextClassActual = student.myGetNextClassDate()
		do $$$AssertEquals(nextClassExpected,nextClassActual,"Next class on: " _ nextClassActual _ ", expected: " _ nextClassExpected)

		// set a String
		do student.mySetName("John","Smith")
		// set an int
		do student.mySetID(27)

		do $$$AssertEquals("Smith,John",student.myGetName(),"Test set string, student.myGetName(), expected 'Smith,John'")
		do $$$AssertEquals("27",student.myGetID(),"Test set string, student.myGetID(), expected '27'")
		do $$$AssertEquals("976-01-6712",student.getSSN(),"Test set string, student.getSSN(), expected '976-01-6712'")

		set staticMethodActual = ..gateway.invoke("samples.intersystems.gateway.Person","myStaticMethod")
		do $$$AssertEquals("Success", staticMethodActual, "Static set/get, expected 'Success', actual = '" _ staticMethodActual _ "'")

		do ..gateway.setProperty("samples.intersystems.gateway.Person", "staticProperty", 89)
		set staticPropertyActual = ..gateway.getProperty("samples.intersystems.gateway.Person", "staticProperty")
		do $$$AssertEquals("89", staticPropertyActual, "Static set/get, expected '89', actual = '" _ staticPropertyActual _ "'")

		// HashMap example

		set grades = ..gateway.new("java.util.HashMap")

		set x = grades.put("Biology", "3.8")
		set changedActual = grades.put("Biology", "3.1")
		do $$$AssertEquals(3.8, changedActual, "Biology grade changed from, expected = '3.8', actual = '" _ changedActual _ "'")
		set changedToActual = grades.get("Biology")
		do $$$AssertEquals(3.1, changedToActual, "Biology grade changed to, expected = '3.1', actual = '" _ changedToActual _ "'")
		set x = grades.put("French","3.75")
		set x = grades.put("Spanish","2.75")
		do student.mySetGrades(grades)

		set grades = student.myGetGrades()
		if $ISOBJECT(grades) {
			try {
			    set gradesSizeActual = grades.size()
			    do $$$LogMessage("Student Grades: actual size() = "_gradesSizeActual)
				do $$$LogMessage("Student has completed the following " _ grades.size() _ " classes:")
				set it = grades.keySet().iterator()
				while (it.hasNext()) {
					set key = it.next()
					set value = grades.get(key)
					do $$$LogMessage("  " _ key _ " " _ value)
				}
			} catch ce {
				do $$$AssertTrue(0, "Student completed the following: Exception caught during iteration: " _ ce.AsSQLMessage())
			}
		} else {
			do $$$AssertTrue(0, "myGetGrades(): returned a null oref due to a bug in intersystems-jdbc versions prior to 3.8.3")
		}

		set highestGradeActual = student.myGetHighestGrade()
		do $$$AssertEquals("3.75", highestGradeActual,"Highest grade, expected = '3.75', actual = '" _ highestGradeActual _  "'")

		do $$$LogMessage("Now taking: Calculus, Chemistry, English Comp")
		do student.setGrade("Calculus",3.5)
		do student.setGrade("Chemistry",3.92)
		do student.setGrade("English Comp",2.5)
		set englishCompActual = student.getGrade("English Comp")
		do $$$AssertEquals("2.5", englishCompActual, "English Comp Grade, expected '2.5', actual = '" _ englishCompActual _ "'")

		set grades = student.myGetGrades()
		if $ISOBJECT(grades) {
			try {
				do $$$LogMessage("Student has completed the following " _ grades.size() _ " classes:")
				set it = grades.keySet().iterator()
				while (it.hasNext()) {
					set key = it.next()
					set value = grades.get(key)
					do $$$LogMessage("  " _ key _ " " _ value)
				}
				do $$$AssertTrue(1, "Student - iterated over " _ grades.size() _ " completed classes")
			} catch cge {
				do $$$AssertTrue(0, "Student has completed the following: EXCEPTION caught - " _ cge.AsSQLMessage())
			}
		} else {
			do $$$AssertTrue(0, "Student has completed the following: student.myGetGrades() returned a null oref due to a bug in intersystems-jdbc versions prior to 3.8.3")
		}
		set highestGradeExpected = 3.92
		set highestGradeActual = $NUMBER($DECIMAL(student.myGetHighestGrade()),2)
		do $$$AssertEquals(highestGradeExpected, highestGradeActual, "Highest grade now: expected = '" _ highestGradeExpected _ "', actual = '" _ highestGradeActual _ "'")
	} catch exception {

	}
}

Method TestClassForName()
{
	// example of using Class.forName
    set student = ..createStudent(29, "976-01-6712")
    try {
        set arrayListClass = ..gateway.invoke("java.lang.Class", "forName","java.util.ArrayList")
        set sports = arrayListClass.getDeclaredConstructor().newInstance().%CastAs("java.util.ArrayList")
        do sports.add("Basketball")
        do sports.add("Tennis")
        do sports.add("Running")
        do sports.add("Swimming")
        do student.mySetFavoriteSports(sports)

        // set/get a list of Strings
        set list = student.myGetFavoriteSports()
        do $$$LogMessage(" Student's favorite sports are: ")
        set sportsSizeExpected = list.size()
        for i = 0:1:sportsSizeExpected-1 {
            do $$$LogMessage("  "_list.get(i))
        }
        set sportsSizeActual = i + 1
        do $$$AssertEquals(sportsSizeExpected, sportsSizeActual, "Student favorite sports expected = '" _ sportsSizeExpected _ "', actual = '" _ sportsSizeActual _ "'")
    } catch fne {
        do $$$AssertTrue(0, "Students favorite sports, expected = 4, actual = <EXCEPTION> caught: " _ fne.AsSQLMessage())
    }
}

Method TestSetObject()
{
	// set an object
    set student = ..createStudent(29, "976-01-6712")
	try {
		set home = ..gateway.new("samples.intersystems.gateway.Address")
		set street = ..gateway.new("samples.intersystems.gateway.Street")

		set street.name = "Memorial Drive"
		set street.number = "One"
		do home.mySetCity("San Diego")
		do home.mySetStreet(street)
		do home.mySetState("CA")
		do home.mySetZip("20098")
		do student.sethome(home)

		// get an object
		do $$$LogMessage("Student's address: ")
		set home2 = student.gethome()
		do $$$LogMessage("  " _ student.gethome().street.name)
		do $$$LogMessage("  " _ home2.myGetCity() _ ", " _ home2.myGetState() _ " " _ home2.myGetZip())

		do $$$LogMessage("Change address")

		set newHome = ..gateway.new("samples.intersystems.gateway.Address")
		set newStreet = ..gateway.new("samples.intersystems.gateway.Street")
		set newStreet.number = "456"
		set newStreet.name = "Del Monte"
		do newHome.mySetCity("Boston")
		do newHome.mySetState("MA")
		do newHome.mySetStreet(newStreet)
		do newHome.mySetZip("40480")
		do student.changeAddress(home,newHome)
		// get an array of Strings
        set list = student.getAddressAsCollection()
        do $$$LogMessage("Student's new address is: ")
        do $$$LogMessage("  " _ list.%get(3))
        do $$$LogMessage("  " _ list.%get(0) _ ", " _ list.%get(1) _ " " _ list.%get(2))
	} catch exception {
	    do $$$AssertTrue(0, "TestSetObject: exception caught, '" _ exception.AsSQLMessage() _ "'")
	}
}

/*
/// This shows how to use arrays. The test uses sample classes delivered with InterSystems IRIS (under /dev/java/samples).
/// To run the example, start the Java Gateway Super Server, then from your
/// production-enabled namespace type in Do ##class(%Net.Remote.Java.Test).TestArrays(port,host)
ClassMethod TestArrays(port As %Integer, host As %String = "127.0.0.1") [ Final ]
{
	Try {
        Set gateway = ..Connect(port,host)
        Quit:gateway=""

        Set test=##class(samples.intersystems.gateway.Person).%New(gateway)

        // test simple string arrays
        Set stringArray=##class(%ListOfDataTypes).%New()
        Do stringArray.Insert("test string one")
        Do stringArray.Insert("test string two")
        Do stringArray.Insert("test string three")
        Do stringArray.Insert("test string four")

        // test simple string arrays
        Do test.setStringArray(stringArray)
        Set outStringArray = test.getStringArray()

        For i=1:1:outStringArray.Count() {
            Write "String " _ i _ " : " _ outStringArray.GetAt(i),!
        }

        // test array of objects
        Set home = ##class(samples.intersystems.gateway.Address).%New(gateway)
        Set street = ##class(samples.intersystems.gateway.Street).%New(gateway)
        Do street.setname("Memorial Drive")
        Do street.setnumber("One")
        Do home.mySetCity("Cambridge")
        Do home.mySetStreet(street)
        Do home.mySetState("MA")
        Do home.mySetZip("02142")

        Set home2 = ##class(samples.intersystems.gateway.Address).%New(gateway)
        Set street2 = ##class(samples.intersystems.gateway.Street).%New(gateway)
        Do street2.setname("Santa Cruz Ave")
        Do street2.setnumber("4555")
        Do home2.mySetCity("San Diego")
        Do home2.mySetStreet(street2)
        Do home2.mySetState("CA")
        Do home2.mySetZip("92109")

        Set addressArray = ##class(%ListOfObjects).%New()
        Do addressArray.Insert(home)
        Do addressArray.Insert(home2)

        Do test.setAddressArray(addressArray)
        Set addressArray = test.getAddressArray()
        For i=1:1:addressArray.Count() {
            Set home = addressArray.GetAt(i)
            Write !,"Address "_i_":",!
            Write home.getstreet().getnumber() _ " " _ home.getstreet().getname(),!
            Write home.getcity()
            Write ", " _ home.getstate()
            Write " " _ home.getzip(),!
        }

        // byte[] is mapped as %GlobalBinaryStream
        Write !,"Byte array test:",!
        Set byteStream = ##class(%GlobalBinaryStream).%New()
        Do byteStream.Write("Global binary stream")
        // Note that byteStream is passed in by value, so any changes on the Java
        // side will be ignored. The next example will pass the stream by reference
        // meaning changes on the Java side will be reflected here as well
        Do test.setByteArray(byteStream)

        Set result = test.getByteArray()
        Write result.Read(result.SizeGet()),!

        Set readStream = ##class(%GlobalBinaryStream).%New()
        // we need to 'reserve' a number of bytes since we are passing the stream
        // by reference (Java's equivalent is byte[] ba = new byte[max];)
        For i=1:1:50 Do readStream.Write("0")

        Set bytesRead = test.read(.readStream,50)
        Write readStream.Read(bytesRead),!

        Set status = gateway.%Disconnect()
        Do ..ProcessError(status)
	} Catch exception {
		Set status=##class(%Net.Remote.Gateway).%SetStatus(exception)
		Do ..ProcessError(status)
	}
}

/// This example establishes a connection with the InterSystems JDBC driver, then executes
/// some standard JDBC code. This code should work against any database that
/// has a JDBC driver. Simply change the connection parameters (driver class name,
/// url, username and password)
/// To run the example, start the Java Gateway Super Server, then from your
/// production-enabled namespace type in Do ##class(%Net.Remote.Java.Test).JDBC(port,host,jdbcPort,jdbcHost)
ClassMethod JDBC(port As %Integer, host As %String = "127.0.0.1", jdbcPort As %Integer = 1972, jdbcHost As %String = "127.0.0.1") [ Final ]
{
	Try {
        Set gateway=..Connect(port,host)
        Quit:gateway=""

        Set status = gateway.%ClassForName($$$jdbcDriverClass)
        If status'=$$$OK {
            Do ..ProcessError(status)
            Quit
        }
        // connect to IRIS JDBC (in order to connect to a different database, modify
        // the connection parameters: driver name, url, username and password)
        Set url = $$$jdbcConnectionStrPrefix_"//"_jdbcHost_":"_jdbcPort_"/SAMPLES",username="_SYSTEM",password="SYS"
        // calls java Class.forName method
        Set connection = ##class(java.sql.DriverManager).getConnection(gateway,url,username,password)

        // get a list of tables
        Set databaseMetaData = connection.getMetaData()
        Set tables = databaseMetaData.getTables("","Sample","%","")
        Write "Tables in SAMPLES Namespace [Schema=Sample]:",!
        While (tables.next()) {
            Write "  ",tables.getString(3)_" ",!
        }

        // execute a query against Sample.Person table
        Set statement = connection.createStatement()
        Set resultSet = statement.executeQuery("select * from Sample.Person where ID < 10")
        Set resultSetMetaData = resultSet.getMetaData()
        Write !,"Execute query: select * from Sample.Person where ID < 10",!
        Write "----------------------------------------------",!
        Write resultSetMetaData.getColumnName(1)_"  "_resultSetMetaData.getColumnName(3)_"          "
        Write resultSetMetaData.getColumnName(6)_"           "_resultSetMetaData.getColumnName(5)_"  ",!
        Write "----------------------------------------------",!
        While (resultSet.next()) {
            Write resultSet.getString(1)_"   "
            Write resultSet.getString(3)_"   "
            Write resultSet.getString(6)_"   "
            Write resultSet.getString(5)_"   ",!
        }
        Write "----------------------------------------------",!

    	Set status = gateway.%Disconnect()
	    Do ..ProcessError(status)
	} Catch exception {
		Set status = ##class(%Net.Remote.Gateway).%SetStatus(exception)
		Do ..ProcessError(status)
	}
}


ClassMethod Connect(port As %Integer, host As %String) As %Net.Remote.Gateway
{
	// connect to current namespace, use 2 second timeout
	Set status = $$$OK,namespace=$namespace,timeout=2
	Set classPath = ##class(%ListOfDataTypes).%New()
	Set samplePath = $SYSTEM.Util.InstallDirectory()_"dev/java/samples/"
	// or: Set samplePath=$SYSTEM.Util.InstallDirectory()_"dev/java/samples/javagatewaysamples.jar"
	Do classPath.Insert(samplePath)

	// get a connection handle and connect
	Set gateway = ##class(%Net.Remote.Gateway).%New()
	Set status = gateway.%Connect(host,port,namespace,timeout,classPath)
	If status'=$$$OK {
		Do ..ProcessError(status)
		Quit ""
	}
	Quit gateway
}

ClassMethod TestEager(port As %Integer, eager As %Boolean = 1, runs As %Integer = 1000, host As %String = "127.0.0.1") [ Final ]
{
	Try {
		Set gateway = ..Connect(port,host)
		Quit:gateway=""

		Set student = ##class(samples.intersystems.gateway.Student).%New(gateway,29,"976-01-6712")
		Set timeElapsed = $P($now(),",",2)
		Set grades = ##class(java.util.HashMap).%New(gateway)
		Set x=grades.put("Biology",3.8)
		Set x=grades.put("French",3.75)
		Set x=grades.put("Spanish",2.75)
		Set colors = ##class(%Library.ListOfDataTypes).%New()
		Do colors.Insert("Red")
		Do colors.Insert("Blue")
		Do colors.Insert("White")
		Set byteStream = ##class(%GlobalBinaryStream).%New()
		Do byteStream.Write("Global binary stream")
		Do:eager=1 student.%SetEager(1)
		For i=1:1:runs {
			Do student.setyearsInProgram(8)
			Do student.setGPA(3.45)
			Do student.sethighestGrade(4.0)
			Do student.setnextClassCredits(3.0)
			Do student.setisGraduate(1)
			Do student.setnextClassOnSchedule(1)
			Do student.setnextClassLocation("McCall Hall")
			Do student.setclassCount(7)
			Do student.setcredits(12)
			Do student.setstudentID(5024)
			Do student.setnextClassTime("12:00:00")
			Do student.setgrades(grades)
			Do student.setfavoriteColors(colors)
			Do student.setByteArray(byteStream)
			Do:eager=1 student.%SendObject()

			Do:eager=1 student.%FetchObject()
			Set years = student.getyearsInProgram()
			Set gpa = student.getGPA()
			Set hg = student.gethighestGrade()
			Set nc = student.getnextClassCredits()
			Set ig = student.getisGraduate()
			Set credits = student.getcredits()
			Set id = student.getstudentID()
			Set cc = student.getclassCount()
			Set time = student.getnextClassTime()
			Set location = student.getnextClassLocation()
			Set onSchedule = student.getnextClassOnSchedule()
			Set grades = student.getgrades()
			Set favoriteColors = student.getfavoriteColors()
			Set byteArray = student.getByteArray()
		}
		Write "Time Elapsed: "_($P($now(),",",2)-timeElapsed),!
		Write "Years: "_years,!,"GPA: "_gpa,!,"Highest grade: "_hg,!,"Credits: "_credits,!,"ID: "_id,!
		Write "Biology grade: "_student.getgrades().get("Biology"),!
		Write "Favorite Colors: ",!
		For i=1:1:favoriteColors.Count() {
			Write " ",favoriteColors.GetAt(i),!
		}
		Write "ByteArray: ",byteArray.Read(byteArray.SizeGet()),!

		Set status=gateway.%Disconnect()
	} Catch exception {
		Set status=##class(%Net.Remote.Gateway).%SetStatus(exception)
		Do ..ProcessError(status)
	}
}
*/
Method createStudent(id As %Integer, ssn As %String) As %RegisteredObject
{
    return ..gateway.new("samples.intersystems.gateway.Student", id, ssn)
}

ClassMethod ProcessError(status As %Status) [ Final ]
{
	use 0
	if status=$$$OK {
		write !,"Test Successfully Completed"
	} else {
		write $SYSTEM.OBJ.DisplayError(status)
	}
}

}
