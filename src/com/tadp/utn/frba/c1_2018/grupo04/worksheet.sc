package com.tadp.utn.frba.c1_2018.grupo04
import scala.collection.mutable._

object tests {
	val x = new Apuesta_Test()
  if(
	  try {
	  	x.TestFalla()
	  	true
	  }
	  catch {
	  	case _:Throwable=> false
	  })
  	throw new Exception("Los assert fallidos no tiran excepcion")
  x.setup()
  x.TestApuestaSimple1()
  x.TestApuestaSimple2()
  x.TestApuestaCompuesta1()
  x.TestApuestaMultipleResultado()
}