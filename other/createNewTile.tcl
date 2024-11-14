# Hierarchical cell: RP1_DFX
proc create_hier_cell_RP1_DFX { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1_DFX() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 input_stream

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 output_stream


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn

  # Create instance: rmBase_0, and set properties
  set rmBase_0 [ create_bd_cell -type ip -vlnv xilinx.com:hls:rmBase:1.1 rmBase_0 ]

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0 ]
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
 ] [get_bd_intf_pins /RP1/RP1_DFX/axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP1/RP1_DFX/axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /RP1/RP1_DFX/axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI} \
 ] [get_bd_pins /RP1/RP1_DFX/axi_noc_0/aclk0]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins rmBase_0/input_stream] [get_bd_intf_pins input_stream]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins rmBase_0/output_stream] [get_bd_intf_pins output_stream]
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_pins S00_INI] [get_bd_intf_pins axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net rmBase_0_m_axi_DATA_BUS_ADDR [get_bd_intf_pins rmBase_0/m_axi_DATA_BUS_ADDR] [get_bd_intf_pins axi_noc_0/S00_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins rmBase_0/s_axi_CTRL_BUS]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins aclk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins axi_noc_0/aclk0] [get_bd_pins rmBase_0/ap_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins rmBase_0/ap_rst_n]

  # Restore current instance
  current_bd_instance $oldCurInst
}



# Hierarchical cell: RP1_static
proc create_hier_cell_RP1_static { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1_static() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 rp_rp2n_m

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 rp_n2rp_s

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S00_INIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M01_INIS


  # Create pins
  create_bd_pin -dir I -type clk rp2n_m_aclk
  create_bd_pin -dir I -type rst n2rp_s_arstn
  create_bd_pin -dir I decouple

  # Create instance: axis_noc_low, and set properties
  set axis_noc_low [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 axis_noc_low ]
  set_property -dict [list \
    CONFIG.NMI_TDEST_VALS {,} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_NSI {1} \
    CONFIG.SI_DESTID_PINS {} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_low


  set_property -dict [ list \
   CONFIG.TDEST_WIDTH {8} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.CONNECTIONS {M01_INIS { write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP1/RP1_static/axis_noc_low/S00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INIS { write_bw {0}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP1/RP1_static/axis_noc_low/S00_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
 ] [get_bd_pins /RP1/RP1_static/axis_noc_low/aclk0]

  # Create instance: dfx_decoupler_0, and set properties
  set dfx_decoupler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler_0 ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_AXI_LITE 0 HAS_SIGNAL_CONTROL 1 HAS_SIGNAL_STATUS 0 INTF {rp2n_m {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 REGISTER 1 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST\
{DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 1 WIDTH 1} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 1 WIDTH 16} TKEEP {PRESENT\
1 WIDTH 16}}} n2rp_s {ID 1 MODE slave VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT\
1 WIDTH 1} TUSER {PRESENT 0 WIDTH 0} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 16} TKEEP {PRESENT 1 WIDTH 16}} REGISTER 1}}} \
    CONFIG.GUI_INTERFACE_NAME {rp2n_m} \
    CONFIG.GUI_SELECT_INTERFACE {0} \
    CONFIG.GUI_SELECT_MODE {master} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
    CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
  ] $dfx_decoupler_0


  # Create instance: axis_noc_high, and set properties
  set axis_noc_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 axis_noc_high ]
  set_property -dict [list \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {0} \
    CONFIG.NUM_SI {1} \
    CONFIG.SI_DESTID_PINS {} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_high


  set_property -dict [ list \
   CONFIG.TDEST_WIDTH {8} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.CONNECTIONS {M00_INIS {read_bw {0} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP1/RP1_static/axis_noc_high/S00_AXIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
 ] [get_bd_pins /RP1/RP1_static/axis_noc_high/aclk0]

  # Create instance: axis_switch_outputMux, and set properties
  set axis_switch_outputMux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_outputMux ]
  set_property -dict [list \
    CONFIG.M00_AXIS_HIGHTDEST {0x0000000f} \
    CONFIG.M01_AXIS_BASETDEST {0x00000010} \
    CONFIG.M01_AXIS_HIGHTDEST {0x0000001f} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
  ] $axis_switch_outputMux


  # Create instance: axis_noc_inputMux, and set properties
  set axis_noc_inputMux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 axis_noc_inputMux ]
  set_property -dict [list \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axis_noc_inputMux


  set_property -dict [ list \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP1/RP1_static/axis_noc_inputMux/M00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP1/RP1_static/axis_noc_inputMux/S00_INIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP1/RP1_static/axis_noc_inputMux/S01_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS} \
 ] [get_bd_pins /RP1/RP1_static/axis_noc_inputMux/aclk0]

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axis_noc_low/M01_INIS] [get_bd_intf_pins M01_INIS]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axis_noc_low/S00_INIS] [get_bd_intf_pins S00_INIS]
  connect_bd_intf_net -intf_net axis_noc_0_M00_AXIS [get_bd_intf_pins axis_noc_inputMux/M00_AXIS] [get_bd_intf_pins dfx_decoupler_0/s_n2rp_s]
  connect_bd_intf_net -intf_net axis_noc_high_M00_INIS [get_bd_intf_pins axis_noc_high/M00_INIS] [get_bd_intf_pins axis_noc_inputMux/S01_INIS]
  connect_bd_intf_net -intf_net axis_noc_low_M00_INIS [get_bd_intf_pins axis_noc_low/M00_INIS] [get_bd_intf_pins axis_noc_inputMux/S00_INIS]
  connect_bd_intf_net -intf_net axis_switch_0_M00_AXIS [get_bd_intf_pins axis_switch_outputMux/M00_AXIS] [get_bd_intf_pins axis_noc_low/S00_AXIS]
  connect_bd_intf_net -intf_net axis_switch_0_M01_AXIS [get_bd_intf_pins axis_switch_outputMux/M01_AXIS] [get_bd_intf_pins axis_noc_high/S00_AXIS]
  connect_bd_intf_net -intf_net dfx_decoupler_0_rp_n2rp_s [get_bd_intf_pins rp_n2rp_s] [get_bd_intf_pins dfx_decoupler_0/rp_n2rp_s]
  connect_bd_intf_net -intf_net dfx_decoupler_0_s_rp2n_m [get_bd_intf_pins dfx_decoupler_0/s_rp2n_m] [get_bd_intf_pins axis_switch_outputMux/S00_AXIS]
  connect_bd_intf_net -intf_net tile1_output_stream [get_bd_intf_pins rp_rp2n_m] [get_bd_intf_pins dfx_decoupler_0/rp_rp2n_m]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins rp2n_m_aclk] [get_bd_pins dfx_decoupler_0/rp2n_m_aclk] [get_bd_pins dfx_decoupler_0/n2rp_s_aclk] [get_bd_pins axis_noc_low/aclk0] [get_bd_pins axis_switch_outputMux/aclk] [get_bd_pins axis_noc_high/aclk0] [get_bd_pins axis_noc_inputMux/aclk0]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins n2rp_s_arstn] [get_bd_pins dfx_decoupler_0/n2rp_s_arstn] [get_bd_pins dfx_decoupler_0/rp2n_m_arstn] [get_bd_pins axis_switch_outputMux/aresetn]
  connect_bd_net -net static_region_Dout [get_bd_pins decouple] [get_bd_pins dfx_decoupler_0/decouple]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Hierarchical cell: RP1
