proc create_hier_cell_RP_Static {nameHier RP_number } {

  if { $nameHier eq "" || $RP_number eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1_Static() - Empty argument(s)!"}
     return
  }

  # # Create Static Hierarchical cell
  set hier_obj [create_bd_cell -type hier /RP${RP_number}/$nameHier]

  # Check if RP_number is within the allowed range
  if { $RP_number < 1 || $RP_number > 31 } {
      puts "ERROR: RP_number must be between 1 and 31."
      return
  }

  # Set num_low and num_high based on the value of RP_number
  if { $RP_number < 17 } {
      set num_low [expr {$RP_number - 1}]
      set num_high 0
  } else {
      set num_low 15
      set num_high [expr {$RP_number - 1 - 15}]
  }

  # Print: num_low and num_high are now set based on RP_number conditions
  puts "num_low: $num_low, num_high: $num_high"
  
###########################################################################################################################################################################

  # Create instance: axis_switch_outputMux, and set properties
  set axis_switch_outputMux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 /RP${RP_number}/${nameHier}/axis_switch_outputMux ]
  set_property -dict [list \
    CONFIG.M00_AXIS_BASETDEST {0x00000000} \
    CONFIG.M00_AXIS_HIGHTDEST {0x0000000f} \
    CONFIG.M01_AXIS_BASETDEST {0x00000010} \
    CONFIG.M01_AXIS_HIGHTDEST {0x0000001f} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $axis_switch_outputMux

  # Create instance: axis_noc_inputMux, and set properties
  set axis_noc_inputMux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 /RP${RP_number}/${nameHier}/axis_noc_inputMux ]
  set_property -dict [list \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axis_noc_inputMux

  set_property -dict [ list \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/M00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/S00_INIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/S01_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS} \
  ] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/aclk0]
  
###########################################################################################################################################################################

  # Create instance: axis_noc_low
  set axis_noc_low [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 /RP${RP_number}/${nameHier}/axis_noc_low]
  # Set properties on the axis_noc_low instance
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI [expr {$num_low + 1}] \
    CONFIG.NUM_NSI $num_low \
    CONFIG.SI_DESTID_PINS {1} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_low

  set_property -dict [ list \
    CONFIG.TDEST_WIDTH {8} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/S00_AXIS]

  # Initialize an empty string for the nested CONFIG.CONNECTIONS structure
  set connections_axis_list ""
  # Loop to build the nested CONNECTIONS list based on num_nmi
  for {set i 0} {$i < $num_low} {incr i} {
    # Format the index to always be two digits
    set formatted_index [format "%02d" [expr {$i + 1}]]
    # Append each INIS connection in a nested format with bandwidth settings
    append connections_axis_list "M${formatted_index}_INIS { write_bw {500}} "
  }
  # Apply the dynamically created CONNECTIONS list to the S00_AXIS interface
  set_property -dict [list CONFIG.CONNECTIONS $connections_axis_list] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/S00_AXIS]

  # Loop to set the CONNECTIONS for each SINIS interface to the M_AXIS
  for {set i 0} {$i < $num_low} {incr i} {
    # Format the index to always be two digits
    set formatted_index [format "%02d" $i]
    # Set the CONNECTIONS for each SINIS interface to the M_AXIS
    set_property -dict [list CONFIG.CONNECTIONS {M00_INIS { write_bw {500} }}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/S${formatted_index}_INIS]
  }

  # Initialize the NMI_TDEST_VALS list with values starting from 1 "," is for M00_INIS
  set nmi_tdest_vals "," 
  for {set i 0} {$i < $num_low} {incr i} {
    # Format the hex value with leading zeros
    set formatted_hex [format "0x%08X" [expr {$i + 1}]]
    # Append each formatted hex value pair, separated by a comma
    append nmi_tdest_vals "$formatted_hex $formatted_hex"
    
    # Add a comma separator after each pair, except the last one
    if { $i < $num_low - 1 } {
      append nmi_tdest_vals ","
    }
  }

  # Set the NMI_TDEST_VALS property on the axis_noc_low instance with quotes
  set_property -dict [list CONFIG.NMI_TDEST_VALS "$nmi_tdest_vals"] [get_bd_cells /RP${RP_number}/${nameHier}/axis_noc_low]

  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
  ] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_low/aclk0]

