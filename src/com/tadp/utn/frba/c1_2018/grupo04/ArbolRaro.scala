package com.tadp.utn.frba.c1_2018.grupo04

trait ArbolRaro[T1, T2] {
  def map[T3](f: T1 => T3): ArbolRaro[T3, T2]
  def bind[T3](f: T1 => ArbolRaro[T3, T2]): ArbolRaro[T3, T2]
  def fold(seed: T2)(f: (T1, T2, T2) => (T1, T2)): Seq[(T1, T2)]
}
case class NodoArbol[T1, T2](val valor2: T2, val subarboles: (ArbolRaro[T1, T2])*) extends ArbolRaro[T1, T2] {
  def map[T3](f: T1 => T3) = bind((x) => HojaArbol(f(x)))
  def bind[T3](f: T1 => ArbolRaro[T3, T2]) = NodoArbol(valor2, subarboles.map(_.bind(f)): _*)
  def fold(seed: T2)(f: (T1, T2, T2) => (T1, T2)) =
    subarboles.map((r) => r.fold(seed)(f)).fold(List())(_ ++ _).
      map((p) => f(p._1, p._2, valor2))
}
case class HojaArbol[T1, T2](val valor1: T1) extends ArbolRaro[T1, T2] {
  def flatMap(f: T1 => T1) = HojaArbol(f(valor1))
  def map[T3](f: T1 => T3) = HojaArbol(f(valor1))
  def bind[T3](f: T1 => ArbolRaro[T3, T2]) = f(valor1)
  def fold(seed: T2)(f: (T1, T2, T2) => (T1, T2)) = Seq((valor1, seed))
}