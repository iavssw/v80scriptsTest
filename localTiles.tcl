proc createLocalRPStatic {parentName nameHier RP_number } {

  if { $parentName eq "" || $nameHier eq "" || $RP_number eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1_Static() - Empty argument(s)!"}
     return
  }

  # # Create Static Hierarchical cell
  set hier_obj [create_bd_cell -type hier /${parentName}/$nameHier]

  # Check if RP_number is within the allowed range
  if { $RP_number < 1 || $RP_number > 15 } {
      puts "ERROR: RP_number must be between 1 and 31."
      return
  }

  # Calculate the number of NMIs as one less than RP_number - 4 for local tile offset + 3 for local tiles
  set num_nmi [expr {$RP_number - 1}]

  puts "Static Main NUM_NMI: $num_nmi"
  
###########################################################################################################################################################################

  # Create instance: axis_noc_0
  set axis_noc [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 /${parentName}/${nameHier}/axis_noc]
  
  # Set properties on the axis_noc_0 instance
  # tdest width is hardcoded to 4 for the ip version 2024.1 will not pass DRC if changed
  set_property -dict [list \
    CONFIG.NUM_NMI $num_nmi \
    CONFIG.NUM_NSI $num_nmi \
    CONFIG.SI_DESTID_PINS {1} \
    CONFIG.TDEST_WIDTH {4} \
  ] $axis_noc

  set_property -dict [ list \
    CONFIG.TDEST_WIDTH {4} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /${parentName}/${nameHier}/axis_noc/M00_AXIS]

  set_property -dict [ list \
    CONFIG.TDEST_WIDTH {4} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /${parentName}/${nameHier}/axis_noc/S00_AXIS]

  # Initialize an empty string for the nested CONFIG.CONNECTIONS structure
  set connections_axis_list ""
  # Loop to build the nested CONNECTIONS list based on num_nmi
  for {set i 0} {$i < $num_nmi} {incr i} {
    # Format the index to always be two digits
    set formatted_index [format "%02d" $i]
    # Append each INIS connection in a nested format with bandwidth settings
    append connections_axis_list "M${formatted_index}_INIS { write_bw {500}} "
  }
  # Apply the dynamically created CONNECTIONS list to the S00_AXIS interface
  set_property -dict [list CONFIG.CONNECTIONS $connections_axis_list] [get_bd_intf_pins /${parentName}/${nameHier}/axis_noc/S00_AXIS]

  # Loop to set the CONNECTIONS for each SINIS interface to the M_AXIS
  for {set i 0} {$i < $num_nmi} {incr i} {
    # Format the index to always be two digits
    set formatted_index [format "%02d" $i]
    # Set the CONNECTIONS for each SINIS interface to the M_AXIS
    set_property -dict [list CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}}] [get_bd_intf_pins /${parentName}/${nameHier}/axis_noc/S${formatted_index}_INIS]
  }

  # Initialize the NMI_TDEST_VALS list with values starting from 5 for global routing
  set nmi_tdest_vals ""
  for {set i 0} {$i < $num_nmi} {incr i} {
    # Format the hex value with leading zeros
    set formatted_hex [format "0x%08X" [expr {$i + 1}]]
    # Append each formatted hex value pair, separated by a comma
    append nmi_tdest_vals "$formatted_hex $formatted_hex"
    
    # Add a comma separator after each pair, except the last one
    if { $i < $num_nmi - 1 } {
      append nmi_tdest_vals ","
    }
  }

  # Set the NMI_TDEST_VALS property on the axis_noc_0 instance with quotes
  set_property -dict [list CONFIG.NMI_TDEST_VALS "$nmi_tdest_vals"] [get_bd_cells /${parentName}/${nameHier}/axis_noc]

  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {M00_AXIS:S00_AXIS} \
  ] [get_bd_pins /${parentName}/${nameHier}/axis_noc/aclk0]

