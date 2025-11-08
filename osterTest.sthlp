osterTest
-----------

Syntax:
    osterTest varname , r(#) out("filename")   //out() optional

Description:
    osterTest is used after you run a regression.
    It reads the coefficient and standard error of the variable you name,
    computes the 95% confidence interval, and checks whether your given
    value r() is inside that interval. It can also export the result with
    outreg2 and keep only this variable.
    This is useful for Oster-style robustness or for checking whether
    the first-stage beta meets your requirement.

Options:
    r(#)           value of beta to test; default 0
    out("file")    export table via outreg2

Example:
    reghdfe y x x1 x2, absorb(id year) vce(cluster id)
    osterTest x, a(0.9)
    osterTest x, a(0.9) out("oster.doc")

Stored results:
    r(b)     coefficient
    r(se)    standard error
    r(lb)    lower bound of 95% CI
    r(ub)    upper bound of 95% CI
    r(r)     value you tested
    r(inCI)  1 if r() is inside 95% CI, 0 otherwise
