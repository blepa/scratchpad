name := "fp_lab"

version := "0.1"

scalaVersion := "2.12.6"

libraryDependencies ++= Seq(
  "com.typesafe.slick" %% "slick" % "3.2.3" from "http://repo1.maven.org/maven2/com/typesafe/slick/slick_2.12/3.2.3/slick_2.12-3.2.3.jar",
  "org.slf4j" % "slf4j-nop" % "1.7.9" from "http://repo1.maven.org/maven2/org/slf4j/slf4j-nop/1.7.9/slf4j-nop-1.7.9.jar",
  "com.microsoft.sqlserver" % "mssql-jdbc" % "7.0.0.jre8" from "http://repo1.maven.org/maven2/com/microsoft/sqlserver/mssql-jdbc/7.0.0.jre8/mssql-jdbc-7.0.0.jre8.jar"
)