###########################################################################################################################################################################

  # Create instance: dfx_decoupler_0 and set properties
  set dfx_decoupler_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 /${parentName}/${nameHier}/dfx_decoupler_0]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_AXI_LITE 0 HAS_SIGNAL_CONTROL 1 HAS_SIGNAL_STATUS 0 INTF {sout2rp2n {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 REGISTER 1 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 1 WIDTH 1} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 1 WIDTH 16} TKEEP {PRESENT 1 WIDTH 16}}} n2rp2sin {ID 1 MODE slave VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 0 WIDTH 0} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 0 WIDTH 16} TKEEP {PRESENT 1 WIDTH 16}} REGISTER 1}}} \
    CONFIG.GUI_SELECT_INTERFACE {0} \
    CONFIG.GUI_SELECT_MODE {master} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
    CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
  ] $dfx_decoupler_0

  # Create ctr and clk pins
  create_bd_pin -dir I -type clk /${parentName}/${nameHier}/rp_clk
  create_bd_pin -dir I -type rst /${parentName}/${nameHier}/rp_arstn
  create_bd_pin -dir I /${parentName}/${nameHier}/rp_decouple

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

#   # connect axis_switch_outputMux to axis_noc_low
#   connect_bd_intf_net -intf_net axis_switch2low [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/M00_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/S00_AXIS]
#   # connect axis_noc_low to axis_noc_inputMux
#   connect_bd_intf_net -intf_net axis_low2noc [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_low/M00_INIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/S00_INIS]

#   # connect axis_switch_outputMux to axis_noc_high
#   connect_bd_intf_net -intf_net axis_switch2high [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/M01_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/S00_AXIS]
#   # connect axis_noc_high to axis_noc_inputMux
#   connect_bd_intf_net -intf_net axis_high2noc [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_high/M00_INIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/S01_INIS]

#   # connect switch and noc to decoupler rp_dfx
#   # Create interface pins
#   create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/rp_sout2rp2n
#   create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/rp_n2rp2sin
#   #connect path of input stream
#   connect_bd_intf_net -intf_net n2dcp [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/M00_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/s_n2rp2sin]
#   connect_bd_intf_net -intf_net dcp2dfx [get_bd_intf_pins /RP${RP_number}/${nameHier}/rp_n2rp2sin] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/rp_n2rp2sin]
#   #connect path of output stream
#   connect_bd_intf_net -intf_net dcp2n [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/s_sout2rp2n] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/S00_AXIS]
#   connect_bd_intf_net -intf_net dcp2dfx2 [get_bd_intf_pins /RP${RP_number}/${nameHier}/rp_sout2rp2n] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/rp_sout2rp2n]

#   # Connect ctr and clk pins 
#   connect_bd_net -net clk [get_bd_pins /RP${RP_number}/${nameHier}/rp_clk] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/sout2rp2n_aclk] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/n2rp2sin_aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_low/aclk0] [get_bd_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_inputMux/aclk0] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_high/aclk0]
#   connect_bd_net -net aresetn [get_bd_pins /RP${RP_number}/${nameHier}/rp_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/sout2rp2n_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/n2rp2sin_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/axis_switch_outputMux/aresetn]
#   connect_bd_net -net decouple [get_bd_pins /RP${RP_number}/${nameHier}/rp_decouple] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/decouple]

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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 /RP${RP_number}/${nameHier}/M00_DFX_INI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 /RP${RP_number}/${nameHier}/S00_DFX_INI
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
  connect_bd_intf_net -intf_net axi_noc_0_S00_AXI [get_bd_intf_pins /RP${RP_number}/${nameHier}/smartconnect_0/S00_AXI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_S00_DFX_INI [get_bd_intf_pins /RP${RP_number}/${nameHier}/S00_DFX_INI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_DFX_INI [get_bd_intf_pins /RP${RP_number}/${nameHier}/M00_DFX_INI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net rmBase_0_m_axi_DATA_BUS_ADDR [get_bd_intf_pins /RP${RP_number}/${nameHier}/rmBase_0/m_axi_DATA_BUS_ADDR] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axi_noc_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins /RP${RP_number}/${nameHier}/smartconnect_0/M00_AXI] [get_bd_intf_pins /RP${RP_number}/${nameHier}/rmBase_0/s_axi_CTRL_BUS]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins /RP${RP_number}/${nameHier}/aclk] [get_bd_pins /RP${RP_number}/${nameHier}/smartconnect_0/aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axi_noc_0/aclk0] [get_bd_pins /RP${RP_number}/${nameHier}/rmBase_0/ap_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins /RP${RP_number}/${nameHier}/aresetn] [get_bd_pins /RP${RP_number}/${nameHier}/smartconnect_0/aresetn] [get_bd_pins /RP${RP_number}/${nameHier}/rmBase_0/ap_rst_n]

}

