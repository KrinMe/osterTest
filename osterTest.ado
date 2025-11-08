*! version 1.4.0  08 Nov 2025
program define osterTest, rclass
    version 13.0
    // 用法: osterTest varname , beta(#) out("path")
    syntax varlist(min=1 max=1) [, BETA(real 0) OUT(string)]

    // 取变量名
    local xvar : word 1 of `varlist'

    // 要有回归结果
    capture confirm scalar e(df_r)
    if _rc {
        di as err "No regression results found. Run a regression first."
        exit 198
    }

    // 要有这个变量的系数
    capture scalar b_x = _b[`xvar']
    if _rc {
        di as err "Variable `xvar' not found in last regression."
        exit 198
    }

    // 尝试接上一条命令的 r(delta)（比如 psacalc2 留下的）
    capture scalar delta = r(delta)

    quietly {
        scalar se_x    = _se[`xvar']
        scalar tcrit   = invttail(e(df_r), 0.025)
        scalar lb_x    = b_x - tcrit*se_x
        scalar ub_x    = b_x + tcrit*se_x
        scalar beta_in_ci = (`beta' >= lb_x & `beta' <= ub_x)
    }

    // 打印
    di as txt "Variable: " as res "`xvar'"
    di as txt "Coef     = " as res %9.4f b_x
    di as txt "SE       = " as res %9.4f se_x
    di as txt "95% CI   = [" %9.4f lb_x " , " %9.4f ub_x "]"
    di as txt "beta     = " as res %9.4f `beta'
    di as txt "beta in CI? = " as res beta_in_ci
    di as txt "delta    = " as res delta

    // 返回
    return scalar b        = b_x
    return scalar se       = se_x
    return scalar lb       = lb_x
    return scalar ub       = ub_x
    return scalar beta     = `beta'
    return scalar inCI     = beta_in_ci
    return scalar delta    = delta

    // 导出
    if `"`out'"' != "" {
        outreg2 using `"`out'"', replace keep(`xvar') ///
            addstat("coef",  b_x, ///
                    "95% LB", lb_x, ///
                    "95% UB", ub_x, ///
                    "beta",   `beta', ///
                    "beta in 95% CI", beta_in_ci, ///
                    "delta",  delta)
    }

end
