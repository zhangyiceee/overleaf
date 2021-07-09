global output "/Users/zhangyi/Documents/GitHub/overleaf/output"




bcuse kielmc.dta  //bcuse专门调取伍德里奇教材中的数据
keep if y81==1 //保留1981年样本
reg rprice y81nrinc


keep if y81!=1 //调用数据省略，保留1978年样本
reg rprice nearinc





bcuse kielmc.dta,clear
reg rprice y81 nearinc y81nrinc
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,无)  dec(2) replace 
reg rprice y81 nearinc y81nrinc age agesq
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,age age2) dec(2) append 
reg rprice y81 nearinc y81nrinc age agesq intst baths land area rooms
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,all) dec(2) append 
reg lrprice y81 nearinc y81nrinc 
outreg2 using "$output/did_1" ,tex keep(y81 nearinc y81nrinc ) addtext(其他控制变量,无) dec(2) append 