proc createLocalTop { SLR_number RP_number } {

  if { $SLR_number eq "" || $RP_number eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP() - Empty argument(s)!"}
    return
  }

  # RP name
  set RPname "SLR${SLR_number}_RPL${RP_number}"

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier /$RPname]

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 /$RPname/SLR${SLR_number}_M00_DFX_INI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 /$RPname/SLR${SLR_number}_S00_DFX_INI

  # Create interface pins based on RP_number + offset for local tiles
  for {set i 0} {$i < ($RP_number - 1)} {incr i} {
    # Format pin names dynamically based on index + offset  
    set formatted_index [format "%02d" [expr {$i + 1}]]
    set master_inis_pin "SLR${SLR_number}_M${formatted_index}_INIS"
    set slave_inis_pin "SLR${SLR_number}_S${formatted_index}_INIS"

    # Create master and slave INIS interface pins dynamically
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /$RPname/$master_inis_pin
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /$RPname/$slave_inis_pin
  }

  # Create pins
  create_bd_pin -dir I -type clk /$RPname/aclk
  create_bd_pin -dir I -type rst /$RPname/aresetn
  create_bd_pin -dir I /$RPname/decouple

###########################################################################################################################################################################    

  set RPStaticName "RPL${RP_number}_static"
  createLocalRPStatic $RPname $RPStaticName $RP_number

###########################################################################################################################################################################  

#   #Loop to create and connect master and slave INIS pins for top level based on RP_number
#   for {set i 0} {$i < ($RP_number - 1)} {incr i} {
#     # Format pin names dynamically based on index
#     set formatted_index [format "%02d" [expr {$i + 1}]]
#     set master_inis_pin "M${formatted_index}_INIS"
#     set slave_inis_pin "S${formatted_index}_INIS"

#     # Connect each master INIS pin to the corresponding axis_noc master interface pin
#     set master_intf_net "static_${master_inis_pin}_conn"
#     connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /$RPname/$RPStaticName/${master_inis_pin}] [get_bd_intf_pins /$RPname/$master_inis_pin]

#     # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
#     set slave_intf_net "static_${slave_inis_pin}_conn"
#     connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /$RPname/$RPStaticName/${slave_inis_pin}] [get_bd_intf_pins /$RPname/$slave_inis_pin]
#   }

#   # Connect decouple pins 
#   connect_bd_net -net decouple [get_bd_pins /$RPname/decouple] [get_bd_pins /$RPname/$RPStaticName/rp_decouple] 

# ###########################################################################################################################################################################  

#   set RPDFXName "RP${RP_number}_DFX"
#   create_hier_cell_RP_DFX $RPDFXName $RP_number

# ###########################################################################################################################################################################  

#   connect_bd_intf_net -intf_net S00_DFX_INI [get_bd_intf_pins /$RPname/S00_DFX_INI] [get_bd_intf_pins /$RPname/$RPDFXName/S00_DFX_INI]
#   connect_bd_intf_net -intf_net M00_DFX_INI [get_bd_intf_pins /$RPname/M00_DFX_INI] [get_bd_intf_pins /$RPname/$RPDFXName/M00_DFX_INI]

#   connect_bd_intf_net -intf_net input_dfx2static [get_bd_intf_pins /$RPname/$RPStaticName/rp_n2rp2sin] [get_bd_intf_pins /$RPname/$RPDFXName/input_stream]
#   connect_bd_intf_net -intf_net output_dfx2static [get_bd_intf_pins /$RPname/$RPStaticName/rp_sout2rp2n] [get_bd_intf_pins /$RPname/$RPDFXName/output_stream]

#   # Connect clk and reset pins 
#   connect_bd_net -net clk [get_bd_pins /$RPname/aclk] [get_bd_pins /$RPname/$RPStaticName/rp_clk] [get_bd_pins /$RPname/$RPDFXName/aclk] 
#   connect_bd_net -net aresetn [get_bd_pins /$RPname/aresetn] [get_bd_pins /$RPname/$RPStaticName/rp_arstn] [get_bd_pins /$RPname/$RPDFXName/aresetn] 
}

