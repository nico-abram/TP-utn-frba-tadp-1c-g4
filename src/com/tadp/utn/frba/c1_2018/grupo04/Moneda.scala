package com.tadp.utn.frba.c1_2018.grupo04
import Suceso._

case class Cara() extends JugadaMoneda
case class Cruz() extends JugadaMoneda

object Moneda extends Juego {
  val d: Distribucion = Equiprobable(Seq(Cara(), Cruz()))
  val distribucion = d
}

trait JugadaMoneda extends JugadaDeJuego {
  def ganancia(x: Double): Double = x * 2.0
  val juego = Moneda
}
