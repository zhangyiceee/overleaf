# 双重差分法学习









## 平行趋势检验

```stata
use "$data/autor-jole-2003.dta",clear

* Log total employment - from BLS employment & earnings
gen lnemp=ln(annemp)

* Non-business-service sector employment from CBP
gen nonemp= stateemp-svcemp
gen lnnon=ln(nonemp)
gen svcfrac= svcemp/nonemp

* Total business services employment from CBP
gen bizemp= svcemp+peremp
gen lnbiz = ln(biz)

* State dummies, year dummies, and state*time trends
gen t=year-78
gen t2=t^2
drop if state==98 
xi i.state i.year i.state*t i.state*t2 i.region*i.year
drop _Iyear_77 - _Iyear_79

gen year1 = year>=79 & year<=95
keep if year1
gen year2 = ((int(year/2)*2 + 1)==year)
gen year4 = (year==79 | year==83 | year==87 | year==91 | year==95)


* Generate more aggregate demos
gen clp=clg+gtc
gen a1624=m1619+m2024+f1619+f2024
gen a2554=m2554+f2554
gen a55up=m5564+m65up+f5564+f65up
gen fem=f1619+f2024+f2554+f5564+f65up
gen white=rs_wm+rs_wf
gen black=rs_bm+rs_bf
gen other=rs_om+rs_of
gen married=marfem+marmale


* Modify union variable so that:
*  1 - We don't use interpolated data for 1979 & 1981
*  2 - Turn from fraction into percent so that coefficient will be friendly size
replace unmem=. if year==79 | year==81
replace unmem=unmem*100

reg lnths lnemp admico_2 admico_1 admico0 admico1 admico2 admico3 mico4 admppa_2 admppa_1 admppa0 admppa1 admppa2 admppa3 mppa4 admgfa_2 admgfa_1 admgfa0 admgfa1 admgfa2 admgfa3 mgfa4 _Iy* _Istate* _IstaXt* if year1 , cluster(state)

coefplot, keep(admico_2 admico_1 admico0 admico1 admico2 admico3 mico4)                     ///
    coeflabels(admico_2 = "2 yr prior" admico_1 = "1 yr prior" admico0  = "Yr of adopt" ///     
	admico1  = "1 yr after" admico2  = "2 yr after" admico3  = "3 yr after"  ///
    mico4    = "4+ yr after")                                              ///
    vertical                                                                          ///
    yline(0) ytitle("Log points")                                                     ///
    xtitle("Time passage relative to year of adoption of implied contract exception") ///
    addplot(line @b @at)                                                              ///
    ciopts(recast(rcap))    rescale(100)   scheme(s1mono)                                       
graph export "$output/did_common_trend.png" ,replace


```