proc updateStaticRegion { nameHier RP_number } {

  if { $nameHier eq "" || $RP_number eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP() - Empty argument(s)!"}
    return
  }

  set RPname "${nameHier}${RP_number}"

  ###########################################################################################################################################################################  

  # Retrieve the object for the axi_noc_cips instance
  set axi_noc_cips [get_bd_cells /static_region/axi_noc_cips]

  # Check if the object was found
  if { $axi_noc_cips eq "" } {
    puts "ERROR: Could not find the object /static_region/axi_noc_cips."
    return
  }

  # Query the current values of NUM_NMI and NUM_NSI
  set current_num_nmi [get_property CONFIG.NUM_NMI $axi_noc_cips]
  set current_num_nsi [get_property CONFIG.NUM_NSI $axi_noc_cips]

  # Increment each value by 1
  set new_num_nmi [expr {$current_num_nmi + 1}]
  set new_num_nsi [expr {$current_num_nsi + 1}]

  puts "Static Main Current NUM_NMI: $current_num_nmi, Current NUM_NSI: $current_num_nsi"

  # Apply the updated configuration with incremented values using -dict
  set_property -dict [list \
    CONFIG.NUM_NMI $new_num_nmi \
    CONFIG.NUM_NSI $new_num_nsi \
  ] $axi_noc_cips

  # Format the number with zero-padding for zero index
  set formatted_index1 [format "%02d" [expr {$new_num_nmi - 1}]]
  set MINI_name "M${formatted_index1}_INI"
  
  # Query the existing connections
  set current_connections00 [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /static_region/axi_noc_cips/S00_AXI]]
  set current_connections01 [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /static_region/axi_noc_cips/S01_AXI]]
  # Append the new connection to the existing connections
  lappend current_connections00 $MINI_name {read_bw {5} write_bw {5}}
  lappend current_connections01 $MINI_name {read_bw {5} write_bw {5}}

  # Set connections from CIPS to the new MINI ctrl
  set_property -dict [list CONFIG.CONNECTIONS $current_connections00] [get_bd_intf_pins /static_region/axi_noc_cips/S00_AXI]
  set_property -dict [list CONFIG.CONNECTIONS $current_connections01] [get_bd_intf_pins /static_region/axi_noc_cips/S01_AXI]

  # Format the number with zero-padding for zero index
  set formatted_index2 [format "%02d" [expr {$new_num_nsi - 1}]]
  set SINI_name "S${formatted_index2}_INI"

  # connect to DDR with 500MB bandwidth for HBM modify here
  set_property -dict [list CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M00_INI {read_bw {500} write_bw {500}}}] [get_bd_intf_pins /static_region/axi_noc_cips/$SINI_name]

  # ###########################################################################################################################################################################  

  set formatted_index_dfx [format "%02d" $RP_number]
  set master_inis_pin_extern "M${formatted_index_dfx}_DFX_INI"
  set slave_inis_pin_extern "S${formatted_index_dfx}_DFX_INI"

  # Create master and slave INIS interface pins dynamically
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 /static_region/$master_inis_pin_extern
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 /static_region/$slave_inis_pin_extern

  # Connect each master INIS pin to the corresponding axis_noc master interface pin
  connect_bd_intf_net -intf_net "M_noc_cips2block_${RP_number}" [get_bd_intf_pins /static_region/axi_noc_cips/${MINI_name}] [get_bd_intf_pins /static_region/$master_inis_pin_extern]
  # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
  connect_bd_intf_net -intf_net "S_noc_cips2block_${RP_number}" [get_bd_intf_pins /static_region/axi_noc_cips/${SINI_name}] [get_bd_intf_pins /static_region/$slave_inis_pin_extern]

  ###########################################################################################################################################################################  

  # Create instance: RP2, and set properties
  set RP_Slice "${nameHier}${RP_number}_slice"
  set $RP_Slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 /static_region/$RP_Slice ]  
  set_property CONFIG.DIN_TO $RP_number [get_bd_cells /static_region/$RP_Slice]

  # Create interface pins
  connect_bd_net [get_bd_pins /static_region/$RP_Slice/Din] [get_bd_pins /static_region/axi_decoupler/gpio_io_o]

  # Create pins externally from static region
  set RP_Slice_dcpl "${nameHier}${RP_number}_dcpl"
  create_bd_pin -dir O -from 0 -to 0 /static_region/$RP_Slice_dcpl

  # Connect decouple pins
  connect_bd_net -net "decouple_${RP_number}" [get_bd_pins /static_region/$RP_Slice/Dout] [get_bd_pins /static_region/$RP_Slice_dcpl]

}

