package com.tadp.utn.frba.c1_2018.grupo04

abstract class Jugador(val montoInicial: Double) {
  val planDeJuego: ((Double, Double)) => Double
  def elegirJuego(juegos: Seq[ApuestaCompuesta]): ApuestaCompuesta =
    juegos.maxBy(_.aplanada(montoInicial).map((p) => this.planDeJuego.apply(p)).sum)
}

case class Racional(override val montoInicial: Double) extends Jugador(montoInicial) {
  val planDeJuego = (p: (Double, Double)) => p._1 * p._2
}
case class Arriesgado(override val montoInicial: Double) extends Jugador(montoInicial) {
  val planDeJuego = (p: (Double, Double)) => p._1
}
case class Cauto(override val montoInicial: Double) extends Jugador(montoInicial) {
  val planDeJuego = (p: (Double, Double)) =>
    if (p._1 >= 0) p._2 else 0.0
}
case class Customizable(override val montoInicial: Double, override val planDeJuego: ((Double, Double)) => Double) extends Jugador(montoInicial) {}