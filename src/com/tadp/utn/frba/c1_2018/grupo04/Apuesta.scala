package com.tadp.utn.frba.c1_2018.grupo04
import Suceso._

trait Apuesta {
  type Resultado = ArbolRaro[Double, Double]
  def apply(montoInicial: Double): Resultado
  def distribucion(montoInicial: Double) = Ponderada(aplanada(montoInicial))
  def aplanada(montoInicial: Double) = apply(montoInicial).fold(1)((monto, p1, p2) => (monto, p1 * p2 / 100)).map((x) => (x._1, x._2 * 100))
}
case class ApuestaSimple(jugada: Jugada, monto: Double) extends Apuesta {
  def apply(montoInicial: Double): Resultado = {
    val (wins: Seq[Suceso], losses: Seq[Suceso]) =
      jugada.resultadosPosibles.partition((suceso: Suceso) => jugada.sucesoGanador(suceso))
    NodoArbol[Double, Double](
      100.0,
      NodoArbol(
        losses.map(jugada.probabilidadDe(_)).sum,
        HojaArbol(-monto)),
      NodoArbol(
        wins.map(jugada.probabilidadDe(_)).sum,
        HojaArbol(jugada.ganancia(monto) - monto))).map(montoInicial + _)
  }
}
case class ApuestaCompuesta(apuestas: Seq[ApuestaSimple]) extends Apuesta {
  def apply(montoInicial: Double): Resultado =
    apuestas.tail.foldLeft(apuestas.head(montoInicial)) { (r: Resultado, ap: ApuestaSimple) =>
      r.bind((m: Double) => if (ap.monto <= m) ap.apply(m) else HojaArbol[Double, Double](m))
    }
}