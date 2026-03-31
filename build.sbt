val scala3Version = "3.8.3"

lazy val root = project
  .in(file("."))
  .settings(
    name         := "scala-type-driven-talk",
    version      := "0.1.0",
    scalaVersion := scala3Version,

    libraryDependencies ++= Seq(
      "org.typelevel" %% "cats-core" % "2.13.0",
      "org.scalameta" %% "munit"     % "1.0.3" % Test,
    ),

    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-Xcheck-macros",
    ),

    // run demos easily
    Compile / mainClass := Some("demos.BookingDemo"),
  )
