package com.tadp.utn.frba.c1_2018.grupo04

object Suceso {
  type Suceso = Any
}
import Suceso._
import scala.collection.GenSeq

trait Distribucion {
  val sucesosPosibles: GenSeq[Suceso]
  def probabilidad(x: Suceso): Double
}

case class EventoSeguro(val suceso: Suceso) extends Distribucion {
  val sucesosPosibles: GenSeq[Suceso] = Seq(suceso)
  def probabilidad(x: Suceso): Double = if (x == suceso) 100.0 else 0.0
}
case class Equiprobable(val sucesosPosibles: GenSeq[Suceso]) extends Distribucion {
  def probabilidad(x: Suceso): Double =
    if (sucesosPosibles.exists(_ == x)) 100.0 / sucesosPosibles.length else 0.0
}
case class Ponderada(val sucesos: GenSeq[(Suceso, Double)]) extends Distribucion {
  val sucesosPosibles: GenSeq[Suceso] = sucesos.map(_._1)
  def probabilidad(x: Suceso): Double = sucesos.find(_._1 == x) match {
    case Some(s) => s._2 / sucesos.map(_._2).sum
    case None    => 0.0
  }
}