#iam 11/1/2017: deprecated use/edit/update the yices2 formula instead
class Yices < Formula
  desc "The Yices SMT Solver"
  homepage "http://yices.csl.sri.com/"
  url "https://github.com/SRI-CSL/yices2/archive/Yices-2.5.4.tar.gz"
  sha256 "f7403328d7d0b3973ffac61fe674d5b8030dd4806c75f3de2cfb8fd81aad1ccd"

  depends_on "autoconf" => :build
  depends_on "gperf" => :build
  depends_on "gmp"
  depends_on "libpoly"


  def install
    system "autoconf"
    system "./configure", "--enable-mcsat",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"lra.smt2").write <<-EOS.undent
      ;; QF_LRA = Quantifier-Free Linear Real Arithemtic
      (set-logic QF_LRA)
      ;; Declare variables x, y
      (declare-fun x () Real)
      (declare-fun y () Real)
      ;; Find solution to (x + y > 0), ((x < 0) || (y < 0))
      (assert (> (+ x y) 0))
      (assert (or (< x 0) (< y 0)))
      ;; Run a satisfiability check
      (check-sat)
      ;; Print the model
      (get-model)
    EOS

    assert_match "sat\n(= x 2)\n(= y (- 1))\n", shell_output("#{bin}/yices-smt2 lra.smt2")
  end
end
