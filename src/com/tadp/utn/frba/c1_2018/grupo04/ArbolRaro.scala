package com.tadp.utn.frba.c1_2018.grupo04

object ArbolRaro {
  def apply[T1, T2](t: T1): ArbolRaro[T1, T2] = HojaArbol(t)
}
sealed trait ArbolRaro[T1, T2] {
  def map[T3](f: T1 => T3): ArbolRaro[T3, T2] = flatMap((x) => ArbolRaro(f(x)))
  def flatMap[T3](f: T1 => ArbolRaro[T3, T2]): ArbolRaro[T3, T2]
  def fold(seed: T2)(f: (T1, T2, T2) => (T1, T2)): Seq[(T1, T2)]
}
case class NodoArbol[T1, T2](val valor2: T2, val subarboles: (ArbolRaro[T1, T2])*) extends ArbolRaro[T1, T2] {
  def flatMap[T3](f: T1 => ArbolRaro[T3, T2]) = NodoArbol(valor2, subarboles.map(_.flatMap(f)): _*)
  def fold(seed: T2)(f: (T1, T2, T2) => (T1, T2)) =
    subarboles.map((r) => r.fold(seed)(f)).fold(List())(_ ++ _).
      map((p) => f(p._1, p._2, valor2))
}
case class HojaArbol[T1, T2](val valor1: T1) extends ArbolRaro[T1, T2] {
  def flatMap[T3](f: T1 => ArbolRaro[T3, T2]) = f(valor1)
  def fold(seed: T2)(f: (T1, T2, T2) => (T1, T2)) = Seq((valor1, seed))
}