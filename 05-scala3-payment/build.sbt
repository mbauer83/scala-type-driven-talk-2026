val scala3Version = "3.8.3"

lazy val root = project
  .in(file("."))
  .settings(
    name         := "scala3-payment",
    version      := "0.1.0",
    scalaVersion := scala3Version,

    scalacOptions ++= Seq("-deprecation", "-feature"),

    libraryDependencies += "io.github.iltotore" %% "iron" % "2.6.0",

    Compile / mainClass := Some("demos.PaymentDemo"),
  )
