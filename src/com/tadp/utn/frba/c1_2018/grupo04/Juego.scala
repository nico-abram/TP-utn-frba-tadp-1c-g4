package com.tadp.utn.frba.c1_2018.grupo04
import Suceso._
import scala.collection.GenSeq

trait Jugada {
  def ganancia(monto: Double): Double
  def sucesoGanador(suceso: Suceso): Boolean
  val resultadosPosibles: GenSeq[Suceso]
  def probabilidadDe(s: Suceso): Double
  lazy val probabilidad = probabilidadDe(this)
}

trait JugadaDeJuego extends Jugada {
  def juego: Juego
  def ganancia(monto: Double): Double
  def sucesoGanador(suceso: Suceso) = juego.sucesoGanador(suceso, this)
  lazy val resultadosPosibles = juego.resultadosPosibles
  def probabilidadDe(s: Suceso) = juego.probabilidad(s)
}

trait Juego {
  val distribucion: Distribucion
  lazy val resultadosPosibles = distribucion.sucesosPosibles
  def probabilidad(s: Suceso) = distribucion.probabilidad(s)
  def sucesoGanador(suceso: Suceso, resultado: Jugada) = suceso == resultado
}