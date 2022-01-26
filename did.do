global output "/Users/zhangyi/Documents/GitHub/overleaf/output"
global data "/Users/zhangyi/Documents/GitHub/overleaf/data"



bcuse kielmc.dta,clear  //bcuse专门调取伍德里奇教材中的数据
keep if y81==1 //保留1981年样本
reg rprice y81nrinc


*1978年结果
bcuse kielmc.dta,clear
keep if y81!=1 //调用数据省略，保留1978年样本
reg rprice nearinc


*did结果输出
bcuse kielmc.dta,clear
reg rprice y81 nearinc y81nrinc
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,无)  dec(2) replace 
reg rprice y81 nearinc y81nrinc age agesq
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,age age2) dec(2) append 
reg rprice y81 nearinc y81nrinc age agesq intst baths land area rooms
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,all) dec(2) append 
reg lrprice y81 nearinc y81nrinc 
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,无) dec(2) append 


*调用card数据
use "$data/cardkrueger1994.dta",clear
gen t_treat=t*treated
reg fte t treated t_treat
outreg2 using "$output/did_card" ,tex keep(t treated t_treat) addtext(control,No) dec(2) replace 

reg fte t treated t_treat bk kfc  roys 
outreg2 using "$output/did_card" ,tex keep(t treated t_treat) addtext(control,Yes) dec(2) append 

 
*平行趋势假定的作图
*https://economics.mit.edu/faculty/dautor/data/autor03
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


*Soap Opera 平行趋势


use "$data/soap/Indiv.dta", clear

*Drop AMCs above 95th pctile of area size (i.e., 5994 km2)
keep if geoarea<5994

keep id yr1stcov amc_code weight year B married yrsedu_head wealth_noTV catholic rural Doctors ipc_renta age agesq stock stocksq

* Create dummies around coverage year
gen byte t = year==yr1stcov
foreach n in 1 2 3 4 5 6 7 8 9 {
	gen byte t_m`n'= year==yr1stcov-`n'
	gen byte t_p`n'= year==yr1stcov+`n'
	}
	compress

xi: areg B t_m9 t_m8 t_m7 t_m6 t_m5 t_m4 t_m3 t_m2 t_m1 t t_p1 t_p2 t_p3 t_p4 t_p5 t_p6 t_p7 t_p8 t_p9 married yrsedu_head wealth_noTV catholic rural Doctors ipc_renta age agesq stock stocksq i.year [w=weight], absorb(amc_code) cluster(amc_code)
coefplot,keep(t_m9 t_m8 t_m7 t_m6 t_m5 t_m4 t_m3 t_m2 t_m1 t t_p1 t_p2 t_p3 t_p4 t_p5 t_p6 t_p7 t_p8 t_p9) ///
	coeflabels(t_m9="m9" t_m8="m8" t_m7="m7" t_m6="m6" t_m5="m5" t_m4="m4" t_m3="m3" t_m2="m2" t_m1="m1" t="0" ///
	 t_p1="p1" t_p2="p2" t_p3="p3" t_p4="p4" t_p5="p5" t_p6="p6" t_p7="p7" t_p8="p8" t_p9  ="p9")  ///
	vertical                                                                          ///
    yline(0) ytitle("Fertility")                                                     ///
    xtitle("Year since coverage") ///
    addplot(line @b @at)                                                              ///
    ciopts(recast(rcap))    rescale(100)   scheme(s1mono)                                 

graph export "$output/common_trend_soap.png" ,replace



* figure 4 is then created in Excel from the above estimates



















