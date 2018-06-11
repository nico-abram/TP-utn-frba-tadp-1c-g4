package com.tadp.utn.frba.c1_2018.grupo04
import org.junit.Before
import org.junit.Test
import org.junit.Assert._

@Test
class Apuesta_Test {

  private var apuesta1: ApuestaSimple = _
  private var apuesta2: ApuestaSimple = _
  private var apuestaCompuesta1: ApuestaCompuesta = _
  @Before
  def setup() = {
    apuesta1 = ApuestaSimple(Cara(), 10.0)
    apuesta2 = ApuestaSimple(Numero(0), 15.0)
    apuestaCompuesta1 = ApuestaCompuesta(Seq(apuesta1, apuesta2))
  }

  @Test
  def ApuestaSimple1_test() = {
    assertEquals(
      NodoArbol(
        100.0,
        NodoArbol(50.0, HojaArbol(0.0)),
        NodoArbol(50.0, HojaArbol(20.0))): ArbolRaro[Double, Double],
      apuesta1(10.0))
  }
  @Test
  def ApuestaSimple2_test() = {
    val NodoArbol(_,
      NodoArbol(p1, HojaArbol(m1)),
      NodoArbol(p2, HojaArbol(m2))): ArbolRaro[Double, Double] = apuesta2(15.0)
    assertEquals(m1, 0.0, 0.05)
    assertEquals(m2, 540.0, 0.05)
    assertEquals(p1, 100.0 - Numero(0).probabilidad, 0.05)
    assertEquals(p2, Numero(0).probabilidad, 0.05)
  }
  @Test
  def ApuestaCompuesta2_test() = {
    val NodoArbol(_,
      NodoArbol(p1, HojaArbol(m1)),
      NodoArbol(p4,
        NodoArbol(_,
          NodoArbol(p2, HojaArbol(m2)),
          NodoArbol(p3, HojaArbol(m3))
          ))): ArbolRaro[Double, Double] = apuestaCompuesta1(15.0)
    assertEquals(m1, 5.0, 0.05)
    assertEquals(m2, 10.0, 0.05)
    assertEquals(m3, 550.0, 0.05)
    assertEquals(p1, Cara().probabilidad, 0.05)
    assertEquals(p2, 100.0 - Numero(0).probabilidad, 0.05)
    assertEquals(p3, Numero(0).probabilidad, 0.05)
    assertEquals(p4, Cruz().probabilidad, 0.05)
  }
  @Test
  def AplanarResultado_test() = {
    val x = apuestaCompuesta1.aplanada(15.0)
    assertEquals(3, x.length)
    val Some(res1) = x.find(_._1 == 550)
    val Some(res2) = x.find(_._1 == 5)
    val Some(res3) = x.find(_._1 == 10)
    assertEquals(res2._2, Cara().probabilidad, 0.05)
    assertEquals(
      Cara().probabilidad * Numero(0).probabilidad / 100.0,
      res1._2, 0.05)
    assertEquals(
      Cara().probabilidad * (100.0 - Numero(0).probabilidad) / 100.0,
      res3._2, 0.05)
  }

}