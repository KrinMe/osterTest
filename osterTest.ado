*! version 1.3.0  08 Nov 2025
program define osterTest, rclass
    version 13.0
    syntax varlist(min=1 max=1) [, R(real 0) OUT(string)]

    local xvar : word 1 of `varlist'

    capture confirm scalar e(df_r)
    if _rc {
        di as err "No regression results found. Run a regression first."
        exit 198
    }

    capture scalar b_x = _b[`xvar']
    if _rc {
        di as err "Variable `xvar' not found in last regression."
        exit 198
    }
	capture scalar delta = r(delta)

    quietly {
        scalar se_x = _se[`xvar']
        scalar tcrit  = invttail(e(df_r), 0.025)
        scalar lb_x = b_x - tcrit*se_x
        scalar ub_x = b_x + tcrit*se_x
        scalar r_in_ci = (`r' >= lb_x & `r' <= ub_x)
    }

    di as txt "Variable: " as res "`xvar'"
    di as txt "Coef     = " as res %9.4f b_x
    di as txt "SE       = " as res %9.4f se_x
    di as txt "95% CI   = [" %9.4f lb_x " , " %9.4f ub_x "]"
    di as txt "r        = " as res %9.4f `r'
    di as txt "r in CI? = " as res r_in_ci
    di as txt "delta    = " as res delta

    return scalar b    = b_x
    return scalar se   = se_x
    return scalar lb   = lb_x
    return scalar ub   = ub_x
    return scalar r    = `r'
    return scalar inCI = r_in_ci
	return scalar delta= delta

    if `"`out'"' != "" {
        outreg2 using `"`out'"', replace keep(`xvar') ///
            addstat("coef", b_x, "95% LB", lb_x, "95% UB", ub_x, ///
                    "r", `r', "r in 95% CI", r_in_ci, "delta", delta)

    }

end

