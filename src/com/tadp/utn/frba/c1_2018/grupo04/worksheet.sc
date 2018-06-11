package com.tadp.utn.frba.c1_2018.grupo04
import scala.collection.mutable._

object tests {
	def time[R](f: => R): (Double,R) = {
	    val t0 = System.nanoTime()
	    val r = f
	    val t1 = System.nanoTime()
	    (t1-t0, r)
	}
	def timeR[R](f: => R): R = {
	    val rt = time(f)
	    println("Elapsed:" + rt._1 + "ns")
	    rt._2
	}
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
  x.apuesta2(15.0)
  x.TestApuestaSimple1()
  x.TestApuestaSimple2()
  x.TestApuestaCompuesta1()
  timeR {x.TestAplanarResultado()}
  // Usando ParSeq
  x.par()
  timeR {x.TestAplanarResultado()}
  x.setup()
  val l1 = (1 to 1000).map(((a)=>(time{x.TestAplanarResultado()}._1)))
  x.par()
  val l2 = (1 to 1000).map(((a)=>(time{x.TestAplanarResultado()}._1)))
  println("Tiempo promedio sin paralelizar: "+l1.sum/l1.size+"ns")
  println("Tiempo promedio paralelizando: "+l2.sum/l2.size+"ns")
  println((1-(l2.sum/l2.size)/(l1.sum/l1.size))*100+"% mas rapido")
}