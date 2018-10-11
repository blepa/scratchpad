package io.blepa.collection

abstract sealed class nSet[+A] {
    def isEmpty: Boolean

    def set: nSet[A]

    def prepend[B >: A](x: B): nSet[B] = nSet.make(x, this)

    override def toString: String = "TODO" 
}

case object nNil extends nSet[Nothing] {
  def set: nSet[Nothing] = throw new NoSuchElementException("A empty nSet")

  def isEmpty: Boolean = true
}

case class nSetCons[A](set: nSet[A]) extends nSet[A] {
    def isEmpty: Boolean = false
}

object nSet {
    def empty[A]: nSet[A] = nNil

    def make[A](x:A, xs: nSet[A] = nNil): nSet[A] = nSetCons(xs)

    def apply[A](xs: A*): nSet[A] = {
        var r: nSet[A] = nSet.empty 
        for( x <- xs) {
            r = r.prepend(x)            
        }
        r
    }
}
