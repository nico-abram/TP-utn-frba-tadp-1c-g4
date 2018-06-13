package com.tadp.utn.frba.c1_2018.grupo04
import Suceso._
import scala.collection.GenSeq

trait Jugada {
  val resultadosPosibles: Seq[Suceso]
  def probabilidadDe(s: Suceso): Double
  lazy val probabilidad = probabilidadDe(this)
  def montoDeApuesta(s: Suceso, montoInicial: Double): Double
}

trait JugadaDeJuego extends Jugada {
  def juego: Juego
  def ganancia(monto: Double): Double
  def sucesoGanador(suceso: Suceso) = juego.sucesoGanador(suceso, this)
  lazy val resultadosPosibles = juego.resultadosPosibles
  def probabilidadDe(s: Suceso) = juego.probabilidad(s)
  def montoDeApuesta(s: Suceso, montoInicial: Double) =
    if (sucesoGanador(s))
      ganancia(montoInicial) - montoInicial
    else
      -montoInicial
}

trait Juego {
  val distribucion: Distribucion
  lazy val resultadosPosibles = distribucion.sucesosPosibles
  def probabilidad = distribucion.probabilidad(_)
  def sucesoGanador(suceso: Suceso, resultado: Jugada) = suceso == resultado
}