(globals
version = 3
space= 15
io_order = default
)
(row_margin
	(top
	(io_row ring_number=1 margin=0)
	(io_row ring_number=2 margin=0)
	)
	(left
	(io_row ring_number=1 margin=0)
	(io_row ring_number=3 margin=0)
	)
	(bottom
	(io_row ring_number=1 margin=0)
	(io_row ring_number=4 margin=0)
	)
	(right
	(io_row ring_number=1 margin=0)
	(io_row ring_number=5 margin=0)
	)
)
(iopad
	(topleft
		(inst name="CORNER_TL" cell=PCORNER orientation=R270)
	)
	(left
		(inst name="vss_2" 	    cell=PVSS3CDG 		orientation=R270)			# Common GND 2
		(inst name="vdd_poc" 	cell=PVDD2POC 		orientation=R270)			# VDD power-on control
		(inst name="vdd_core_1" cell=PVDD1CDG 		orientation=R270)			# VDD for core
		(inst name="vdd_core_2" cell=PVDD1CDG 		orientation=R270)			# VDD for core
		(inst name="SCAN_EN" 	cell=PDUW0408SCDG 	orientation=R270)
		(inst name="SCAN_TSTMD" cell=PDUW0408SCDG 	orientation=R270)
		(inst name="SCAN_DI" 	cell=PDUW0408SCDG 	orientation=R270)
		(inst name="SCAN_DO" 	cell=PDUW0408SCDG 	orientation=R270)
		(inst name="RESET_N" 	cell=PDUW0408SCDG 	orientation=R270)
		(inst name="CLK_EXT"    cell=PDUW0408SCDG 	orientation=R270)
		(inst name="CLK_SEL" 	cell=PDUW0408SCDG 	orientation=R270)
		(inst name="CLK_OUT" 	cell=PDUW0408SCDG 	orientation=R270)
	)
	(topright
		(inst name="CORNER_TR" cell=PCORNER orientation=R180)
	)
	(top
		(inst name="PLL_BIAS_1" cell=PDB3A 		    orientation=R180)
		(inst name="PLL_BIAS_2" cell=PDB3A 			orientation=R180)
		(inst name="PLL_CLK_IN" cell=PXOE2CDG 		orientation=R180 space=20) 		# Takes two spaces
		(inst name="PLL_CTRL_0" cell=PDUW0408SCDG 	orientation=R180 space=20)
		(inst name="PLL_CTRL_1" cell=PDUW0408SCDG 	orientation=R180 space=15)
		(inst name="PLL_CTRL_2" cell=PDUW0408SCDG 	orientation=R180)
		(inst name="PLL_CTRL_3" cell=PDUW0408SCDG 	orientation=R180)
		(inst name="GPIO_0"     cell=PDUW0408SCDG 	orientation=R180)
		(inst name="GPIO_1"     cell=PDUW0408SCDG 	orientation=R180)
		(inst name="GPIO_2"     cell=PDUW0408SCDG 	orientation=R180)
		(inst name="GPIO_3"     cell=PDUW0408SCDG 	orientation=R180)
	)
	(bottomright
		(inst name="CORNER_BR" cell=PCORNER orientation=R90)
	)
	(right
		(inst name="GPIO_15" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_14" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_13" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_12" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_11" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_10" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_9" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_8" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_7" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_6" 	cell=PDUW0408SCDG 	orientation=R90)
		(inst name="GPIO_5" 	cell=PDUW0408SCDG 	orientation=R90)	
		(inst name="GPIO_4" 	cell=PDUW0408SCDG 	orientation=R90)	
	)
	(bottomleft
		(inst name="CORNER_BL" cell=PCORNER orientation=R0)
	)
	(bottom
		(inst name="vss_1" 		cell=PVSS3CDG 		orientation=R0)				# Common GND 1
		(inst name="GPIO_24" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_23" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_22" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="vdd_io_1" 	cell=PVDD2CDG 		orientation=R0)				# VDD for I/O
		(inst name="vdd_io_2" 	cell=PVDD2CDG 		orientation=R0)				# VDD for I/O
		(inst name="GPIO_21" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_20" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_19" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_18" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_17" 	cell=PDUW0408SCDG 	orientation=R0)
		(inst name="GPIO_16" 	cell=PDUW0408SCDG 	orientation=R0)
	)

	(left
    (locals ring_number = 2)
		(inst name="BPAD_vss_2" 	 		offset=90 	)
		(inst name="BPAD_vdd_poc" 	  			)
		(inst name="BPAD_vdd_core_1"    		)
		(inst name="BPAD_vdd_core_2"    		)
		(inst name="BPAD_SCAN_EN" 	  			)
		(inst name="BPAD_SCAN_TSTMD"    		)
		(inst name="BPAD_SCAN_DI" 	  			)
		(inst name="BPAD_SCAN_DO" 	  			) 
		(inst name="BPAD_RESET_N" 	  			)
		(inst name="BPAD_CLK_EXT"     			)
		(inst name="BPAD_CLK_SEL" 	  			)
		(inst name="BPAD_CLK_OUT" 	  			)
	)
	(top
	(locals ring_number = 3)
		(inst name="BPAD_PLL_BIAS_1"		offset=90	) 
		(inst name="BPAD_PLL_BIAS_2"			) 
		(inst name="BPAD_PLL_CLK_I"				) 
		(inst name="BPAD_PLL_CLK_O"				) 
		(inst name="BPAD_PLL_CTRL_0"			) 
		(inst name="BPAD_PLL_CTRL_1"			) 
		(inst name="BPAD_PLL_CTRL_2"			) 
		(inst name="BPAD_PLL_CTRL_3"			)
		(inst name="BPAD_GPIO_0"    			) 
		(inst name="BPAD_GPIO_1"    			) 
		(inst name="BPAD_GPIO_2"    			) 
		(inst name="BPAD_GPIO_3"    			) 
	)

	(right
	(locals ring_number = 4)
		(inst name="BPAD_GPIO_15"			offset=90	)
		(inst name="BPAD_GPIO_14"				)
		(inst name="BPAD_GPIO_13"				)
		(inst name="BPAD_GPIO_12" 				)
		(inst name="BPAD_GPIO_11"				)
		(inst name="BPAD_GPIO_10"				)
		(inst name="BPAD_GPIO_9" 				)
		(inst name="BPAD_GPIO_8" 				)
		(inst name="BPAD_GPIO_7" 				)
		(inst name="BPAD_GPIO_6" 				)
		(inst name="BPAD_GPIO_5" 				)
		(inst name="BPAD_GPIO_4" 				)
	)

	(bottom
	(locals ring_number = 5)
		(inst name="BPAD_vss_1" 	  		offset=90	)
		(inst name="BPAD_GPIO_24" 				)
		(inst name="BPAD_GPIO_23" 				)
		(inst name="BPAD_GPIO_22" 				)
		(inst name="BPAD_vdd_io_1"				)
		(inst name="BPAD_vdd_io_2"				)
		(inst name="BPAD_GPIO_21" 				)
		(inst name="BPAD_GPIO_20" 				)
		(inst name="BPAD_GPIO_19" 				)
		(inst name="BPAD_GPIO_18" 				)
		(inst name="BPAD_GPIO_17" 				)
		(inst name="BPAD_GPIO_16" 				)
	)
)