proc updateRPregions { nameHier RP_number } {
  if { $nameHier eq "" || $RP_number eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP() - Empty argument(s)!"}
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

  #do not update the the RP just created
  for {set i 1} {$i < $RP_number} {incr i} {
  # for {set i 17} {$i < 18} {incr i}
    puts "Updating RP Static Region $i"

    #update low for lower half of RP
    if { $RP_number < 17 } {
      set current_low_num_nmi [get_property CONFIG.NUM_NMI [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_low]]
      set current_low_num_nsi [get_property CONFIG.NUM_NSI [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_low]]      

      set new_low_num_nmi [expr {$current_low_num_nmi + 1}]
      set new_low_num_nsi [expr {$current_low_num_nsi + 1}]

      #safty check
      if {($new_low_num_nmi < 17) && ($new_low_num_nsi < 17) || 1} {
        # puts "Current Low NUM_NMI: $current_low_num_nmi, Current Low NUM_NSI: $current_low_num_nsi"
        # puts "New Low NUM_NMI: $new_low_num_nmi, New Low NUM_NSI: $new_low_num_nsi"

        # Apply the updated configuration with incremented values using -dict
        set_property -dict [list \
          CONFIG.NUM_NMI $new_low_num_nmi \
          CONFIG.NUM_NSI $new_low_num_nsi \
        ] [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_low]        

        # output steam: Format the number with zero-padding for zero index
        set formatted_indexM [format "%02d" [expr {$new_low_num_nmi - 1}]]
        set MINIS_name "M${formatted_indexM}_INIS"
        set current_connectionsS [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_low/S00_AXIS]]
        lappend current_connectionsS $MINIS_name {read_bw {500} write_bw {500}}
        set_property -dict [list CONFIG.CONNECTIONS $current_connectionsS] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_low/S00_AXIS]
        
        # input stream: Format the number with zero-padding for zero index
        set formatted_indexS [format "%02d" [expr {$new_low_num_nsi - 1}]]
        set SINIS_name "S${formatted_indexS}_INIS"
        set_property -dict [list CONFIG.CONNECTIONS {M00_INIS { write_bw {500} }}] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_low/$SINIS_name] 

        # Initialize the NMI_TDEST_VALS list with values starting from 1 "," is for M00_INIS
        set nmi_tdest_vals "," 
        # +1 to skip itself
        set skip 0
        if {$i < 17} {
          set skip 1
        }
        # +1 to start from 1
        for {set j 1} {$j < ($num_low + $skip + 1)} {incr j} {
          # skip itself
          if { $j != $i} {
            # Format the hex value with leading zeros
            set formatted_hex [format "0x%08X" [expr {$j}]]

            # Append each formatted hex value pair, separated by a comma
            append nmi_tdest_vals "$formatted_hex $formatted_hex"

            # Add a comma separator after each pair, except the last one
            if { $j < ($num_low + $skip) } {
              append nmi_tdest_vals ","
            }
          }
        }
        # puts "L NMI_TDEST_VALS: $nmi_tdest_vals"
        # Set the NMI_TDEST_VALS property on the axis_noc_high instance with quotes
        set_property -dict [list CONFIG.NMI_TDEST_VALS "$nmi_tdest_vals"] [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_low]

        # Format pin names dynamically based on index
        set formatted_indexM [format "%02d" [expr {$new_low_num_nmi - 1}]]
        set formatted_indexS [format "%02d" [expr {$new_low_num_nsi - 1}]]
        set formatted_indexOut [format "%02d" $RP_number]
        set master_inis_pin_intern "M${formatted_indexM}_INIS"
        set slave_inis_pin_intern "S${formatted_indexS}_INIS"
        set master_inis_pin_extern "M${formatted_indexOut}_INIS"
        set slave_inis_pin_extern "S${formatted_indexOut}_INIS"

        puts "$master_inis_pin_intern $slave_inis_pin_intern"
        puts "$master_inis_pin_extern $slave_inis_pin_extern"

        create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/${nameHier}${i}_static/$master_inis_pin_extern
        create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/${nameHier}${i}_static/$slave_inis_pin_extern

        create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/$master_inis_pin_extern
        create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/$slave_inis_pin_extern

        set master_intf_net "axis_noc_low_${master_inis_pin_extern}_conn"
        connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_low/${master_inis_pin_intern}] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$master_inis_pin_extern]
        set slave_intf_net "axis_noc_low_${slave_inis_pin_extern}_conn"
        connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_low/${slave_inis_pin_intern}] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$slave_inis_pin_extern]

        set master_intf_net "axis_noc_low_${master_inis_pin_extern}_connE"
        connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$master_inis_pin_extern] [get_bd_intf_pins /RP${i}/$master_inis_pin_extern]
        set slave_intf_net "axis_noc_low_${slave_inis_pin_extern}_connE"
        connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$slave_inis_pin_extern] [get_bd_intf_pins /RP${i}/$slave_inis_pin_extern]

      } else {
        puts "ERROR: Cannot update Static Region $i Too many NMI/NSI"
        return
      }

    # update high for upper half of RP
    } else {
      set current_high_num_nmi [get_property CONFIG.NUM_NMI [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_high]]
      set current_high_num_nsi [get_property CONFIG.NUM_NSI [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_high]]

      set new_high_num_nmi [expr {$current_high_num_nmi + 1}]
      set new_high_num_nsi [expr {$current_high_num_nsi + 1}]

      #safty check
      if {($new_high_num_nmi < 17) && ($new_high_num_nmi < 17)} {
        # puts "Current High NUM_NMI: $current_high_num_nmi, Current High NUM_NSI: $current_high_num_nsi"
        # puts "New High NUM_NMI: $new_high_num_nmi, New High NUM_NSI: $new_high_num_nsi"

        # Apply the updated configuration with incremented values using -dict
        set_property -dict [list \
          CONFIG.NUM_NMI $new_high_num_nmi \
          CONFIG.NUM_NSI $new_high_num_nsi \
        ] [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_high]        

        # output steam: Format the number with zero-padding for zero index
        set formatted_indexM [format "%02d" [expr {$new_high_num_nmi - 1}]]
        set MINIS_name "M${formatted_indexM}_INIS"
        set current_connectionsS [get_property CONFIG.CONNECTIONS [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_high/S00_AXIS]]
        lappend current_connectionsS $MINIS_name {read_bw {500} write_bw {500}}
        set_property -dict [list CONFIG.CONNECTIONS $current_connectionsS] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_high/S00_AXIS]
        
        # input stream: Format the number with zero-padding for zero index
        set formatted_indexS [format "%02d" [expr {$new_high_num_nsi - 1}]]
        set SINIS_name "S${formatted_indexS}_INIS"
        set_property -dict [list CONFIG.CONNECTIONS {M00_INIS { write_bw {500} }}] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_high/$SINIS_name] 

        # Initialize the NMI_TDEST_VALS list with values starting from 1 "," is for M00_INIS
        set nmi_tdest_vals "," 
        # +1 to skip itself 
        set skip 0
        set start 16
        if {$i > 16} {
          set skip 1
        } else {
          set start 17
        }
        #+1 to start from 1
        for {set j $start} {$j < ($num_low + $num_high + 1 + 1)} {incr j} {
          # skip itself
          if { $j != $i} {
            # Format the hex value with leading zeros
            set formatted_hex [format "0x%08X" [expr {$j}]]

            # Append each formatted hex value pair, separated by a comma
            append nmi_tdest_vals "$formatted_hex $formatted_hex"

            # Add a comma separator after each pair, except the last one
            if { $j < ($num_low + $num_high + 1) } {
              append nmi_tdest_vals ","
            }
          }
        }
        # puts "H NMI_TDEST_VALS: $nmi_tdest_vals"
        # Set the NMI_TDEST_VALS property on the axis_noc_high instance with quotes
        set_property -dict [list CONFIG.NMI_TDEST_VALS "$nmi_tdest_vals"] [get_bd_cells /RP${i}/${nameHier}${i}_static/axis_noc_high]

        # Format pin names dynamically based on index
        set formatted_indexM [format "%02d" [expr {$new_high_num_nmi - 1}]]
        set formatted_indexS [format "%02d" [expr {$new_high_num_nsi - 1}]]
        set formatted_indexOut [format "%02d" $RP_number]
        set master_inis_pin_intern "M${formatted_indexM}_INIS"
        set slave_inis_pin_intern "S${formatted_indexS}_INIS"
        set master_inis_pin_extern "M${formatted_indexOut}_INIS"
        set slave_inis_pin_extern "S${formatted_indexOut}_INIS"

        puts "$master_inis_pin_intern $slave_inis_pin_intern"
        puts "$master_inis_pin_extern $slave_inis_pin_extern"

        create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/${nameHier}${i}_static/$master_inis_pin_extern
        create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/${nameHier}${i}_static/$slave_inis_pin_extern

        create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/$master_inis_pin_extern
        create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${i}/$slave_inis_pin_extern

        set master_intf_net "axis_noc_high_${master_inis_pin_extern}_conn"
        connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_high/${master_inis_pin_intern}] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$master_inis_pin_extern]
        set slave_intf_net "axis_noc_high_${slave_inis_pin_extern}_conn"
        connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/axis_noc_high/${slave_inis_pin_intern}] [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$slave_inis_pin_extern]

        set master_intf_net "axis_noc_high_${master_inis_pin_extern}_connE"
        connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$master_inis_pin_extern] [get_bd_intf_pins /RP${i}/$master_inis_pin_extern]
        set slave_intf_net "axis_noc_high_${slave_inis_pin_extern}_connE"
        connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${i}/${nameHier}${i}_static/$slave_inis_pin_extern] [get_bd_intf_pins /RP${i}/$slave_inis_pin_extern]

      } else {
        puts "ERROR: Cannot update Static Region $i Too many NMI/NSI"
        return
      }
    }
  }
}

