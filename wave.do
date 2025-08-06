onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider PISO
add wave -noupdate /top_tb/SF/ps/reset_n_i
add wave -noupdate /top_tb/SF/ps/load_i
add wave -noupdate /top_tb/SF/ps/enable_i
add wave -noupdate /top_tb/SF/ps/a_i
add wave -noupdate /top_tb/SF/ps/b_i
add wave -noupdate /top_tb/SF/ps/b_o
add wave -noupdate /top_tb/SF/ps/temp_b
add wave -noupdate /top_tb/SF/ps/a_o
add wave -noupdate /top_tb/SF/ps/b_o
add wave -noupdate -divider SIPO
add wave -noupdate /top_tb/SF/sp_sr/clk_i
add wave -noupdate /top_tb/SF/sp_sr/reset_n_i
add wave -noupdate /top_tb/SF/sp_sr/enable_i
add wave -noupdate /top_tb/SF/sp_sr/sum_o_out_i
add wave -noupdate /top_tb/SF/sp_sr/sum_o
add wave -noupdate -divider FULL_ADDER
add wave -noupdate /top_tb/SF/fa/a_out_i
add wave -noupdate /top_tb/SF/fa/b_out_i
add wave -noupdate /top_tb/SF/fa/sum_o
add wave -noupdate /top_tb/SF/fa/c_i
add wave -noupdate /top_tb/SF/fa/c_o
add wave -noupdate -divider D_FLIP_FLOP
add wave -noupdate /top_tb/SF/dflip_flop/reset_i
add wave -noupdate /top_tb/SF/dflip_flop/data_i
add wave -noupdate /top_tb/SF/dflip_flop/q_o
add wave -noupdate -divider FINAL_OUTPUT
add wave -noupdate /top_tb/clock_sb
add wave -noupdate /top_tb/resetn_sb
add wave -noupdate /top_tb/start_sb
add wave -noupdate /top_tb/A_sb
add wave -noupdate /top_tb/B_sb
add wave -noupdate /top_tb/sum_out_sb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {135 ns} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {110 ns} {160 ns}
