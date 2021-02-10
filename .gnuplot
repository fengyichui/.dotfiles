#
# 1.加载脚本: 
#   load "script.dem"
#
# 2.plot
#   plot sin(x)
#   plot sin(x) with lines              # lines,dots,linespoints,points,boxes,steps
#   plot "a.dat"                        # 使用文件内的第1列数据绘图
#   plot "a.dat" using 2 with lines     # 使用文件内的第2列数据绘图
#   plot "a.dat" using ($1-$2)          # 使用文件内的第1列减去第2列的结果绘图
#   plot "a.dat" using 1:2 with lines,\ # 使用文件内的数据绘制两条线, 线1:第1,2列分别作为x,y轴;
#        "a.dat" using 1:3 with lines   #                             线2:第1,3列分别作为x,y轴
#
# 3.常用命令：
#   set title "各城市月平均降水量"    # Title
#   set xlabel "月份"                 # X轴标签
#   set ylabel "降水量（毫米）"       # Y轴标签
#   set xrange [0.5:12.5]             # X轴范围
#   set yrange [0.5:12.5]             # Y轴范围
#   set xtics 1,1,12                  # X周刻度，显示字符、刻度位置、刻度等级
#   set ytics 1,1,12                  # Y周刻度，显示字符、刻度位置、刻度等级
#   set grid                          # 显示网格
#
# 4.输出PNG
#   set term pngcairo lw 2 font "AR␣PL␣UKai␣CN,14"
#   set output "1.png"
#   plot ...
#   set output
#

# enable macros, Add "@" to call the defined macros, for example: @defined_macro
set macros

# add macros to select a desired terminal
WXT = "set terminal wxt size 350,262 enhanced font 'Verdana,10' persist"
PNG = "set terminal pngcairo size 350,262 enhanced font 'Verdana,10'"
SVG = "set terminal svg size 350,262 fname 'Verdana, Helvetica, Arial, sans-serif' fsize = 10"
CYG = "set terminal sixel"


# change a color of border.
set border lw 1 lc rgb "grey"

# change text colors of  tics
set xtics textcolor rgb "grey"
set ytics textcolor rgb "grey"

# change text colors of labels
set xlabel "X" textcolor rgb "grey"
set ylabel "Y" textcolor rgb "grey"

# change a text color of key
set key textcolor rgb "grey"

# Set default terminal for cygwin
#set terminal sixel # size 800,640
set terminal x11 # For x11