###########################################################################################################################################################################

  # Create instance: axis_noc_high
  set axis_noc_high [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 /RP${RP_number}/${nameHier}/axis_noc_high]
  # Set properties on the axis_noc_high instance
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI [expr {$num_high + 1}] \
    CONFIG.NUM_NSI $num_high \
    CONFIG.SI_DESTID_PINS {1} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_high

  set_property -dict [ list \
    CONFIG.TDEST_WIDTH {8} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/S00_AXIS]

  # Initialize an empty string for the nested CONFIG.CONNECTIONS structure
  set connections_axis_list ""
  # Loop to build the nested CONNECTIONS list based on num_nmi
  for {set i 0} {$i < $num_high} {incr i} {
    # Format the index to always be two digits + 16 for high
    set formatted_index [format "%02d" [expr {$i + 1}]] 
    # Append each INIS connection in a nested format with bandwidth settings
    append connections_axis_list "M${formatted_index}_INIS { write_bw {500}} "
  }
  # Apply the dynamically created CONNECTIONS list to the S00_AXIS interface
  set_property -dict [list CONFIG.CONNECTIONS $connections_axis_list] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/S00_AXIS]

  # Loop to set the CONNECTIONS for each SINIS interface to the M_AXIS
  for {set i 0} {$i < $num_high} {incr i} {
    # Format the index to always be two digits
    set formatted_index [format "%02d" $i]
    # Set the CONNECTIONS for each SINIS interface to the M_AXIS
    set_property -dict [list CONFIG.CONNECTIONS {M00_INIS { write_bw {500} }}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/S${formatted_index}_INIS]
  }

  # Initialize the NMI_TDEST_VALS list with values starting from 1 "," is for M00_INIS
  set nmi_tdest_vals "," 
  for {set i 0} {$i < $num_high} {incr i} {
    # Format the hex value with leading zeros
    set formatted_hex [format "0x%08X" [expr {$i + 1 + 15}]]
    # Append each formatted hex value pair, separated by a comma
    append nmi_tdest_vals "$formatted_hex $formatted_hex"
    
    # Add a comma separator after each pair, except the last one
    if { $i < $num_high - 1 } {
      append nmi_tdest_vals ","
    }
  }

  # Set the NMI_TDEST_VALS property on the axis_noc_high instance with quotes
  set_property -dict [list CONFIG.NMI_TDEST_VALS "$nmi_tdest_vals"] [get_bd_cells /RP${RP_number}/${nameHier}/axis_noc_high]

  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
  ] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_high/aclk0]