proc create_hier_cell_RP1 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP1() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M00_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M00_INIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S00_INIS


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I decouple

  # Create instance: RP1_Static
  create_hier_cell_RP1_Static $hier_obj RP1_Static

  # Create instance: RP1_DFX
  create_hier_cell_RP1_DFX $hier_obj RP1_DFX

  # Create interface connections
  connect_bd_intf_net -intf_net RP1_Static_M00_INIS [get_bd_intf_pins M00_INIS] [get_bd_intf_pins RP1_Static/M00_INIS]
  connect_bd_intf_net -intf_net S00_INIS_1 [get_bd_intf_pins S00_INIS] [get_bd_intf_pins RP1_Static/S00_INIS]
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_pins S00_INI] [get_bd_intf_pins RP1_DFX/S00_INI]
  connect_bd_intf_net -intf_net dfx_decoupler_0_rp_n2rp_s [get_bd_intf_pins RP1_Static/rp_n2rp_s] [get_bd_intf_pins RP1_DFX/input_stream]
  connect_bd_intf_net -intf_net tile1_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins RP1_DFX/M00_INI]
  connect_bd_intf_net -intf_net tile1_output_stream [get_bd_intf_pins RP1_Static/rp_rp2n_m] [get_bd_intf_pins RP1_DFX/output_stream]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins aclk] [get_bd_pins RP1_DFX/aclk] [get_bd_pins RP1_Static/rp2n_m_aclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins RP1_DFX/aresetn] [get_bd_pins RP1_Static/n2rp_s_arstn]
  connect_bd_net -net static_region_Dout [get_bd_pins decouple] [get_bd_pins RP1_Static/decouple]

  # Restore current instance
  current_bd_instance $oldCurInst
}