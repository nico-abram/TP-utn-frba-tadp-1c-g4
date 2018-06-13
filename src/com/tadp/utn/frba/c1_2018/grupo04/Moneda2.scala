package com.tadp.utn.frba.c1_2018.grupo04
import Suceso._

case class Cara2() extends JugadaMoneda2
case class Cruz2() extends JugadaMoneda2
case class Parada() extends JugadaMoneda2

object Moneda2 extends Juego {
  val distribucion = Ponderada(Seq((Cara2(), 45), (Cruz2(), 45), (Parada(), 10)))
}

sealed trait JugadaMoneda2 extends JugadaDeJuego { 
  def ganancia(x: Double): Double = x * 2.0
  def juego = Moneda2
  override def montoDeApuesta(s: Suceso, montoInicial: Double) = s match {
    case Cara2() => if(s==this) montoInicial else -montoInicial
    case Cruz2() => if(s==this) montoInicial else -montoInicial
    case Parada() => if(s==this) 5*montoInicial else 0
  }
}