###########################################################################################################################################################################  

  # Create instance: dfx_decoupler_0 and set properties
  set dfx_decoupler_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 /RP${RP_number}/${nameHier}/dfx_decoupler_0]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_AXI_LITE 0 HAS_SIGNAL_CONTROL 1 HAS_SIGNAL_STATUS 0 INTF {sout2rp2n {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 REGISTER 1 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 1 WIDTH 1} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 1 WIDTH 16} TKEEP {PRESENT 1 WIDTH 16}}} n2rp2sin {ID 1 MODE slave VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 0 WIDTH 0} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 0 WIDTH 16} TKEEP {PRESENT 1 WIDTH 16}} REGISTER 1}}} \
    CONFIG.GUI_SELECT_INTERFACE {0} \
    CONFIG.GUI_SELECT_MODE {master} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
    CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
  ] $dfx_decoupler_0

  # Create ctr and clk pins
  create_bd_pin -dir I -type clk /RP${RP_number}/${nameHier}/rp_clk
  create_bd_pin -dir I -type rst /RP${RP_number}/${nameHier}/rp_arstn
  create_bd_pin -dir I /RP${RP_number}/${nameHier}/rp_decouple

  # Loop to create and connect master and slave INIS pins for axis_noc based on num_nmi
  for {set i 0} {$i < $num_low} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index0 [format "%02d" $i]
    set formatted_index1 [format "%02d" [expr {$i + 1}]]
    set master_inis_pin "M${formatted_index1}_INIS"
    set slave_inis_pin_intern "S${formatted_index0}_INIS"
    set slave_inis_pin_extern "S${formatted_index1}_INIS"

    # Create master and slave INIS interface pins dynamically
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${RP_number}/${nameHier}/$master_inis_pin
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${RP_number}/${nameHier}/$slave_inis_pin_extern
    
    # Connect each master INIS pin to the corresponding axis_noc master interface pin
    set master_intf_net "axis_noc_low_${master_inis_pin}_conn"
    connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/${master_inis_pin}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/$master_inis_pin]

    # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
    set slave_intf_net "axis_noc_low_${slave_inis_pin_extern}_conn"
    connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/${slave_inis_pin_intern}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/$slave_inis_pin_extern]
  }
  for {set i 0} {$i < $num_high} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index0 [format "%02d" $i]
    set formatted_index1 [format "%02d" [expr {$i + 1}]]
    set formatted_index15 [format "%02d" [expr {$i + 1 + 15}]]

    set master_inis_pin_intern "M${formatted_index1}_INIS"
    set master_inis_pin_extern "M${formatted_index15}_INIS"
    set slave_inis_pin_intern "S${formatted_index0}_INIS"
    set slave_inis_pin_extern "S${formatted_index15}_INIS"

    # Create master and slave INIS interface pins dynamically
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${RP_number}/${nameHier}/$master_inis_pin_extern
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${RP_number}/${nameHier}/$slave_inis_pin_extern
    
    # Connect each master INIS pin to the corresponding axis_noc master interface pin
    set master_intf_net "axis_noc_high_${master_inis_pin_intern}_conn"
    connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/${master_inis_pin_intern}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/$master_inis_pin_extern]

    # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
    set slave_intf_net "axis_noc_high_${slave_inis_pin_extern}_conn"
    connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/${slave_inis_pin_intern}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/$slave_inis_pin_extern]
  }

  # connect axis_switch_outputMux to axis_noc_low
  connect_bd_intf_net -intf_net axis_switch2low [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/M00_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/S00_AXIS]
  # connect axis_noc_low to axis_noc_inputMux
  connect_bd_intf_net -intf_net axis_low2noc [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/M00_INIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/S00_INIS]

  # connect axis_switch_outputMux to axis_noc_high
  connect_bd_intf_net -intf_net axis_switch2high [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/M01_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/S00_AXIS]
  # connect axis_noc_high to axis_noc_inputMux
  connect_bd_intf_net -intf_net axis_high2noc [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/M00_INIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/S01_INIS]

  # connect switch and noc to decoupler rp_dfx
  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/rp_sout2rp2n
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/rp_n2rp2sin
  #connect path of input stream
  connect_bd_intf_net -intf_net n2dcp [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/M00_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/s_n2rp2sin]
  connect_bd_intf_net -intf_net dcp2dfx [get_bd_intf_pins /RP${RP_number}/${nameHier}/rp_n2rp2sin] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/rp_n2rp2sin]
  #connect path of output stream
  connect_bd_intf_net -intf_net dcp2n [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/s_sout2rp2n] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/S00_AXIS]
  connect_bd_intf_net -intf_net dcp2dfx2 [get_bd_intf_pins /RP${RP_number}/${nameHier}/rp_sout2rp2n] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/rp_sout2rp2n]

  # Connect ctr and clk pins 
  connect_bd_net -net clk [get_bd_pins /RP${RP_number}/${nameHier}/rp_clk] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/sout2rp2n_aclk] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/n2rp2sin_aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_low/aclk0] [get_bd_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/aclk0] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_high/aclk0]
  connect_bd_net -net aresetn [get_bd_pins /RP${RP_number}/${nameHier}/rp_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/sout2rp2n_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/n2rp2sin_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/aresetn]
  connect_bd_net -net decouple [get_bd_pins /RP${RP_number}/${nameHier}/rp_decouple] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/decouple]

}

proc create_hier_cell_RP_DFX { nameHier RP_number } {

  if { $nameHier eq "" || $RP_number eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1_Static() - Empty argument(s)!"}
     return
  }

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier /RP${RP_number}/$nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 /RP${RP_number}/${nameHier}/M00_INI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 /RP${RP_number}/${nameHier}/S00_INI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/input_stream
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/output_stream

  # Create pins
  create_bd_pin -dir I -type clk /RP${RP_number}/${nameHier}/aclk
  create_bd_pin -dir I -type rst /RP${RP_number}/${nameHier}/aresetn

  # Create instance: rmBase_0, and set properties
  set rmBase_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:rmBase:1.1 /RP${RP_number}/${nameHier}/rmBase_0 ]

###########################################################################################################################################################################  

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 /RP${RP_number}/${nameHier}/axi_noc_0 ]
  set_property -dict [list \
    CONFIG.MI_NAMES {} \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {1} \
  ] $axi_noc_0

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_8000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI} \
 ] [get_bd_pins /RP${RP_number}/${nameHier}/axi_noc_0/aclk0]

