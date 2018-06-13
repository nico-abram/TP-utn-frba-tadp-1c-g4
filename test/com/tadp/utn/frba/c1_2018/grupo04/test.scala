package com.tadp.utn.frba.c1_2018.grupo04

import com.tadp.utn.frba.c1_2018.grupo04._
import org.junit._
import Assert._

@Test
class Apuesta_Test {

  var apuesta1: ApuestaSimple = _
  var apuesta2: ApuestaSimple = _
  var apuestaCompuesta1: ApuestaCompuesta = _
  @Before
  def setup() = {
    apuesta1 = ApuestaSimple(Cara(), 10.0)
    apuesta2 = ApuestaSimple(Numero(0), 15.0)
    apuestaCompuesta1 = ApuestaCompuesta(Seq(apuesta1, apuesta2))
  }

  @Test
  def TestApuestaSimple1() = {
    val res = apuesta1.aplanada(10.0)
    assertEquals(2, res.length)
    val Some(res1) = res.find(_._1 == 0.0)
    val Some(res2) = res.find(_._1 == 20.0)
    assertEquals(Cara().probabilidad, res2._2, 0.05)
    assertEquals(100.0 - Cara().probabilidad, res1._2, 0.05)
    res
  }
  @Test
  def TestApuestaSimple2() = {
    val res = apuesta2.aplanada(15.0)
    assertEquals(2, res.length)
    val Some(res1) = res.find(_._1 == 0.0)
    val Some(res2) = res.find(_._1 == 540.0)
    assertEquals(100.0 - Numero(0).probabilidad, res1._2, 0.05)
    assertEquals(Numero(0).probabilidad, res2._2, 0.05)
    res
  }
  @Test
  def TestApuestaCompuesta1() = {
    val res = apuestaCompuesta1.aplanada(15.0)
    assertEquals(3, res.length)
    val Some(res1) = res.find(_._1 == 550)
    val Some(res2) = res.find(_._1 == 5)
    val Some(res3) = res.find(_._1 == 10)
    assertEquals(Cara().probabilidad, res2._2, 0.05)
    assertEquals(
      Cara().probabilidad * Numero(0).probabilidad / 100.0,
      res1._2, 0.05)
    assertEquals(
      Cara().probabilidad * (100.0 - Numero(0).probabilidad) / 100.0,
      res3._2, 0.05)
    res
  }
  @Test
  def TestApuestaMultipleResultado() = {
    val res = ApuestaSimple(Cara2(), 10.0).aplanada(10)
    assertEquals(3, res.length)
    val Some(res1) = res.find(_._1 == 20)
    val Some(res2) = res.find(_._1 == 10)
    val Some(res3) = res.find(_._1 == 0)
    assertEquals(Cruz2().probabilidad,res1._2, 0.05)
    assertEquals(Parada().probabilidad,res2._2, 0.05)
    assertEquals(Cara2().probabilidad, res3._2, 0.05)
	  res
  }
  @Test
  def TestFalla() = {
    assertEquals(3, 2)
  }

}