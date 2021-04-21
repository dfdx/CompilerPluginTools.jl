using Test
using Yuan
using MLStyle

f = @λ begin
    Expr(:(=), SlotNumber(x), _) => x
    ReturnNode(SSAValue(x)) => x
    NewSSAValue(x) => x
    Argument(x) => x
    Const(x) => x
    QuoteNode(x) => x
    _ => false
end

ex = ReturnNode(SSAValue(1))
@test f(ex) == 1

ex = NewSSAValue(2)
@test f(ex) == 2

ex = Expr(:(=), SlotNumber(3), :(Base.Math.abs($(SlotNumber(2)))))
@test f(ex) == 3
@test f(Argument(4)) == 4
@test f(Const(1.1)) == 1.1
@test f(QuoteNode(2)) == 2

dummy(x) = 2x
ir, _ = code_ircode(dummy, Tuple{Float64})[1]
ir[SSAValue(2)]
ic = IncrementalCompact(ir)
(_, idx), stmt = first(ic)
@test idx == 1
@test stmt.args[1] == GlobalRef(Base, :sitofp)
@test stmt.args[2] == Float64
@test stmt.args[3] == 2

@test ic[1].args[1] == GlobalRef(Base, :abs_float)
