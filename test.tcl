proc create_hier_cell_RP_Static {nameHier RP_number } {

  if { $nameHier eq "" || $RP_number eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1_Static() - Empty argument(s)!"}
     return
  }

  # # Create Static Hierarchical cell
  set hier_obj [create_bd_cell -type hier /RP${RP_number}/$nameHier]

  # Calculate the number of NMIs as one less than RP_number
  set num_nmi [expr {$RP_number - 1}]
  
  # Initialize the NMI_TDEST_VALS list with values from 2 to (num_nmi + 1)
  set nmi_tdest_vals {}
  for {set i 0} {$i < $num_nmi} {incr i} {
    lappend nmi_tdest_vals "0x0000000[expr {$i + 4}]" "0x0000000[expr {$i + 4}]"
  }
    
  # Create instance: axis_noc_0
  set axis_noc_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 /RP${RP_number}/${nameHier}/axis_noc_0]
  # Set properties on the axis_noc_0 instance
  set_property -dict [list \
    CONFIG.NUM_NMI $num_nmi \
    CONFIG.NUM_NSI $num_nmi \
    CONFIG.SI_DESTID_PINS {1} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_0

  set_property -dict [ list \
    CONFIG.TDEST_WIDTH {8} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/M00_AXIS]

  set_property -dict [ list \
    CONFIG.TDEST_WIDTH {8} \
    CONFIG.TID_WIDTH {0} \
    CONFIG.DEST_IDS {} \
    CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/S00_AXIS]

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
  set_property -dict [list CONFIG.CONNECTIONS $connections_axis_list] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/S00_AXIS]

  # Loop to set the CONNECTIONS for each SINIS interface to the M_AXIS
  for {set i 0} {$i < $num_nmi} {incr i} {
    # Format the index to always be two digits
    set formatted_index [format "%02d" $i]
    # Set the CONNECTIONS for each SINIS interface to the M_AXIS
    set_property -dict [list CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/S${formatted_index}_INIS]
  }

  # Initialize the NMI_TDEST_VALS list with values starting from 1
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
  set_property -dict [list CONFIG.NMI_TDEST_VALS "$nmi_tdest_vals"] [get_bd_cells /RP${RP_number}/${nameHier}/axis_noc_0]

  set_property -dict [list \
    CONFIG.ASSOCIATED_BUSIF {M00_AXIS:S00_AXIS} \
  ] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_0/aclk0]

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
  for {set i 0} {$i < $num_nmi} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index [format "%02d" $i]
    set master_inis_pin "M${formatted_index}_INIS"
    set slave_inis_pin "S${formatted_index}_INIS"

    # Create master and slave INIS interface pins dynamically
    create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${RP_number}/${nameHier}/$master_inis_pin
    create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 /RP${RP_number}/${nameHier}/$slave_inis_pin

    # Connect each master INIS pin to the corresponding axis_noc master interface pin
    set master_intf_net "axis_noc_0_${master_inis_pin}_conn"
    connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/${master_inis_pin}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/$master_inis_pin]

    # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
    set slave_intf_net "axis_noc_0_${slave_inis_pin}_conn"
    connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/${slave_inis_pin}] [get_bd_intf_pins /RP${RP_number}/${nameHier}/$slave_inis_pin]
  }

  # connect external to noc to decoupler to rp_dfx
  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/rp_sout2rp2n
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 /RP${RP_number}/${nameHier}/rp_n2rp2sin
  #connect path of input stream
  connect_bd_intf_net -intf_net n2dcp [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/M00_AXIS] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/s_n2rp2sin]
  connect_bd_intf_net -intf_net dcp2dfx [get_bd_intf_pins /RP${RP_number}/${nameHier}/rp_n2rp2sin] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/rp_n2rp2sin]
  #connect path of output stream
  connect_bd_intf_net -intf_net dcp2n [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/s_sout2rp2n] [get_bd_intf_pins /RP${RP_number}/${nameHier}/axis_noc_0/S00_AXIS]
  connect_bd_intf_net -intf_net dcp2dfx2 [get_bd_intf_pins /RP${RP_number}/${nameHier}/rp_sout2rp2n] [get_bd_intf_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/rp_sout2rp2n]

  # Connect ctr and clk pins 
  connect_bd_net -net clk [get_bd_pins /RP${RP_number}/${nameHier}/rp_clk] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/sout2rp2n_aclk] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/n2rp2sin_aclk] [get_bd_pins /RP${RP_number}/${nameHier}/axis_noc_0/aclk0]
  connect_bd_net -net aresetn [get_bd_pins /RP${RP_number}/${nameHier}/rp_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/sout2rp2n_arstn] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/n2rp2sin_arstn]
  connect_bd_net -net decouple [get_bd_pins /RP${RP_number}/${nameHier}/rp_decouple] [get_bd_pins /RP${RP_number}/${nameHier}/dfx_decoupler_0/decouple]

}

