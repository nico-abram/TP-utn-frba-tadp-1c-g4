package com.tadp.utn.frba.c1_2018.grupo04
import Suceso._
import scala.collection.GenSeq
import scala.collection.mutable

trait Apuesta {
  type Resultado = ArbolRaro[Double, Double]
  def apply(montoInicial: Double): Resultado
  def distribucion(montoInicial: Double) = Ponderada(aplanada(montoInicial))
  def aplanada(montoInicial: Double) = apply(montoInicial).fold(1)((monto, p1, p2) => (monto, p1 * p2 / 100)).map((x) => (x._1, x._2 * 100))
}
case class ApuestaSimple(jugada: Jugada, monto: Double) extends Apuesta {
  def apply(montoInicial: Double): Resultado = {
    var map = scala.collection.mutable.Map[Double, Double]()
    jugada.resultadosPosibles.foreach((suceso: Suceso) => {
      val k = jugada.montoDeApuesta(suceso, monto)
      map += k -> (jugada.probabilidadDe(suceso) + map.get(k).getOrElse(0.0))
    })
    val nodos = map.map((p) => NodoArbol(p._2, HojaArbol[Double, Double](p._1)))
    NodoArbol[Double, Double](
      100.0, nodos.toSeq: _*).map(montoInicial + _)
  }
}
case class ApuestaCompuesta(apuestas: GenSeq[ApuestaSimple]) extends Apuesta {
  def apply(montoInicial: Double): Resultado =
    apuestas.tail.foldLeft(apuestas.head(montoInicial)) { (r: Resultado, ap: ApuestaSimple) =>
      r.flatMap((m: Double) => if (ap.monto <= m) ap.apply(m) else HojaArbol[Double, Double](m))
    }
}