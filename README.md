# InterSystems Samples - Dynamic Gateway

## Refactored %Net.Remote.Java.Test

Previously, Java samples were distributed with InterSystems IRIS Kits under ./dev/java/samples. All samples were removed
from kits and many of the previous samples were not refactored to make them consistent with new features in InterSystems
IRIS.

This project includes samples from %Net.Remote.Java.Test. The original source used the old Java Gateway which has been
replaced by External Java Server and Dynamic Gateway. The focus of this project is not running this project (it 
should run) but rather to demonstrate how code that used the old Java Gateway can be refactored to use the new 
External Java Server with Dynamic Gateway connections.

## Running the Sample Code

*NOTE: There are bugs in the Java Server that were discovered during the testing of this project. Those bugs will be 
correct in a later version of intersystems-jdbc. At this time, the latest version of intersystems-jdbc is 3.8.1. These bugs impact the use of parameterized types.*

There are actually two implementations of the refactored %Net.Remote.Java.Test class, one is a direct refactor and 
the other is a UnitTest class. There is a jar included and it can be used directly to run the sample code.

```shell
USER>d $system.OBJ.LoadDir("<path to project>/samples-dynamicgateway-java-main/src/main/objectscript/","ckr",,1)
```

```text
Load of directory started on 11/30/2023 09:33:59
Loading file <path to project>/samples-dynamicgateway-java-main/src/main/objectscript/samples/intersystems/gateway
/Dynamic.cls as cls
Imported class: samples.intersystems.gateway.Dynamic
Compiling class samples.intersystems.gateway.Dynamic
Compiling routine samples.intersystems.gateway.Dynamic.1
Load finished successfully.
```

Then class, *samples.intersystems.gateway.Dynamic*, implements two methods that demonstrate various capabilities:
* Test
* TestArrays

Both take a single argument that is the path to the jar file. If you choose to compile the java sources and use 
compiled classes instead of the jar then simply pass the directory containing the compiled java classes instead of a 
full path to a jar file.

```shell
USER>do ##class(samples.intersystems.gateway.Dynamic).Test("/home/danp/community/projects/samples-dynamicgateway-java/target/samples-dynamicgateway-java-1.0.0.jar")

setNextClass returned: 0
Next class on: 2023-12-05

Name: Smith,John
ID: 27
SSN: 976-01-6712

Static method execute: Success

Static set/get: 89

Biology grade changed from 3.8 to 3.1
Student has completed the following 3 classes:
  French 3.75
  Biology 3.1
  Spanish 2.75

Highest grade: 3.75
Now taking: Calculus, Chemistry, English Comp

English Comp Grade: 2.5

Student has completed the following 6 classes:
  Chemistry 3.92
  French 3.75
  Biology 3.1
  Spanish 2.75
  Calculus 3.5
  English Comp 2.5

Highest grade now: 3.92
Student's favorite sports are: 
  Basketball
  Tennis
  Running
  Swimming

Student's address: 
  Memorial Drive
  San Diego, CA 20098

Change address
Student's new address is: 
  456 Del Monte
  Boston, MA 40480

Test Successfully Completed
```

```
USER>do ##class(samples.intersystems.gateway.Dynamic).TestArrays("/home/danp/community/projects/samples-dynamicgateway-java/target/samples-dynamicgateway-java-1.0.0.jar")
String 1 : test string one
String 2 : test string two
String 3 : test string three
String 4 : test string four

Address 1:
One Memorial Drive
Cambridge, MA 02142

Address 2:
4555 Santa Cruz Ave
San Diego, CA 92109

Byte array test:
Global binary stream
This byte stream has been filled in by Java

Test Successfully Completed
```