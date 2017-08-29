!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!!!  1. 设计目的：计算环境容量系数A和混合层厚度mixH !!!!!
!!!!  2. coding:utf-8                             !!!!!!!!
!!!!  3. write by ZhouJunqian, on 18th May,2017   !!!!!!!!
!!!!  4. any question if you have, please contact !!!!!!!!
!!!!! by email(zhoujunqian15@outlook.com).        !!!!!!!!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
module Public_parameter
    implicit none

    !!! set struct variables for station infomation file
    type Station_Info
        integer std_id     !!! 站点ID号
        character(len=30) province  !!! 站点所处的省份或行政区域
        character(len=45) std_name  !!! 站点名称
        real represent_area      !!! 站点观测代表的面积，单位: km2
        real lat      !!! 站点的纬度, 单位,degree
        real lon      !!! 站点的经度, 单位,degree
    end type Station_Info

    !!! set struct variables for station weather elements file
    type Station_elements
        integer std_id
        integer date       !!! 数据观测日期, eg,20170101
        real Cloud_Total   !!! 总云量
        real Cloud_Low     !!! 低云量
        real rain          !!! 累计降雨量, 单位:mm
        real wind_10min    !!! 地面风速10min平均, 单位: m/s
    end type Station_elements

    !!! set struct variables for output calculate result
    type OutDataFmt
        integer date       !!! 数据的日期, eg, 20170101
        real(8) Avalue     !!! 环境容量系数A，单位: 10000km2/数小时([天,月,年])
    end type OutDataFmt

end module Public_parameter


