onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbench/SUT/clk
add wave -noupdate /tbench/SUT/reset
add wave -noupdate /tbench/SUT/sym_clk_en
add wave -noupdate /tbench/SUT/sam_clk_en
add wave -noupdate -radix decimal /tbench/SUT/x_in
add wave -noupdate -max 130909.00000000001 -min -130999.0 -radix decimal -childformat {{{/tbench/SUT/y[17]} -radix decimal} {{/tbench/SUT/y[16]} -radix decimal} {{/tbench/SUT/y[15]} -radix decimal} {{/tbench/SUT/y[14]} -radix decimal} {{/tbench/SUT/y[13]} -radix decimal} {{/tbench/SUT/y[12]} -radix decimal} {{/tbench/SUT/y[11]} -radix decimal} {{/tbench/SUT/y[10]} -radix decimal} {{/tbench/SUT/y[9]} -radix decimal} {{/tbench/SUT/y[8]} -radix decimal} {{/tbench/SUT/y[7]} -radix decimal} {{/tbench/SUT/y[6]} -radix decimal} {{/tbench/SUT/y[5]} -radix decimal} {{/tbench/SUT/y[4]} -radix decimal} {{/tbench/SUT/y[3]} -radix decimal} {{/tbench/SUT/y[2]} -radix decimal} {{/tbench/SUT/y[1]} -radix decimal} {{/tbench/SUT/y[0]} -radix decimal}} -subitemconfig {{/tbench/SUT/y[17]} {-radix decimal} {/tbench/SUT/y[16]} {-radix decimal} {/tbench/SUT/y[15]} {-radix decimal} {/tbench/SUT/y[14]} {-radix decimal} {/tbench/SUT/y[13]} {-radix decimal} {/tbench/SUT/y[12]} {-radix decimal} {/tbench/SUT/y[11]} {-radix decimal} {/tbench/SUT/y[10]} {-radix decimal} {/tbench/SUT/y[9]} {-radix decimal} {/tbench/SUT/y[8]} {-radix decimal} {/tbench/SUT/y[7]} {-radix decimal} {/tbench/SUT/y[6]} {-radix decimal} {/tbench/SUT/y[5]} {-radix decimal} {/tbench/SUT/y[4]} {-radix decimal} {/tbench/SUT/y[3]} {-radix decimal} {/tbench/SUT/y[2]} {-radix decimal} {/tbench/SUT/y[1]} {-radix decimal} {/tbench/SUT/y[0]} {-radix decimal}} /tbench/SUT/y
add wave -noupdate -format Analog-Step -height 84 -max 8949000000.0 -min -1048440000.0 -radix decimal /tbench/SUT/y_temp
add wave -noupdate -radix unsigned /tbench/SUT/counter
add wave -noupdate -radix decimal /tbench/SUT/i
add wave -noupdate -radix decimal /tbench/SUT/x
add wave -noupdate -radix decimal /tbench/SUT/xm
add wave -noupdate -radix decimal /tbench/SUT/h
add wave -noupdate -radix decimal /tbench/SUT/m
add wave -noupdate -radix decimal -childformat {{{/tbench/SUT/m_acc[19]} -radix decimal} {{/tbench/SUT/m_acc[18]} -radix decimal} {{/tbench/SUT/m_acc[17]} -radix decimal} {{/tbench/SUT/m_acc[16]} -radix decimal} {{/tbench/SUT/m_acc[15]} -radix decimal} {{/tbench/SUT/m_acc[14]} -radix decimal} {{/tbench/SUT/m_acc[13]} -radix decimal} {{/tbench/SUT/m_acc[12]} -radix decimal} {{/tbench/SUT/m_acc[11]} -radix decimal} {{/tbench/SUT/m_acc[10]} -radix decimal} {{/tbench/SUT/m_acc[9]} -radix decimal} {{/tbench/SUT/m_acc[8]} -radix decimal} {{/tbench/SUT/m_acc[7]} -radix decimal} {{/tbench/SUT/m_acc[6]} -radix decimal} {{/tbench/SUT/m_acc[5]} -radix decimal} {{/tbench/SUT/m_acc[4]} -radix decimal} {{/tbench/SUT/m_acc[3]} -radix decimal} {{/tbench/SUT/m_acc[2]} -radix decimal} {{/tbench/SUT/m_acc[1]} -radix decimal} {{/tbench/SUT/m_acc[0]} -radix decimal}} -expand -subitemconfig {{/tbench/SUT/m_acc[19]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[18]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[17]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[16]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[15]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[14]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[13]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[12]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[11]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[10]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[9]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[8]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[7]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[6]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[5]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[4]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[3]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[2]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[1]} {-height 16 -radix decimal} {/tbench/SUT/m_acc[0]} {-height 16 -radix decimal}} /tbench/SUT/m_acc
add wave -noupdate -radix decimal /tbench/SUT/m_acc_reg
add wave -noupdate -radix decimal -childformat {{{/tbench/SUT/sum_level_1[9]} -radix decimal} {{/tbench/SUT/sum_level_1[8]} -radix decimal} {{/tbench/SUT/sum_level_1[7]} -radix decimal} {{/tbench/SUT/sum_level_1[6]} -radix decimal} {{/tbench/SUT/sum_level_1[5]} -radix decimal} {{/tbench/SUT/sum_level_1[4]} -radix decimal} {{/tbench/SUT/sum_level_1[3]} -radix decimal} {{/tbench/SUT/sum_level_1[2]} -radix decimal} {{/tbench/SUT/sum_level_1[1]} -radix decimal} {{/tbench/SUT/sum_level_1[0]} -radix decimal}} -expand -subitemconfig {{/tbench/SUT/sum_level_1[9]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[8]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[7]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[6]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[5]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[4]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[3]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[2]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[1]} {-height 16 -radix decimal} {/tbench/SUT/sum_level_1[0]} {-height 16 -radix decimal}} /tbench/SUT/sum_level_1
add wave -noupdate -radix decimal /tbench/SUT/sum_level_2
add wave -noupdate -radix decimal /tbench/SUT/sum_level_3
add wave -noupdate -radix decimal /tbench/SUT/sum_level_4
add wave -noupdate -radix decimal /tbench/SUT/mout21
add wave -noupdate -radix decimal /tbench/SUT/mout21_reg
add wave -noupdate -radix decimal /tbench/SUT/h80
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1945503 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {1944524 ns} {1946536 ns}
