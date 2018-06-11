package com.tadp.utn.frba.c1_2018.grupo04

object Suceso {
  type Suceso = Any
}
import Suceso._

trait Distribucion {
  val sucesosPosibles: Seq[Suceso]
  def probabilidad(x: Suceso): Double
}

case class EventoSeguro(val suceso: Suceso) extends Distribucion {
  val sucesosPosibles: Seq[Suceso] = Seq(suceso)
  def probabilidad(x: Suceso): Double = if (x == suceso) 100.0 else 0.0
}
case class Equiprobable(val sucesosPosibles: Seq[Suceso]) extends Distribucion {
  def probabilidad(x: Suceso): Double =
    if (sucesosPosibles.contains(x)) 100.0 / sucesosPosibles.length else 0.0
}
case class Ponderada(val sucesos: Seq[(Suceso, Double)]) extends Distribucion {
  val sucesosPosibles: Seq[Suceso] = sucesos.map(_._1)
  def probabilidad(x: Suceso): Double = sucesos.find(_._1 == x) match {
    case Some(s) => s._2 / sucesos.map(_._2).sum
    case None    => 0.0
  }
}