proc connectRegions { SLR_number RP_number } {

  if { $SLR_number eq "" || $RP_number eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP() - Empty argument(s)!"}
    return
  }

  # RP name
  set RPname "SLR${SLR_number}_RP${RP_number}"

  # Names of Static Region Pins
  # INI Pins
  set formatted_index_dfx [format "%02d" $RP_number]
  set master_inis_pin_extern "M${formatted_index_dfx}_DFX_INI"
  set slave_inis_pin_extern "S${formatted_index_dfx}_DFX_INI"
  # Decouple Pins
  set RP_Slice_dcpl "${nameHier}${RP_number}_dcpl"

  # Connect Static Region to RP 
  connect_bd_intf_net -intf_net "static_region_MINI_${RP_number}" [get_bd_intf_pins /static_region/$master_inis_pin_extern] [get_bd_intf_pins /$RPname/S00_DFX_INI]
  connect_bd_intf_net -intf_net "static_region_SINI_${RP_number}" [get_bd_intf_pins /static_region/$slave_inis_pin_extern] [get_bd_intf_pins /$RPname/M00_DFX_INI]

  # decouple
  connect_bd_net -net "dcpl_${RP_number}" [get_bd_pins /static_region/$RP_Slice_dcpl] [get_bd_pins /$RPname/decouple]

  # clk and reset pins
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins /static_region/slowest_sync_clk] [get_bd_pins /$RPname/aclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins /static_region/peripheral_aresetn] [get_bd_pins /$RPname/aresetn]

  # #connect
  # for {set i 1} {$i < ($RP_number)} {incr i} {
  #   # Format pin names dynamically based on index
  #   set formatted_indexNew [format "%02d" [expr {$i}]]
  #   set formatted_indexOld [format "%02d" [expr {$RP_number}]]

  #   set master_inis_pin_new "M${formatted_indexNew}_INIS"
  #   set slave_inis_pin_new "S${formatted_indexNew}_INIS"
  #   set master_inis_pin_old "M${formatted_indexOld}_INIS"
  #   set slave_inis_pin_old "S${formatted_indexOld}_INIS"

  #   # puts "$master_inis_pin_new $slave_inis_pin_new $master_inis_pin_old $slave_inis_pin_old"

  #   connect_bd_intf_net -intf_net "stream_${RP_number}_2_${i}" [get_bd_intf_pins /$RPname/$master_inis_pin_new] [get_bd_intf_pins /${nameHier}${i}/$slave_inis_pin_old]
  #   connect_bd_intf_net -intf_net "stream_${i}_2_${RP_number}" [get_bd_intf_pins /${nameHier}${i}/$master_inis_pin_old] [get_bd_intf_pins /$RPname/$slave_inis_pin_new]
  # }
}

createLocalTop 0 3

# updateStaticRegion RP 3

# updateRPregions RP 3

# connectRegions RP 3


# # Define the range of values for RP_number (for example, 1 to 3)
# set max_value 27

# # Loop through each value and make function calls
# for {set i 1} {$i <= $max_value} {incr i} {
#     create_hier_cell_RPtop RP $i
#     updateStaticRegion RP $i
#     updateRPregions RP $i
#     connectRegions RP $i
# }