proc create_hier_cell_RPtop { nameHier RP_number } {

  if { $nameHier eq "" || $RP_number eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP() - Empty argument(s)!"}
     return
  }

  set RPname "${nameHier}${RP_number}"

  # # Get object for parentCell
  # set parentObj [get_bd_cells $parentCell]
  # if { $parentObj == "" } {
  #    catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
  #    return
  # }

  # # Make sure parentObj is hier blk
  # set parentType [get_property TYPE $parentObj]
  # if { $parentType ne "hier" } {
  #    catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
  #    return
  # }

  # # Save current instance; Restore later
  # set oldCurInst [current_bd_instance .]

  # Set parent object as current
  # current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier /$RPname]

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 /$RPname/M00_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 /$RPname/S00_INI

  # Create interface pins based on RP_number
  for {set i 0} {$i < ($RP_number - 1)} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index [format "%02d" $i]
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

  # Create instance: RP{RP_number}_Static
  set RPStaticName "RP${RP_number}_static"
  create_hier_cell_RP_Static $RPStaticName $RP_number

  # Loop to create and connect master and slave INIS pins for top level based on RP_number
  for {set i 0} {$i < ($RP_number - 1)} {incr i} {
    # Format pin names dynamically based on index
    set formatted_index [format "%02d" $i]
    set master_inis_pin "M${formatted_index}_INIS"
    set slave_inis_pin "S${formatted_index}_INIS"

    # Connect each master INIS pin to the corresponding axis_noc master interface pin
    set master_intf_net "static_${master_inis_pin}_conn"
    connect_bd_intf_net -intf_net $master_intf_net [get_bd_intf_pins /$RPname/$RPStaticName/${master_inis_pin}] [get_bd_intf_pins /$RPname/$master_inis_pin]

    # Connect each slave INIS pin to the corresponding axis_noc slave interface pin
    set slave_intf_net "static_${slave_inis_pin}_conn"
    connect_bd_intf_net -intf_net $slave_intf_net [get_bd_intf_pins /$RPname/$RPStaticName/${slave_inis_pin}] [get_bd_intf_pins /$RPname/$slave_inis_pin]
  }

  # Connect ctr and clk pins 
  connect_bd_net -net clk [get_bd_pins /$RPname/aclk] [get_bd_pins /$RPname/$RPStaticName/rp_clk] 
  connect_bd_net -net aresetn [get_bd_pins /$RPname/aresetn] [get_bd_pins /$RPname/$RPStaticName/rp_arstn] 
  connect_bd_net -net decouple [get_bd_pins /$RPname/decouple] [get_bd_pins /$RPname/$RPStaticName/rp_decouple] 

  # # Create instance: RP{RP_number}_DFX
  # create_hier_cell_RP_DFX $hier_obj RP${RP_number}_DFX $RP_number

  # Create interface connections
  # connect_bd_intf_net -intf_net RP${RP_number}_Static_M00_INIS [get_bd_intf_pins M00_INIS] [get_bd_intf_pins RP${RP_number}_Static/M00_INIS]
  # connect_bd_intf_net -intf_net S00_INIS_${RP_number} [get_bd_intf_pins S00_INIS] [get_bd_intf_pins RP${RP_number}_Static/S00_INIS]
  # connect_bd_intf_net -intf_net S00_INI_${RP_number} [get_bd_intf_pins S00_INI] [get_bd_intf_pins RP${RP_number}_DFX/S00_INI]
  # connect_bd_intf_net -intf_net dfx_decoupler_${RP_number}_rp_n2rp_s [get_bd_intf_pins RP${RP_number}_Static/rp_n2rp_s] [get_bd_intf_pins RP${RP_number}_DFX/input_stream]
  # connect_bd_intf_net -intf_net tile${RP_number}_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins RP${RP_number}_DFX/M00_INI]
  # connect_bd_intf_net -intf_net tile${RP_number}_output_stream [get_bd_intf_pins RP${RP_number}_Static/rp_rp2n_m] [get_bd_intf_pins RP${RP_number}_DFX/output_stream]

  # # Create port connections
  # connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins aclk] [get_bd_pins RP${RP_number}_DFX/aclk] [get_bd_pins RP${RP_number}_Static/rp2n_m_aclk]
  # connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins RP${RP_number}_DFX/aresetn] [get_bd_pins RP${RP_number}_Static/n2rp_s_arstn]
  # connect_bd_net -net static_region_Dout [get_bd_pins decouple] [get_bd_pins RP${RP_number}_Static/decouple]

  # # Restore current instance
  # current_bd_instance $oldCurInst
}

create_hier_cell_RPtop RP 27 