###########################################################################################################################################################################  

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 /RP${RP_number}/${nameHier}/smartconnect_0 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins /RP${RP_number}/${nameHier}/rmBase_0/input_stream] [get_bd_intf_pins /RP${RP_number}/${nameHier}/input_stream]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins /RP${RP_number}/${nameHier}/rmBase_0/output_stream] [get_bd_intf_pins /RP${RP_number}/${nameHier}/output_stream]
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_pins /RP${RP_number}/${nameHier}/S00_INI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins /RP${RP_number}/${nameHier}/smartconnect_0/S00_AXI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_INI [get_bd_intf_pins /RP${RP_number}/${nameHier}/M00_INI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net rmBase_0_m_axi_DATA_BUS_ADDR [get_bd_intf_pins /RP${RP_number}/${nameHier}/rmBase_0/m_axi_DATA_BUS_ADDR] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins /RP${RP_number}/${nameHier}/smartconnect_0/M00_AXI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/rmBase_0/s_axi_CTRL_BUS]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins /RP${RP_number}/${nameHier}/aclk] [get_bd_pins /RP${RP_number}/${nameHier}/smartconnect_0/aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axi_noc_0/aclk0] [get_bd_pins /RP${RP_number}/${nameHier}/rmBase_0/ap_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins /RP${RP_number}/${nameHier}/aresetn] [get_bd_pins /RP${RP_number}/${nameHier}/smartconnect_0/aresetn] [get_bd_pins /RP${RP_number}/${nameHier}/rmBase_0/ap_rst_n]

}

proc create_hier_cell_RPtop { nameHier RP_number } {

  if { $nameHier eq "" || $RP_number eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP() - Empty argument(s)!"}
     return
  }

  set RPname "${nameHier}${RP_number}"

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier /$RPname]

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 /$RPname/M00_INI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 /$RPname/S00_INI

  # Create interface pins based on RP_number
  for {set i 0} {$i < ($RP_number - 1)} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index [format "%02d" [expr {$i + 1}]]
    set master_inis_pin "M${formatted_index}_INIS"
    set slave_inis_pin "S${formatted_index}_INIS"

    # Create master and slave INIS interface pins dynamically
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /$RPname/$master_inis_pin
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /$RPname/$slave_inis_pin
  }

  # Create pins
  create_bd_pin -dir I -type clk /$RPname/aclk
  create_bd_pin -dir I -type rst /$RPname/aresetn
  create_bd_pin -dir I /$RPname/decouple

###########################################################################################################################################################################    

  set RPStaticName "RP${RP_number}_static"
  create_hier_cell_RP_Static $RPStaticName $RP_number

###########################################################################################################################################################################  

  #Loop to create and connect master and slave INIS pins for top level based on RP_number
  for {set i 0} {$i < ($RP_number - 1)} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index [format "%02d" [expr {$i + 1}]]
    set master_inis_pin "M${formatted_index}_INIS"
    set slave_inis_pin "S${formatted_index}_INIS"

    # Connect each master INIS pin to the corresponding axis_noc master interface pin
    set master_intf_net "static_${master_inis_pin}_conn"
    connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /$RPname/$RPStaticName/${master_inis_pin}] [get_bd_intf_pins /$RPname/$master_inis_pin]

    # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
    set slave_intf_net "static_${slave_inis_pin}_conn"
    connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /$RPname/$RPStaticName/${slave_inis_pin}] [get_bd_intf_pins /$RPname/$slave_inis_pin]
  }

  # Connect decouple pins 
  connect_bd_net -net decouple [get_bd_pins /$RPname/decouple] [get_bd_pins /$RPname/$RPStaticName/rp_decouple] 

###########################################################################################################################################################################  

  set RPDFXName "RP${RP_number}_DFX"
  create_hier_cell_RP_DFX $RPDFXName $RP_number

###########################################################################################################################################################################  

  connect_bd_intf_net -intf_net S00_INI [get_bd_intf_pins /$RPname/S00_INI] [get_bd_intf_pins /$RPname/$RPDFXName/S00_INI]
  connect_bd_intf_net -intf_net M00_INI [get_bd_intf_pins /$RPname/M00_INI] [get_bd_intf_pins /$RPname/$RPDFXName/M00_INI]

  connect_bd_intf_net -intf_net input_dfx2static [get_bd_intf_pins /$RPname/$RPStaticName/rp_n2rp2sin] [get_bd_intf_pins /$RPname/$RPDFXName/input_stream]
  connect_bd_intf_net -intf_net output_dfx2static [get_bd_intf_pins /$RPname/$RPStaticName/rp_sout2rp2n] [get_bd_intf_pins /$RPname/$RPDFXName/output_stream]

  # Connect clk and reset pins 
  connect_bd_net -net clk [get_bd_pins /$RPname/aclk] [get_bd_pins /$RPname/$RPStaticName/rp_clk] [get_bd_pins /$RPname/$RPDFXName/aclk] 
  connect_bd_net -net aresetn [get_bd_pins /$RPname/aresetn] [get_bd_pins /$RPname/$RPStaticName/rp_arstn] [get_bd_pins /$RPname/$RPDFXName/aresetn] 
}

create_hier_cell_RPtop RP 1