program main
    use Public_parameter
    implicit none

    !!! set variables for namelist file !!!!
    character(len=100) IndataPath,OutdataPath
    character(len=50) StdInfoFile,File_Suffix
    integer TimeStep,StationNum
    real MissingValue
    namelist /io/ IndataPath,OutdataPath,StdInfoFile,File_Suffix,TimeStep,StationNum,MissingValue

    type(Station_Info),allocatable,dimension(:)::std_info        !!! StdInfoFile data
    type(Station_elements),allocatable,dimension(:)::std_eles    !!! station elements data
    type(OutDataFmt),allocatable,dimension(:)::cal_Result        !!! output result data

    integer lyear,lmonth,lday    !!! input,  年、月、日
    real lhour,lminute,lseconds  !!! input,  时、分、秒（当地北京时间）
    integer Clower,Ctotal        !!! input,  低云量，总云量, integer有效值:0~10
    real lfai,llamda             !!! input,  当地纬度、经度, 单位：degree
    character(len=50) Meoto_region  !!! input, 区域名称，具体用法参考Get_regionId子程序
    real U10_10min               !!! input,  地面风速10分钟平均值, 单位: m/s, 保留一位小数
    real U10                     !!! input,  地面风速平均值, 单位: m/s
    real S                       !!! input,  区域面积, 单位: km2
    real vd                      !!! input,  干沉降速度, 单位: m/s
    real Rain                    !!! input,  累计降水量(数小时/天/月/年), 单位: mm
    real U_Horizontal            !!! [input],  平流速度, 单位: m/s
    real U_pseudo_diffusion      !!! [input],  伪扩散速度, 单位: m/s

    real SunDelta,Sunh0          !!! output, 太阳赤纬，太阳高度角，单位：degree
    integer lRadLev              !!! output, 太阳辐射等级值, 有效值 -2~3
    character(len=8) PT          !!! output, PT大气稳定度, 有效值 A~F
    real mixH                    !!! output, 混合层厚度, 单位:m
    real(8) Av                   !!! output, 大气容量系数, 单位: 10000km2/数小时([天,月,年])
    ! real(8),allocatable:: A(:,:)

    integer:: tempInt,i,j
    character(len=10) tempStr
    character(len=50) Outfl
    integer*4 day_in_year
    integer*4 dayId_of_year      !!! 一年中的日期序数，有效值0~365
    real bjtT

    !!! 打开namelist文件, 获取必要的参数
    open(10,file="namelist_Aindex.config")
    read(10,nml=io)
    close(10)
    !!! 打开站点信息文件, 获取必要的站点信息
    allocate(std_info(StationNum))
    open(11,file=trim(trim(adjustl(IndataPath))//adjustl(StdInfoFile)),status="old")
    read(11,*)
    do i= 1, StationNum
        read(11,*)std_info(i)
    end do
    !write(*,*)std_info
    close(11)

    lhour=10;lminute=0;lseconds=0     !!! 此处使用的虚假的上午10时，因为数据是逐日的平均。
    ! allocate(A(TimeStep,StationNum))
    do i = 1, StationNum
        allocate(std_eles(TimeStep))
        allocate(cal_Result(TimeStep))
        S = std_info(i)%represent_area
        lfai = std_info(i)%lat
        llamda = std_info(i)%lon
        Meoto_region = std_info(i)%province
        call Inputs(std_info(i)%std_id,IndataPath,File_Suffix,TimeStep,std_eles)
        !write(*,*)std_eles
        do j = 1, TimeStep
            tempInt = std_eles(j)%date
            lyear = tempInt/10000
            lmonth = (mod(tempInt,10000) - mod(tempInt,100))/100
            lday = mod(tempInt-lyear*10000-lmonth*100,100)
            dayId_of_year = day_in_year(lyear,lmonth,lday)-1
            !!! 计算赤纬SunDelta, 单位为degree
            call sun_delta(dayId_of_year,SunDelta)
            !!! 计算太阳高度角,单位: degree
            bjtT = lhour+lminute/60.0+lseconds/3600.0
            call sun_h0(lfai,llamda,SunDelta,bjtT,Sunh0)
            !!! 计算太阳辐射等级值
            Clower = int(std_eles(j)%Cloud_Low)
            Ctotal = int(std_eles(j)%Cloud_Total)
            call radiate_lev(Clower,Ctotal,Sunh0,lRadLev)
            !!! 计算帕斯奎尔大气稳定度
            U10_10min = aint(std_eles(j)%wind_10min * 10.)/10.
            call Atmos_PT_stability(anint(U10_10min*10.)/10.,lRadLev,PT)
            !!! 计算混合层厚度, 单位: m
            U10 = U10_10min
            call mixlevH(Meoto_region,lfai,U10,PT,mixH)
            !!! 计算大气环境容量系数A
            vd = 0.0     !!! 此处忽略干沉降过程，假设干沉降速率为0m/s
            if(std_eles(j)%rain .ge. MissingValue) then
                Rain = 0
            else
                Rain = std_eles(j)%rain
            end if
            call Horizontal_wind_of_MixLayer(U10,mixH,U_Horizontal)
            call pseudo_horizontal_diffusion(U_Horizontal,PT,U_pseudo_diffusion)
            call cal_Avalue(U_Horizontal,U_pseudo_diffusion,mixH,S,vd,Rain,Av)
            ! A(j,i) = Av
            cal_Result(j)%date = std_eles(j)%date
            cal_Result(j)%Avalue = Av
        end do
        ! write(*,*)(A(j,i),j=1,TimeStep)
        ! write(*,*)cal_Result

        write(tempStr,"(i5)") std_info(i)%std_id
        outfl = trim(adjustl(tempStr))//".txt"
        ! call outputs_arr(TimeStep,1,A,OutdataPath,outfl)
        call outputs_type(TimeStep,cal_Result,OutdataPath,outfl)
        deallocate(std_eles)
        deallocate(cal_Result)
        print*," "
    end do
    !deallocate(std_info,A)
end program main


!!!! 读入数据子程序
subroutine inputs(stdid,dataPath,file_suffix,timeStep,std_data)
    use Public_parameter
    implicit none
    integer stdid,timeStep
    character(len=100) dataPath
    character(len=50) file_suffix
    character(len=10) tempStr
    type(Station_elements)::std_data(timeStep)
    integer i

    write(tempStr,"(i5)")stdid
    open(3,file=trim(trim(adjustl(dataPath))//trim(adjustl(tempStr))//adjustl(file_suffix)),status="old")
    read(3,*)
    do i = 1, timeStep
        read(3,*)std_data(i)
        !write(*,*)std_data(i)
    end do
    close(3)
end subroutine inputs

!!!! 输出数据子程序
subroutine outputs_arr(cols,rows,outData,OutPath,outfl)
    implicit none
    integer cols,rows
    real(8) outData(cols,rows)
    character(len=100) OutPath
    character(len=50) outfl
    character(len=80) form
    integer i,j

    open(7,file=trim(trim(adjustl(OutPath))//adjustl(outfl)),status="replace")
    write(form,*)"(",cols,"f8.2)"    !!! 动态定义输出格式

     do i = 1, rows
         write(7,form)(outData(j,i),j=1,cols)
    end do
    close(7)
end subroutine outputs_arr


subroutine outputs_type(rows,outData,OutPath,outfl)
    use Public_parameter
    implicit none
    integer rows
    type(OutDataFmt)::outData(rows)
    character(len=100) OutPath
    character(len=50) outfl
    integer i

    open(7,file=trim(trim(adjustl(OutPath))//adjustl(outfl)),status="replace")
     do i = 1, rows
         write(7,100)outData(i)
    end do
    100 format(1X,I10,F8.2)        !!! 定义有格式输出
    close(7)
end subroutine outputs_type

!!! 1. 子函数leap，判断平（闰）年
function  leap(year)
    integer::leap,year

    if((mod(year,4)==0 .and. mod(year,100)/=0)) then
        leap=1
    else if(mod(year,400)==0) then
        leap=1
    else
        leap=0
    end if
end function leap

!!! 2. 子函数days_of_month，根据给定的年、月计算当月共有多有天（1-31）
function  days_of_month(year,month)
    integer::year,month,days_of_month
    integer::leap        !!! 子程序声明

    select case(month)
     case(1,3,5,7,8,10,12)
         days_of_month=31
     case(4,6,9,11)
         days_of_month=30
     case default
        if(leap(year)==1) then   !!! leap year
            days_of_month=29
        else                     !!! not leap year
            days_of_month=28
        end if
    endselect
end function  days_of_month

!!! 3. 子函数day_in_year 对某一确定日期（year,month,day）计算它在当年中是具体多少天（1-366）
function  day_in_year(year,month,day)
    integer::days_of_month     !!! 子程序声明
    integer::year,month,day
    integer::day_in_year
    integer::imo

    imo=1
    day_in_year = day
    do while(imo < month)
        day_in_year = day_in_year + days_of_month(year,imo)
        imo = imo + 1
    end do
end function  day_in_year

!!! 4. 将角度转换位弧度
function deg2rand(x)
    implicit none
    real:: pi=3.1415926
    real x,deg2rand

    deg2rand = x*pi/180
end function deg2rand

!!! 5. 计算太阳赤纬, 单位degree
subroutine sun_delta(dn,delta)
    implicit none
    external deg2rand
    real:: pi=3.1415926       !!! 圆周率常数
    integer*4 dn              !!! 一年中的日期序数(0~365)
    real tm,deg2rand
    real theta0,delta

    theta0 = 360.0*dn/365  !!! unit is degree
    tm = deg2rand(theta0)
    delta = (0.006918-0.399912*cos(tm)+0.070257*sin(tm)-0.006758*cos(2*tm)+ &
            &0.000907*sin(2*tm)-0.002697*cos(3*tm)+0.001480*sin(3*tm))*180/pi
    !print*,'sun declination: ',delta
end subroutine sun_delta

!!! 6. 计算太阳高度角, 单位degree
subroutine sun_h0(fai,lamda,delta,bjtT,h0)
    implicit none
    real:: pi=3.1415926
    real fai,lamda,delta     !!! 当地纬度、经度以及赤纬，单位均为degree
    real bjtT,h0             !!! 北京时间，单位为hour; 太阳高度角, 单位为degree

    h0 = asin(sin(fai*pi/180)*sin(delta*pi/180)+cos(fai*pi/180)*cos(delta*pi/180)* &
         &cos((15*bjtT+lamda-300)*pi/180))*180/pi
    !print*,'sun hight angle: ',h0
end subroutine sun_h0

!!! 7. 获取太阳辐射等级值
subroutine radiate_lev(C_lower,C_total,sun_h0,radLev)
    implicit none
    integer C_lower,C_total
    real sun_h0
    integer radLev  !!! 太阳辐射等级值, 无量纲整数

    if(C_lower>=8) then
        radLev = 0
    elseif(C_lower>=5 .and. C_lower<7) then
        if(sun_h0>65) then
            radLev = 1
        else
            radLev = 0
        endif
    else
        if(C_total>=8) then
            if(sun_h0<=0) radLev = -1    !!! 夜晚太阳高度角小于0
            if(sun_h0>35) then
                radLev = 1
            else
                radLev = 0
            endif
        endif
        if(C_total>=5 .and. C_total<=7) then
            if(sun_h0<=0) radLev = -1
            if(sun_h0>15 .and. sun_h0<=35) then
                radLev = 1
            elseif(sun_h0>35 .and. sun_h0<=65) then
                radLev = 2
            elseif(sun_h0>65) then
                radLev = 3
            else
                radLev = 0
            endif
        endif
        if(C_total<=4) then
            if(sun_h0<=0) radLev = -2
            if(sun_h0>0 .and. sun_h0<=15) then
                radLev = -1
            elseif(sun_h0>15 .and. sun_h0<=35) then
                radLev = 1
            elseif(sun_h0>35 .and. sun_h0<65) then
                radLev = 2
            else
                radLev = 3
            endif
        endif
    endif
    !print*,'radiate level: ',radLev
end subroutine radiate_lev

!!!  8. 计算帕斯奎尔大气稳定度
!!!  A: 强不稳定; B: 不稳定; C: 弱不稳定; D: 中性; E: 较稳定; F: 稳定.
subroutine Atmos_PT_stability(u10_10min,radLev,PTv)
    implicit none
    integer radLev   !!! 太阳辐射等级
    real u10_10min   !!! 地面10m高度10分钟平均风速, 单位:m/s, 保留一位小数
    character(len=8) PTv   !!! 帕斯奎尔大气稳定度值, 有效值:A~F

    if(u10_10min<=1.9) then
        select case(radLev)
        case(-2)
            PTv = 'F'
        case(-1)
            PTv = 'E'
        case(0)
            PTv = 'D'
        case(1)
            PTv = 'B'
        case(2)
            PTv = 'A~B'
        case default
            PTv = 'A'
        endselect
    elseif(u10_10min<=2.9) then
        select case(radLev)
        case(-2)
            PTv = 'F'
        case(-1)
            PTv = 'E'
        case(0)
            PTv = 'D'
        case(1)
            PTv = 'C'
        case(2)
            PTv = 'B'
        case default
            PTv = 'A~B'
        endselect
    elseif(u10_10min<=4.9) then
        select case(radLev)
        case(-2)
            PTv = 'E'
        case(-1,0)
            PTv = 'D'
        case(1)
            PTv = 'C'
        case(2)
            PTv = 'B~C'
        case default
            PTv = 'B'
        endselect
    elseif(u10_10min<=5.9) then
        select case(radLev)
        case(1,0,-1,-2)
            PTv = 'D'
        case(2)
            PTv = 'C~D'
        case default
            PTv = 'C'
        endselect
    else
        PTv = 'D'
    endif
    !print*,'Atmospheric stability: ',PTv
end subroutine Atmos_PT_stability

!!! 9. 确定混合层系数c0
subroutine mixlevH_c(localId,PTv,c0)
    implicit none
    integer localId    !!! 地区序号
    character(len=8) PTv
    real c0  !!! 混合层系数

    select case (trim(PTv))
    case ('F')
        c0 = 0.70
    case('E')
        c0 = 1.66
    case('D')
        select case(localId)
        case(1,7)
            c0 = 0.031
        case(2,3,4)
            c0 = 0.019
        case(5)
            c0 = 0.012
        case default
            c0 = 0.022
        endselect
    case('C')
        select case(localId)
        case(1,2,3,4,7)
            c0 = 0.041
        case(5)
            c0 = 0.020
        case default
            c0 = 0.031
        endselect
    case('B')
        select case(localId)
        case(1,7)
            c0 = 0.067
        case(2,3,4)
            c0 = 0.060
        case(5)
            c0 = 0.029
        case default
            c0 = 0.048
        endselect
    case default
        select case(localId)
        case(1,7)
            c0 = 0.090
        case(2,3,4,6)
            c0 = 0.073
        case default
            c0 = 0.056
        endselect
    end select
    !print*,'mix level cofficient: ',c0
end subroutine mixlevH_c

!!! 10.
subroutine PTindex(PTv,inx)
    implicit none
    character(len=8) PTv
    integer inx

    inx = index(PTv,'~')
end subroutine PTindex

!!! 11. 获取地区序号regionId
subroutine Get_regionId(Meoto_region,regionId)
    implicit none
    character(len=50) Meoto_region
    integer regionId

    select case(trim(Meoto_region))
    case('新疆','西藏','青海')
        regionId = 1
    case('黑龙江','吉林','辽宁','内蒙古_阴山北')
        regionId = 2
    case('北京','天津','河北','河南','山东')
        regionId = 3
    case('内蒙古_阴山南','山西','陕西_秦岭北','宁夏','甘肃_渭河北')
        regionId = 4
    case('上海','广东','广西','湖南','湖北','江苏','浙江','安徽','海南','台湾','福建','江西')
        regionId = 5
    case('云南','贵州','四川','甘肃_渭河南','陕西_秦岭南')
        regionId = 6
    case('静风区_年均风速小于1')
        regionId = 7
    case default
        print*,'error inputs'
    end select
    !print*,'regional Id: ',regionId
end subroutine Get_regionId

!!! 12. 计算混合层厚度H
subroutine mixlevH(region,fai,u10,PTv,H)
    implicit none
    real:: pi=3.1415926
    real(8):: omega=0.0000729 !!! 地球自转角速度, 单位：rad/s
    character(len=50) region    !!! 地区名称
    character(len=8) PTv
    integer localId
    real u10  !!! 10m高度平均风速, 单位:m/s
    real fai  !!! 地理纬度, 单位: degree
    real f    !!! 地转参数
    real H    !!! 混合层厚度，单位:m
    real u10_t,C0
    character(len=8) PTv_t
    integer inx

    f = 2*omega*sin(fai*pi/180)
    call PTindex(PTv,inx)
    PTv_t = PTv(inx+1:inx+1)
    if(u10>6) then
        u10_t = 6.
    else
        u10_t = u10
    endif
    call Get_regionId(region,localId)
    call mixlevH_c(localId,PTv_t,C0)
    select case(trim(PTv_t))
    case('A','B','C','D')
        H = C0*u10_t/f
    case default
        H = C0*sqrt(u10_t/f)
    endselect
    !print*,'mix level height: ',H
end subroutine mixlevH


!!! 13. 计算混合层内的平流风速（此处为业务上使用边界层内的风速幂率做近似计算）
subroutine  Horizontal_wind_of_MixLayer(u10,mixlevH,u_horizontal)
    implicit none
    real,parameter:: kama=0.16     !!! 风速近似幂率指数
    real u10,mixlevH
    real u_MixLayer            !!! 10m高度及混合层高度处的风速值, 单位: m/s
    real u_horizontal              !!! 平流风速, 单位: m/s

    u_MixLayer = u10*(mixlevH/10)**kama
    u_horizontal = (u10+u_MixLayer)*0.5
    !print*,'u_horizontal: ',u_horizontal
end subroutine Horizontal_wind_of_MixLayer

!!! 14. 计算混合层内的伪平流扩散速度(此处为业务上的近似计算)
subroutine pseudo_horizontal_diffusion(u_horizontal,PTv,u_pseudo_diffusion)
    implicit none
    real u_horizontal
    character(len=8) PTv,PTv_t
    integer inx
    real Co,u_pseudo_diffusion

    call PTindex(PTv,inx)
    PTv_t = PTv(inx+1:inx+1)
    !print*,'PTv: ',PTv_t
    select case (trim(PTv_t))
    case('A')
        Co = 0.14
    case('B')
        Co = 0.12
    case('C')
        Co = 0.10
    case('D')
        Co = 0.05
    case('E')
        Co = 0.02
    case('F')
        Co = 0.01
    case default
        print*,'Pasquale stability is invalid'
    end select

    u_pseudo_diffusion = u_horizontal*Co
    !print*,'u_pseudo_diffusion: ',u_pseudo_diffusion
end subroutine pseudo_horizontal_diffusion

!!! 15. 计算大气容量系数Avalue
subroutine cal_Avalue(u_horizontal,u_pseudo_diffusion,H,S,vd,R,Avalue)
    implicit none
    real:: pi=3.1415926
    real(8):: wr=0.000019    !!! 清洗比，无量纲
    real u_horizontal,u_pseudo_diffusion    !!! 平流及伪扩散速度, 单位: m/s
    real u_plus
    real H                   !!! 混合层厚度, 单位: m
    real S                   !!! 区域面积, 单位: km2
    real vd                  !!! 干沉降速度, 单位: m/s
    real R                   !!! 累计降水量(数小时/天/月/年), 单位: mm
    real(8) Avalue           !!! 大气容量系数, 单位: 10000km2/数小时([天,月,年])
    real tm

    u_plus = u_horizontal + u_pseudo_diffusion
    tm = sqrt(pi)*u_plus*H*0.5
    Avalue = 0.0031536*tm*(1+(sqrt(S)*(vd+wr*R)/tm)*1000)
    !print*,'A value: ',Avalue
end subroutine cal_Avalue
