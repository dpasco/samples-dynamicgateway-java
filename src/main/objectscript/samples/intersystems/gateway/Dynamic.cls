/// <h3>
/// External Java Server Samples (Dynamic Gateway)
/// </h3>
/// <p>
/// It is important to know the difference between what was called "the Java Gateway" and what
/// we now refer to as "External Language Servers". The Java Gateway required ObjectScript classes
/// to be generated and used to interact with a Java counterpart. The Dynamic Gateway, as we often
/// refer to External Language Server, is a different thing. With Dynamic Gateway, there is no
/// need to generated any ObjectScript Classes, simply interact with Java (and other supported
/// external languages - DotNet, Python etc.).
/// </p>
/// <p>
/// This class demonstrates how to use Dynamic Java Gateway, also known as the External Java Server,
/// to accomplish common tasks as previously demonstrated by %Net.Remote.Java.Test using the legacy
/// Java Gateway.
/// </p>
Class samples.intersystems.gateway.Dynamic [ Abstract ]
{

/// This shows how to use the Dynamic Java Gateway with ObjectScript. There is no setup necessary, other than to
/// make certain that the default External Java Server is properly configured and runs (use the SMP to check)
ClassMethod Test(jarPath As %RawString) [ Final ]
{
	try {
#if 0 // The old way of doing this:
        set gateway=..Connect(port,host)
        quit:gateway=""
		set student=##class(samples.intersystems.gateway.Student).%New(gateway,29,"976-01-6712")
#else // The new way
	    set gateway = $SYSTEM.external.getJavaGateway()
	    do gateway.addToPath(jarPath)
    	set student = gateway.new("samples.intersystems.gateway.Student", 29, "976-01-6712")
#endif

	// get, set Date
	write !,"setNextClass returned: ",student.setNextClass($ZDATE($HOROLOG,3),$ZTIME($HOROLOG),"White Hall",3.0,0)
	write !,"Next class on: ",student.myGetNextClassDate(),!,!

	// set a String
	do student.mySetName("John","Smith")
	// set an int
	do student.mySetID(27)

	write "Name: ",student.myGetName(),!
	write "ID: ",student.myGetID(),!
	write "SSN: ",student.getSSN(),!,!

#if 0 // The old way of doing this:
	write "Static method execute: ",##class(samples.intersystems.gateway.Person).myStaticMethod(gateway),!,!
	do ##class(samples.intersystems.gateway.Person).setstaticProperty(gateway,89)
	write "Static set/get: "_##class(samples.intersystems.gateway.Person).getstaticProperty(gateway),!!
#else // The new way
	write "Static method execute: ", gateway.invoke("samples.intersystems.gateway.Person","myStaticMethod"),!,!
	do gateway.setProperty("samples.intersystems.gateway.Person", "staticProperty", 89)
	write "Static set/get: " _ gateway.getProperty("samples.intersystems.gateway.Person", "staticProperty"),!!
#endif

	// HashMap example

#if 0 // The old way of doing this:
    set grades=##class(java.util.HashMap).%New(gateway)
#else // The new way
	set grades = gateway.new("java.util.HashMap")
#endif
	set x = grades.put("Biology","3.8")
	write "Biology grade changed from " _ grades.put("Biology","3.1")_" to 3.1",!
	set x = grades.put("French","3.75")
	set x = grades.put("Spanish","2.75")
	do student.mySetGrades(grades)

	set grades = student.myGetGrades()
    if $ISOBJECT(grades) {
        write "Student has completed the following ",grades.size()," classes:",!
        set it = grades.keySet().iterator()
        while (it.hasNext()) {
            set key = it.next()
            set value = grades.get(key)
            write "  ",key," ",value,!
        }
    } else {
        write !, "myGetGrades() bug in intersystems-jdbc caused myGetGrades() to return a null oref, project requires intersystems-jdbc version > 3.8.2"
    }
	write !,"Highest grade: ", student.myGetHighestGrade()

	write !,"Now taking: Calculus, Chemistry, English Comp",!,!
	do student.setGrade("Calculus",3.5)
	do student.setGrade("Chemistry",3.92)
	do student.setGrade("English Comp",2.5)
	write "English Comp Grade: ",student.getGrade("English Comp"),!

	set grades = student.myGetGrades()
    if $ISOBJECT(grades) {
        write !,"Student has completed the following ",grades.size()," classes:",!
        set it = grades.keySet().iterator()
        while (it.hasNext()) {
            set key = it.next()
            set value = grades.get(key)
            write "  ",key," ",value,!
        }
    } else {
        write !, "myGetGrades() bug in intersystems-jdbc caused myGetGrades() to return a null oref, project requires intersystems-jdbc version > 3.8.2"
    }
	write !,"Highest grade now: "
	write $NUMBER($DECIMAL(student.myGetHighestGrade()),2)

	// example of using Class.forName

#if 0 // The old way of doing this:
	// instead of sports=##class(java.util.ArrayList).%New(gateway)
	set arrayListClass = ##class(java.lang.Class).forName(gateway,"java.util.ArrayList")
	set sports = arrayListClass.newInstance()
#else // The new way
    set arrayListClass = gateway.invoke("java.lang.Class", "forName","java.util.ArrayList")
    set sports = arrayListClass.getDeclaredConstructor().newInstance().%CastAs("java.util.ArrayList")
#endif
    do sports.add("Basketball")
    do sports.add("Tennis")
    do sports.add("Running")
    do sports.add("Swimming")
    do student.mySetFavoriteSports(sports)

 	// set/get a list of Strings
	set list = student.myGetFavoriteSports()
	write !,"Student's favorite sports are: ",!
	for i = 0:1:list.size()-1 {
		write "  "_list.get(i),!
	}
	// set an object

#if 0 // The old way of doing this:
	set home = ##class(samples.intersystems.gateway.Address).%New(gateway)
	set street = ##class(samples.intersystems.gateway.Street).%New(gateway)
#else // The new way
	set home = gateway.new("samples.intersystems.gateway.Address")
	set street = gateway.new("samples.intersystems.gateway.Street")
#endif
    set street.name = "Memorial Drive"
    set street.number = "One"
    do home.mySetCity("San Diego")
    do home.mySetStreet(street)
    do home.mySetState("CA")
    do home.mySetZip("20098")
    do student.sethome(home)

	// get an object
	write !,"Student's address: ",!
	set home2 = student.gethome()
	write "  " _ student.gethome().street.name,!
	write "  "_home2.myGetCity() _ ", " _ home2.myGetState() _ " " _ home2.myGetZip(),!,!

	write "Change address",!

#if 0 // The old way of doing this:
	set newHome = ##class(samples.intersystems.gateway.Address).%New(gateway)
	set newStreet = ##class(samples.intersystems.gateway.Street).%New(gateway)
	do newStreet.setnumber("456")
	do newStreet.setname("Del Monte")
#else // The new way
	set newHome = gateway.new("samples.intersystems.gateway.Address")
	set newStreet = gateway.new("samples.intersystems.gateway.Street")
	set newStreet.number = "456"
	set newStreet.name = "Del Monte"
#endif
	do newHome.mySetCity("Boston")
	do newHome.mySetState("MA")
	do newHome.mySetStreet(newStreet)
	do newHome.mySetZip("40480")
	do student.changeAddress(home,newHome)
	// get an array of Strings

#if 0 // The old way of doing this:
#else // The new way
#endif

        set list = student.getAddressAsCollection()
        write "Student's new address is: ",!
#if 0 // The old way of doing this:
	    write "  "_list.GetAt(4),!,"  "_list.GetAt(1)_", "_list.GetAt(2)_" "_list.GetAt(3),!
	    // Disconnect
	    set status = gateway.%Disconnect()
#else // The new way
	    write "  "_list.%get(3),!,"  "_list.%get(0)_", "_list.%get(1)_" "_list.%get(2),!
#endif
		do ..ProcessError($$$OK)
	} catch exception {
		set status = ##class(%Net.Remote.Gateway).%SetStatus(exception)
		do ..ProcessError(status)
	}
}

/// This shows how to use arrays. The test uses sample classes delivered with InterSystems IRIS (under /dev/java/samples).
/// To run the example, start the Java Gateway Super Server, then from your
/// production-enabled namespace type in Do ##class(%Net.Remote.Java.Test).TestArrays(port,host)
/// ClassMethod TestArrays(port As %Integer, host As %String = "127.0.0.1") [ Final ]
ClassMethod TestArrays(jarPath As %RawString)
{
	try {
#if 0 // The old way of doing this:
        set gateway = ..Connect(port,host)
        quit:gateway=""
        set test=##class(samples.intersystems.gateway.Person).%New(gateway)
#else // The new way
		set gateway = $SYSTEM.external.getJavaGateway()
		quit:'$ISOBJECT(gateway)
	    do gateway.addToPath(jarPath)
		set test = gateway.new("samples.intersystems.gateway.Person")
#endif

        // test simple string arrays
        set stringArray=##class(%ListOfDataTypes).%New()
        do stringArray.Insert("test string one")
        do stringArray.Insert("test string two")
        do stringArray.Insert("test string three")
        do stringArray.Insert("test string four")

        // test simple string arrays
#if 0 // The old way of doing this:
        do test.setStringArray(stringArray)
        set outStringArray = test.getStringArray()
#else // The new way
		do test.setStringArray(gateway.new("String[*]", stringArray))
        set outStringArray = test.getStringArray().%getall()
#endif

        for i=1:1:outStringArray.Count() {
            write "String " _ i _ " : " _ outStringArray.GetAt(i),!
        }

        // test array of objects
#if 0 // The old way of doing this:
        set home = ##class(samples.intersystems.gateway.Address).%New(gateway)
        set street = ##class(samples.intersystems.gateway.Street).%New(gateway)
        do street.setname("Memorial Drive")
        do street.setnumber("One")
#else // The new way
        set home = gateway.new("samples.intersystems.gateway.Address")
        set street = gateway.new("samples.intersystems.gateway.Street")
        set street.name = "Memorial Drive"
        set street.number = "One"
#endif
        do home.mySetCity("Cambridge")
        do home.mySetStreet(street)
        do home.mySetState("MA")
        do home.mySetZip("02142")

#if 0 // The old way of doing this:
        set home2 = ##class(samples.intersystems.gateway.Address).%New(gateway)
        set street2 = ##class(samples.intersystems.gateway.Street).%New(gateway)
        do street2.setname("Santa Cruz Ave")
        do street2.setnumber("4555")
#else // The new way
        set home2 = gateway.new("samples.intersystems.gateway.Address")
        set street2 = gateway.new("samples.intersystems.gateway.Street")
			// Java properties that are public without getter/setter can be accessed directly
        set street2.name = "Santa Cruz Ave"
        set street2.number = "4555"
#endif
        do home2.mySetCity("San Diego")
        do home2.mySetStreet(street2)
        do home2.mySetState("CA")
        do home2.mySetZip("92109")

        set addressArray = ##class(%ListOfObjects).%New()
        do addressArray.Insert(home)
        do addressArray.Insert(home2)

#if 0 // The old way of doing this:
        do test.setAddressArray(addressArray)
        set addressArray = test.getAddressArray()
		for i=1:1:addressArray.Count() {
            set home = addressArray.GetAt(i)
            write !,"Address "_i_":",!
            write home.getstreet().getnumber() _ " " _ home.getstreet().getname(),!
            write home.getcity()
            write ", " _ home.getstate()
            write " " _ home.getzip(),!
		}
#else // The new way
        do test.setAddressArray(gateway.new("samples.intersystems.gateway.Address[*]", addressArray))
        set addressArray = test.getAddressArray().%getall()
        for i=1:1:addressArray.Count() {
            set home = addressArray.GetAt(i)
            write !,"Address "_i_":",!
            write home.street.number _ " " _ home.street.name,!
            write home.city
            write ", " _ home.state
            write " " _ home.zip,!
        }
#endif
        // byte[] is mapped as %GlobalBinaryStream (%GlobalBinaryStream is deprecated, use %Stream.GlobalBinary instead)
        write !,"Byte array test:",!
        set byteStream = ##class(%Stream.GlobalBinary).%New()
        do byteStream.Write("Global binary stream")
        // Note that byteStream is passed in by value, so any changes on the Java
        // side will be ignored. The next example will pass the stream by reference
        // meaning changes on the Java side will be reflected here as well
#if 0 // The old way of doing this:
        do test.setByteArray(byteStream)
        set result = test.getByteArray()
#else // The new way
        set test.ByteArray = gateway.new("byte[?]", byteStream)
        set result = test.ByteArray.%getall()
#endif
        write result.Read(result.SizeGet()),!

        set readStream = ##class(%Stream.GlobalBinary).%New()
        // we need to 'reserve' a number of bytes since we are passing the stream
        // by reference (Java's equivalent is byte[] ba = new byte[max];)
        for i=1:1:50 do readStream.Write("0")
#if 0 // The old way of doing this:
        set bytesRead = test.read(.readStream,50)
#else // The new way
		set byteArray = gateway.new("byte[*]", readStream)
        set bytesRead = test.read(byteArray,50)
		set readStream = byteArray.%getall()
#endif
        write readStream.Read(bytesRead),!
        // Set status = gateway.%Disconnect()
        do ..ProcessError($$$OK)
	} catch exception {
		set status=##class(%Net.Remote.Gateway).%SetStatus(exception)
		do ..ProcessError(status)
	}
}

/// This example establishes a connection with the InterSystems JDBC driver, then executes
/// some standard JDBC code. This code should work against any database that
/// has a JDBC driver. Simply change the connection parameters (driver class name,
/// url, username and password)
/// To run the example, start the Java Gateway Super Server, then from your
/// production-enabled namespace type in Do ##class(%Net.Remote.Java.Test).JDBC(port,host,jdbcPort,jdbcHost)
/// </p>
/// <p>
/// JDBC is better served by %XDBC.Gateway - this example is not refactored, refer to <class>%XDBC.Gateway.Connection</class>.
ClassMethod JDBC(port As %Integer, host As %String = "127.0.0.1", jdbcPort As %Integer = 1972, jdbcHost As %String = "127.0.0.1") [ Final ]
{
	/*
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
	*/
}

/// Connect is replaced by $system.external functions, do $system.external.Help() for more information.
ClassMethod Connect(port As %Integer, host As %String) As %Net.Remote.Gateway
{
	/*
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
	*/
}

/// eager is not relevant to Dynamic Gateway
ClassMethod TestEager(port As %Integer, eager As %Boolean = 1, runs As %Integer = 1000, host As %String = "127.0.0.1") [ Final ]
{
	/*
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
	*/
}

/// Sure, you can do this. Or you can just use exceptions. Exceptions using try/catch blocks are
/// essentially zero cost unless an exception is thrown and caught. Then there is overhead to process
/// the exception. But using try/catch vs. returning a %Status value allows for cleaner and more robust
/// coding patterns are methods become usable as functions without the requirement of returning an error status
/// that not only prevents returning a useful value from a function but also requires the caller to check
/// the error status each and every time. Exceptions are - well - exceptional!
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
