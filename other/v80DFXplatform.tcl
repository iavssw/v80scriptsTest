
################################################################
# This is a generated script based on design: v80DFXplatform
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.1
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source v80DFXplatform_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcv80-lsva4737-2MHP-e-S
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name v80DFXplatform

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:versal_cips:3.4\
xilinx.com:ip:clk_wizard:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_noc:1.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:xlslice:1.0\
xilinx.com:ip:smartconnect:1.0\
xilinx.com:ip:axis_noc:1.0\
xilinx.com:ip:dfx_decoupler:1.0\
xilinx.com:ip:axis_switch:1.1\
xilinx.com:hls:rmBase:1.1\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: RP3_DFX
proc create_hier_cell_RP3_DFX { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP3_DFX() - Empty argument(s)!"}
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
 ] [get_bd_intf_pins /RP3/RP3_DFX/axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP3/RP3_DFX/axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /RP3/RP3_DFX/axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI} \
 ] [get_bd_pins /RP3/RP3_DFX/axi_noc_0/aclk0]

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

# Hierarchical cell: RP3_static
proc create_hier_cell_RP3_static { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP3_static() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M01_INIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S01_INIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M02_INIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S02_INIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 rp_sout2rp2n

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 rp_n2rp2sin


  # Create pins
  create_bd_pin -dir I -type clk rp_clk
  create_bd_pin -dir I -type rst rp_arstn
  create_bd_pin -dir I rp_decouple

  # Create instance: axis_switch_outputMux, and set properties
  set axis_switch_outputMux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_outputMux ]
  set_property -dict [list \
    CONFIG.M00_AXIS_BASETDEST {0x00000000} \
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
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_inputMux/M00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_inputMux/S00_INIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_inputMux/S01_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS} \
 ] [get_bd_pins /RP3/RP3_static/axis_noc_inputMux/aclk0]

  # Create instance: axis_noc_low, and set properties
  set axis_noc_low [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 axis_noc_low ]
  set_property -dict [list \
    CONFIG.NMI_TDEST_VALS {,0x00000001 0x00000001,0x00000002 0x00000002} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {3} \
    CONFIG.NUM_NSI {2} \
    CONFIG.SI_DESTID_PINS {1} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_low


  set_property -dict [ list \
   CONFIG.TDEST_WIDTH {8} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.CONNECTIONS {M01_INIS { write_bw {500}} M02_INIS { write_bw {500}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_low/S00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INIS { write_bw {500} }} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_low/S00_INIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INIS { write_bw {500} }} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_low/S01_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
 ] [get_bd_pins /RP3/RP3_static/axis_noc_low/aclk0]

  # Create instance: axis_noc_high, and set properties
  set axis_noc_high [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_noc:1.0 axis_noc_high ]
  set_property -dict [list \
    CONFIG.NMI_TDEST_VALS {,} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {0} \
    CONFIG.SI_DESTID_PINS {1} \
    CONFIG.TDEST_WIDTH {8} \
  ] $axis_noc_high


  set_property -dict [ list \
   CONFIG.TDEST_WIDTH {8} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.CONNECTIONS {M00_INIS {read_bw {0} write_bw {1720} read_avg_burst {4} write_avg_burst {4}} } \
   CONFIG.DEST_IDS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP3/RP3_static/axis_noc_high/S00_AXIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
 ] [get_bd_pins /RP3/RP3_static/axis_noc_high/aclk0]

  # Create instance: dfx_decoupler_0, and set properties
  set dfx_decoupler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler_0 ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_AXI_LITE 0 HAS_SIGNAL_CONTROL 1 HAS_SIGNAL_STATUS 0 INTF {sout2rp2n {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 REGISTER 1 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST\
{DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TUSER {PRESENT 1 WIDTH 1} TID {PRESENT 1 WIDTH 1} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 1 WIDTH 16} TKEEP {PRESENT\
1 WIDTH 16}}} n2rp2sin {ID 1 MODE slave VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TDATA {DECOUPLED 1 PRESENT 1 WIDTH 128} TLAST {DECOUPLED 1 PRESENT 1 WIDTH 1} TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT\
1 WIDTH 1} TUSER {PRESENT 0 WIDTH 0} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 1 WIDTH 8} TSTRB {PRESENT 0 WIDTH 16} TKEEP {PRESENT 1 WIDTH 16}} REGISTER 1}}} \
    CONFIG.GUI_SELECT_INTERFACE {0} \
    CONFIG.GUI_SELECT_MODE {master} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
    CONFIG.GUI_SIGNAL_DECOUPLED_2 {true} \
    CONFIG.GUI_SIGNAL_DECOUPLED_4 {true} \
  ] $dfx_decoupler_0


  # Create interface connections
  connect_bd_intf_net -intf_net axis_high2noc [get_bd_intf_pins axis_noc_high/M00_INIS] [get_bd_intf_pins axis_noc_inputMux/S01_INIS]
  connect_bd_intf_net -intf_net axis_low2noc [get_bd_intf_pins axis_noc_low/M00_INIS] [get_bd_intf_pins axis_noc_inputMux/S00_INIS]
  connect_bd_intf_net -intf_net axis_noc_low_M01_INIS_conn [get_bd_intf_pins axis_noc_low/M01_INIS] [get_bd_intf_pins M01_INIS]
  connect_bd_intf_net -intf_net axis_noc_low_M02_INIS_conn [get_bd_intf_pins axis_noc_low/M02_INIS] [get_bd_intf_pins M02_INIS]
  connect_bd_intf_net -intf_net axis_noc_low_S01_INIS_conn [get_bd_intf_pins axis_noc_low/S00_INIS] [get_bd_intf_pins S01_INIS]
  connect_bd_intf_net -intf_net axis_noc_low_S02_INIS_conn [get_bd_intf_pins axis_noc_low/S01_INIS] [get_bd_intf_pins S02_INIS]
  connect_bd_intf_net -intf_net axis_switch2high [get_bd_intf_pins axis_switch_outputMux/M01_AXIS] [get_bd_intf_pins axis_noc_high/S00_AXIS]
  connect_bd_intf_net -intf_net axis_switch2low [get_bd_intf_pins axis_switch_outputMux/M00_AXIS] [get_bd_intf_pins axis_noc_low/S00_AXIS]
  connect_bd_intf_net -intf_net dcp2dfx [get_bd_intf_pins rp_n2rp2sin] [get_bd_intf_pins dfx_decoupler_0/rp_n2rp2sin]
  connect_bd_intf_net -intf_net dcp2dfx2 [get_bd_intf_pins rp_sout2rp2n] [get_bd_intf_pins dfx_decoupler_0/rp_sout2rp2n]
  connect_bd_intf_net -intf_net dcp2n [get_bd_intf_pins dfx_decoupler_0/s_sout2rp2n] [get_bd_intf_pins axis_switch_outputMux/S00_AXIS]
  connect_bd_intf_net -intf_net n2dcp [get_bd_intf_pins axis_noc_inputMux/M00_AXIS] [get_bd_intf_pins dfx_decoupler_0/s_n2rp2sin]

  # Create port connections
  connect_bd_net -net aresetn [get_bd_pins rp_arstn] [get_bd_pins dfx_decoupler_0/sout2rp2n_arstn] [get_bd_pins dfx_decoupler_0/n2rp2sin_arstn] [get_bd_pins axis_switch_outputMux/aresetn]
  connect_bd_net -net clk [get_bd_pins rp_clk] [get_bd_pins dfx_decoupler_0/sout2rp2n_aclk] [get_bd_pins dfx_decoupler_0/n2rp2sin_aclk] [get_bd_pins axis_noc_low/aclk0] [get_bd_pins axis_switch_outputMux/aclk] [get_bd_pins axis_noc_inputMux/aclk0] [get_bd_pins axis_noc_high/aclk0]
  connect_bd_net -net decouple [get_bd_pins rp_decouple] [get_bd_pins dfx_decoupler_0/decouple]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: RP2_DFX
proc create_hier_cell_RP2_DFX { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP2_DFX() - Empty argument(s)!"}
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
 ] [get_bd_intf_pins /RP2/RP2_DFX/axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /RP2/RP2_DFX/axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /RP2/RP2_DFX/axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI} \
 ] [get_bd_pins /RP2/RP2_DFX/axi_noc_0/aclk0]

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

# Hierarchical cell: RP2_static
proc create_hier_cell_RP2_static { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP2_static() - Empty argument(s)!"}
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
 ] [get_bd_intf_pins /RP2/RP2_static/axis_noc_low/S00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INIS { write_bw {500}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP2/RP2_static/axis_noc_low/S00_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
 ] [get_bd_pins /RP2/RP2_static/axis_noc_low/aclk0]

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
 ] [get_bd_intf_pins /RP2/RP2_static/axis_noc_high/S00_AXIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXIS} \
 ] [get_bd_pins /RP2/RP2_static/axis_noc_high/aclk0]

  # Create instance: axis_switch_outputMux, and set properties
  set axis_switch_outputMux [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_switch:1.1 axis_switch_outputMux ]
  set_property -dict [list \
    CONFIG.M00_AXIS_HIGHTDEST {0x0000000f} \
    CONFIG.M01_AXIS_BASETDEST {0x00000010} \
    CONFIG.M01_AXIS_HIGHTDEST {0x0000001f} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_SI {1} \
    CONFIG.ROUTING_MODE {0} \
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
 ] [get_bd_intf_pins /RP2/RP2_static/axis_noc_inputMux/M00_AXIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP2/RP2_static/axis_noc_inputMux/S00_INIS]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXIS { write_bw {500} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {} \
 ] [get_bd_intf_pins /RP2/RP2_static/axis_noc_inputMux/S01_INIS]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXIS} \
 ] [get_bd_pins /RP2/RP2_static/axis_noc_inputMux/aclk0]

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

# Hierarchical cell: RP3
proc create_hier_cell_RP3 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP3() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M01_INIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S01_INIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M02_INIS

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S02_INIS


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I decouple

  # Create instance: RP3_static
  create_hier_cell_RP3_static $hier_obj RP3_static

  # Create instance: RP3_DFX
  create_hier_cell_RP3_DFX $hier_obj RP3_DFX

  # Create interface connections
  connect_bd_intf_net -intf_net RP3_static_M02_INIS [get_bd_intf_pins M02_INIS] [get_bd_intf_pins RP3_static/M02_INIS]
  connect_bd_intf_net -intf_net input_stream_1 [get_bd_intf_pins RP3_DFX/input_stream] [get_bd_intf_pins RP3_static/rp_n2rp2sin]
  connect_bd_intf_net -intf_net static_M01_INIS_conn [get_bd_intf_pins RP3_static/M01_INIS] [get_bd_intf_pins M01_INIS]
  connect_bd_intf_net -intf_net static_S01_INIS_conn [get_bd_intf_pins RP3_static/S01_INIS] [get_bd_intf_pins S01_INIS]
  connect_bd_intf_net -intf_net static_S02_INIS_conn [get_bd_intf_pins RP3_static/S02_INIS] [get_bd_intf_pins S02_INIS]

  # Create port connections
  connect_bd_net -net aresetn [get_bd_pins aresetn] [get_bd_pins RP3_static/rp_arstn]
  connect_bd_net -net clk [get_bd_pins aclk] [get_bd_pins RP3_static/rp_clk]
  connect_bd_net -net decouple [get_bd_pins decouple] [get_bd_pins RP3_static/rp_decouple]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: RP2
proc create_hier_cell_RP2 { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_RP2() - Empty argument(s)!"}
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

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S00_INIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M01_INIS


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I decouple

  # Create instance: RP2_static
  create_hier_cell_RP2_static $hier_obj RP2_static

  # Create instance: RP2_DFX
  create_hier_cell_RP2_DFX $hier_obj RP2_DFX

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins RP2_static/M01_INIS] [get_bd_intf_pins M01_INIS]
  connect_bd_intf_net -intf_net S00_INIS_1 [get_bd_intf_pins S00_INIS] [get_bd_intf_pins RP2_static/S00_INIS]
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_pins S00_INI] [get_bd_intf_pins RP2_DFX/S00_INI]
  connect_bd_intf_net -intf_net dfx_decoupler_0_rp_n2rp_s [get_bd_intf_pins RP2_static/rp_n2rp_s] [get_bd_intf_pins RP2_DFX/input_stream]
  connect_bd_intf_net -intf_net tile1_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins RP2_DFX/M00_INI]
  connect_bd_intf_net -intf_net tile1_output_stream [get_bd_intf_pins RP2_static/rp_rp2n_m] [get_bd_intf_pins RP2_DFX/output_stream]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins aclk] [get_bd_pins RP2_DFX/aclk] [get_bd_pins RP2_static/rp2n_m_aclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins RP2_DFX/aresetn] [get_bd_pins RP2_static/n2rp_s_arstn]
  connect_bd_net -net static_region_Dout [get_bd_pins decouple] [get_bd_pins RP2_static/decouple]

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

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inis_rtl:1.0 S00_INIS

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inis_rtl:1.0 M01_INIS


  # Create pins
  create_bd_pin -dir I -type clk aclk
  create_bd_pin -dir I -type rst aresetn
  create_bd_pin -dir I decouple

  # Create instance: RP1_static
  create_hier_cell_RP1_static $hier_obj RP1_static

  # Create instance: RP1_DFX
  create_hier_cell_RP1_DFX $hier_obj RP1_DFX

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins RP1_static/M01_INIS] [get_bd_intf_pins M01_INIS]
  connect_bd_intf_net -intf_net S00_INIS_1 [get_bd_intf_pins S00_INIS] [get_bd_intf_pins RP1_static/S00_INIS]
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_pins S00_INI] [get_bd_intf_pins RP1_DFX/S00_INI]
  connect_bd_intf_net -intf_net dfx_decoupler_0_rp_n2rp_s [get_bd_intf_pins RP1_static/rp_n2rp_s] [get_bd_intf_pins RP1_DFX/input_stream]
  connect_bd_intf_net -intf_net tile1_M00_INI [get_bd_intf_pins M00_INI] [get_bd_intf_pins RP1_DFX/M00_INI]
  connect_bd_intf_net -intf_net tile1_output_stream [get_bd_intf_pins RP1_static/rp_rp2n_m] [get_bd_intf_pins RP1_DFX/output_stream]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins aclk] [get_bd_pins RP1_DFX/aclk] [get_bd_pins RP1_static/rp2n_m_aclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins aresetn] [get_bd_pins RP1_DFX/aresetn] [get_bd_pins RP1_static/n2rp_s_arstn]
  connect_bd_net -net static_region_Dout [get_bd_pins decouple] [get_bd_pins RP1_static/decouple]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: static_region
proc create_hier_cell_static_region { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_static_region() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_pciea1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk0_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_1

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_1

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M04_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S00_INI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 S01_INI

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 M05_INI


  # Create pins
  create_bd_pin -dir O -type clk slowest_sync_clk
  create_bd_pin -dir O -from 0 -to 0 -type rst peripheral_aresetn
  create_bd_pin -dir O -from 0 -to 0 Dout
  create_bd_pin -dir O -from 0 -to 0 Dout1

  # Create instance: logic1, and set properties
  set logic1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic1 ]

  # Create instance: cips, and set properties
  set cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:versal_cips:3.4 cips ]
  set_property -dict [list \
    CONFIG.CPM_CONFIG { \
      CPM_PCIE0_ACS_CAP_ON {0} \
      CPM_PCIE0_CFG_EXT_IF {1} \
      CPM_PCIE0_EXT_PCIE_CFG_SPACE_ENABLED {None} \
      CPM_PCIE0_MAX_LINK_SPEED {32.0_GT/s} \
      CPM_PCIE0_MODES {DMA} \
      CPM_PCIE0_MODE_SELECTION {Advanced} \
      CPM_PCIE0_PF0_BAR0_QDMA_64BIT {1} \
      CPM_PCIE0_PF0_BAR0_QDMA_PREFETCHABLE {1} \
      CPM_PCIE0_PF0_BAR0_QDMA_STEERING {CPM_PCIE_NOC_1} \
      CPM_PCIE0_PF0_BAR0_QDMA_TYPE {DMA} \
      CPM_PCIE0_PF0_BAR2_QDMA_64BIT {1} \
      CPM_PCIE0_PF0_BAR2_QDMA_ENABLED {1} \
      CPM_PCIE0_PF0_BAR2_QDMA_PREFETCHABLE {1} \
      CPM_PCIE0_PF0_BAR2_QDMA_SCALE {Megabytes} \
      CPM_PCIE0_PF0_BAR2_QDMA_SIZE {64} \
      CPM_PCIE0_PF0_BAR4_QDMA_64BIT {1} \
      CPM_PCIE0_PF0_BAR4_QDMA_ENABLED {1} \
      CPM_PCIE0_PF0_BAR4_QDMA_PREFETCHABLE {1} \
      CPM_PCIE0_PF0_BAR4_QDMA_SCALE {Megabytes} \
      CPM_PCIE0_PF0_BAR4_QDMA_SIZE {32} \
      CPM_PCIE0_PF0_BASE_CLASS_VALUE {12} \
      CPM_PCIE0_PF0_CFG_DEV_ID {50b5} \
      CPM_PCIE0_PF0_CFG_REV_ID {42} \
      CPM_PCIE0_PF0_CFG_SUBSYS_ID {000e} \
      CPM_PCIE0_PF0_MSIX_CAP_TABLE_SIZE {8} \
      CPM_PCIE0_PF0_PCIEBAR2AXIBAR_QDMA_2 {0x0000000000000000} \
      CPM_PCIE0_PF0_PCIEBAR2AXIBAR_QDMA_4 {0x0000020180000000} \
      CPM_PCIE0_PF0_SUB_CLASS_VALUE {00} \
      CPM_PCIE0_TANDEM {Tandem_PCIe} \
      CPM_PCIE1_ACS_CAP_ON {0} \
      CPM_PCIE1_ARI_CAP_ENABLED {1} \
      CPM_PCIE1_CFG_EXT_IF {1} \
      CPM_PCIE1_CFG_VEND_ID {10ee} \
      CPM_PCIE1_COPY_PF0_QDMA_ENABLED {0} \
      CPM_PCIE1_EXT_PCIE_CFG_SPACE_ENABLED {Extended_Large} \
      CPM_PCIE1_FUNCTIONAL_MODE {None} \
      CPM_PCIE1_MAX_LINK_SPEED {32.0_GT/s} \
      CPM_PCIE1_MODES {None} \
      CPM_PCIE1_MODE_SELECTION {Advanced} \
      CPM_PCIE1_MSI_X_OPTIONS {MSI-X_External} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_0 {0x0000008000000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_1 {0x0000008040000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_2 {0x0000008080000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_3 {0x00000080C0000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_4 {0x0000008100000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_BASEADDR_5 {0x0000008140000000} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_0 {0x000000803FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_1 {0x000000807FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_2 {0x00000080BFFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_3 {0x00000080FFFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_4 {0x000000813FFFFFFFF} \
      CPM_PCIE1_PF0_AXIBAR2PCIE_HIGHADDR_5 {0x000000817FFFFFFFF} \
      CPM_PCIE1_PF0_BAR0_QDMA_64BIT {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_ENABLED {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_PREFETCHABLE {1} \
      CPM_PCIE1_PF0_BAR0_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF0_BAR0_QDMA_SIZE {512} \
      CPM_PCIE1_PF0_BAR0_QDMA_TYPE {DMA} \
      CPM_PCIE1_PF0_BAR2_QDMA_64BIT {1} \
      CPM_PCIE1_PF0_BAR2_QDMA_ENABLED {1} \
      CPM_PCIE1_PF0_BAR2_QDMA_PREFETCHABLE {1} \
      CPM_PCIE1_PF0_BAR2_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF0_BAR2_QDMA_SIZE {64} \
      CPM_PCIE1_PF0_BAR2_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF0_BASE_CLASS_VALUE {12} \
      CPM_PCIE1_PF0_CFG_DEV_ID {50b5} \
      CPM_PCIE1_PF0_CFG_REV_ID {42} \
      CPM_PCIE1_PF0_CFG_SUBSYS_ID {000e} \
      CPM_PCIE1_PF0_DEV_CAP_FUNCTION_LEVEL_RESET_CAPABLE {0} \
      CPM_PCIE1_PF0_MSIX_CAP_TABLE_OFFSET {50000} \
      CPM_PCIE1_PF0_MSIX_CAP_TABLE_SIZE {8} \
      CPM_PCIE1_PF0_MSIX_ENABLED {1} \
      CPM_PCIE1_PF0_PCIEBAR2AXIBAR_QDMA_0 {0x000000000000000} \
      CPM_PCIE1_PF0_PCIEBAR2AXIBAR_QDMA_2 {0x0000020180000000} \
      CPM_PCIE1_PF0_SUB_CLASS_VALUE {00} \
      CPM_PCIE1_PF1_BAR0_QDMA_64BIT {0} \
      CPM_PCIE1_PF1_BAR0_QDMA_ENABLED {0} \
      CPM_PCIE1_PF1_BAR0_QDMA_PREFETCHABLE {0} \
      CPM_PCIE1_PF1_BAR0_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF1_BAR0_QDMA_SIZE {4} \
      CPM_PCIE1_PF1_BAR0_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF1_BAR2_QDMA_64BIT {0} \
      CPM_PCIE1_PF1_BAR2_QDMA_ENABLED {0} \
      CPM_PCIE1_PF1_BAR2_QDMA_PREFETCHABLE {0} \
      CPM_PCIE1_PF1_BAR2_QDMA_SCALE {Kilobytes} \
      CPM_PCIE1_PF1_BAR2_QDMA_SIZE {4} \
      CPM_PCIE1_PF1_BAR2_QDMA_TYPE {AXI_Bridge_Master} \
      CPM_PCIE1_PF1_BASE_CLASS_VALUE {05} \
      CPM_PCIE1_PF1_CFG_DEV_ID {0} \
      CPM_PCIE1_PF1_CFG_SUBSYS_ID {0} \
      CPM_PCIE1_PF1_CFG_SUBSYS_VEND_ID {0} \
      CPM_PCIE1_PF1_MSIX_CAP_TABLE_OFFSET {50000} \
      CPM_PCIE1_PF1_MSIX_CAP_TABLE_SIZE {8} \
      CPM_PCIE1_PF1_MSIX_ENABLED {1} \
      CPM_PCIE1_PF1_PCIEBAR2AXIBAR_QDMA_2 {0x0000020180000000} \
      CPM_PCIE1_PF1_SUB_CLASS_VALUE {80} \
      CPM_PCIE1_PL_LINK_CAP_MAX_LINK_WIDTH {NONE} \
      CPM_PCIE1_TL_PF_ENABLE_REG {1} \
    } \
    CONFIG.DDR_MEMORY_MODE {Custom} \
    CONFIG.PS_PL_CONNECTIVITY_MODE {Custom} \
    CONFIG.PS_PMC_CONFIG { \
      BOOT_MODE {Custom} \
      CLOCK_MODE {Custom} \
      DDR_MEMORY_MODE {Custom} \
      DESIGN_MODE {1} \
      DEVICE_INTEGRITY_MODE {Custom} \
      IO_CONFIG_MODE {Custom} \
      PCIE_APERTURES_DUAL_ENABLE {0} \
      PCIE_APERTURES_SINGLE_ENABLE {1} \
      PMC_BANK_1_IO_STANDARD {LVCMOS3.3} \
      PMC_CRP_OSPI_REF_CTRL_FREQMHZ {200} \
      PMC_CRP_PL0_REF_CTRL_FREQMHZ {100} \
      PMC_CRP_PL1_REF_CTRL_FREQMHZ {33.3333333} \
      PMC_CRP_PL2_REF_CTRL_FREQMHZ {250} \
      PMC_GLITCH_CONFIG {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_1 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GLITCH_CONFIG_2 {{DEPTH_SENSITIVITY 1} {MIN_PULSE_WIDTH 0.5} {TYPE CUSTOM} {VCC_PMC_VALUE 0.88}} \
      PMC_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PMC_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO12 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO13 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PMC_MIO17 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO26 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO27 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO28 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO29 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO30 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO31 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO32 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO33 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO34 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO35 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO36 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO37 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO38 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO39 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO40 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO41 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO42 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO43 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO44 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO48 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO49 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO50 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO51 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PMC_MIO_EN_FOR_PL_PCIE {0} \
      PMC_OSPI_PERIPHERAL {{ENABLE 1} {IO {PMC_MIO 0 .. 11}} {MODE Single}} \
      PMC_REF_CLK_FREQMHZ {33.333333} \
      PMC_SD0_DATA_TRANSFER_MODE {8Bit} \
      PMC_SD0_PERIPHERAL {{CLK_100_SDR_OTAP_DLY 0x00} {CLK_200_SDR_OTAP_DLY 0x2} {CLK_50_DDR_ITAP_DLY 0x1E} {CLK_50_DDR_OTAP_DLY 0x5} {CLK_50_SDR_ITAP_DLY 0x2C} {CLK_50_SDR_OTAP_DLY 0x5} {ENABLE 1} {IO\
{PMC_MIO 13 .. 25}}} \
      PMC_SD0_SLOT_TYPE {eMMC} \
      PMC_USE_NOC_PMC_AXI0 {1} \
      PMC_USE_PMC_NOC_AXI0 {1} \
      PS_BANK_2_IO_STANDARD {LVCMOS3.3} \
      PS_BOARD_INTERFACE {Custom} \
      PS_CRL_CPM_TOPSW_REF_CTRL_FREQMHZ {1000} \
      PS_GEN_IPI0_ENABLE {0} \
      PS_GEN_IPI1_ENABLE {0} \
      PS_GEN_IPI2_ENABLE {0} \
      PS_GEN_IPI3_ENABLE {1} \
      PS_GEN_IPI3_MASTER {R5_0} \
      PS_GEN_IPI4_ENABLE {1} \
      PS_GEN_IPI4_MASTER {R5_0} \
      PS_GEN_IPI5_ENABLE {1} \
      PS_GEN_IPI5_MASTER {R5_1} \
      PS_GEN_IPI6_ENABLE {1} \
      PS_GEN_IPI6_MASTER {R5_1} \
      PS_GPIO_EMIO_PERIPHERAL_ENABLE {0} \
      PS_I2C0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 2 .. 3}}} \
      PS_I2C1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 0 .. 1}}} \
      PS_IRQ_USAGE {{CH0 1} {CH1 1} {CH10 0} {CH11 0} {CH12 0} {CH13 0} {CH14 0} {CH15 0} {CH2 0} {CH3 0} {CH4 0} {CH5 0} {CH6 0} {CH7 0} {CH8 0} {CH9 0}} \
      PS_KAT_ENABLE {0} \
      PS_KAT_ENABLE_1 {0} \
      PS_KAT_ENABLE_2 {0} \
      PS_MIO10 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO11 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO12 {{AUX_IO 0} {DIRECTION inout} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO13 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO14 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO18 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO19 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO22 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO23 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO24 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO25 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO4 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO5 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO6 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO7 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE GPIO}} \
      PS_MIO8 {{AUX_IO 0} {DIRECTION in} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 0} {SLEW slow} {USAGE Reserved}} \
      PS_MIO9 {{AUX_IO 0} {DIRECTION out} {DRIVE_STRENGTH 8mA} {OUTPUT_DATA default} {PULL pullup} {SCHMITT 1} {SLEW slow} {USAGE Reserved}} \
      PS_M_AXI_LPD_DATA_WIDTH {128} \
      PS_NUM_FABRIC_RESETS {1} \
      PS_PCIE1_PERIPHERAL_ENABLE {1} \
      PS_PCIE2_PERIPHERAL_ENABLE {0} \
      PS_PCIE_EP_RESET1_IO {PMC_MIO 24} \
      PS_PCIE_EP_RESET2_IO {None} \
      PS_PCIE_RESET {ENABLE 1} \
      PS_PL_CONNECTIVITY_MODE {Custom} \
      PS_SPI0 {{GRP_SS0_ENABLE 1} {GRP_SS0_IO {PS_MIO 15}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PMC_MIO 14}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PMC_MIO 13}} {PERIPHERAL_ENABLE 1} {PERIPHERAL_IO {PS_MIO 12 .. 17}}}\
\
      PS_SPI1 {{GRP_SS0_ENABLE 0} {GRP_SS0_IO {PS_MIO 9}} {GRP_SS1_ENABLE 0} {GRP_SS1_IO {PS_MIO 8}} {GRP_SS2_ENABLE 0} {GRP_SS2_IO {PS_MIO 7}} {PERIPHERAL_ENABLE 0} {PERIPHERAL_IO {PS_MIO 6 .. 11}}} \
      PS_TTC0_PERIPHERAL_ENABLE {1} \
      PS_TTC1_PERIPHERAL_ENABLE {1} \
      PS_TTC2_PERIPHERAL_ENABLE {1} \
      PS_TTC3_PERIPHERAL_ENABLE {1} \
      PS_UART0_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 8 .. 9}}} \
      PS_UART1_PERIPHERAL {{ENABLE 1} {IO {PS_MIO 20 .. 21}}} \
      PS_USE_FPD_CCI_NOC {0} \
      PS_USE_M_AXI_FPD {0} \
      PS_USE_M_AXI_LPD {0} \
      PS_USE_NOC_LPD_AXI0 {0} \
      PS_USE_PMCPL_CLK0 {1} \
      PS_USE_PMCPL_CLK1 {0} \
      PS_USE_PMCPL_CLK2 {1} \
      PS_USE_S_AXI_LPD {0} \
      SMON_ALARMS {Set_Alarms_On} \
      SMON_ENABLE_TEMP_AVERAGING {0} \
      SMON_MEAS100 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_500} {SUPPLY_NUM 9}} \
      SMON_MEAS101 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_501} {SUPPLY_NUM 10}} \
      SMON_MEAS102 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_502} {SUPPLY_NUM 11}} \
      SMON_MEAS103 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 4.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {4 V unipolar}} {NAME VCCO_503} {SUPPLY_NUM 12}} \
      SMON_MEAS104 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_700} {SUPPLY_NUM 13}} \
      SMON_MEAS105 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_701} {SUPPLY_NUM 14}} \
      SMON_MEAS106 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCO_702} {SUPPLY_NUM 15}} \
      SMON_MEAS118 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PMC} {SUPPLY_NUM 0}} \
      SMON_MEAS119 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSFP} {SUPPLY_NUM 1}} \
      SMON_MEAS120 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_PSLP} {SUPPLY_NUM 2}} \
      SMON_MEAS121 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_RAM} {SUPPLY_NUM 3}} \
      SMON_MEAS122 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCC_SOC} {SUPPLY_NUM 4}} \
      SMON_MEAS47 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_104} {SUPPLY_NUM 20}} \
      SMON_MEAS48 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCCAUX_105} {SUPPLY_NUM 21}} \
      SMON_MEAS64 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_104} {SUPPLY_NUM 18}} \
      SMON_MEAS65 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVCC_105} {SUPPLY_NUM 19}} \
      SMON_MEAS81 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_104} {SUPPLY_NUM 22}} \
      SMON_MEAS82 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME GTYP_AVTT_105} {SUPPLY_NUM 23}} \
      SMON_MEAS96 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX} {SUPPLY_NUM 6}} \
      SMON_MEAS97 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_PMC} {SUPPLY_NUM 7}} \
      SMON_MEAS98 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCAUX_SMON} {SUPPLY_NUM 8}} \
      SMON_MEAS99 {{ALARM_ENABLE 1} {ALARM_LOWER 0.00} {ALARM_UPPER 2.00} {AVERAGE_EN 0} {ENABLE 1} {MODE {2 V unipolar}} {NAME VCCINT} {SUPPLY_NUM 5}} \
      SMON_TEMP_AVERAGING_SAMPLES {0} \
      SMON_VOLTAGE_AVERAGING_SAMPLES {8} \
    } \
    CONFIG.PS_PMC_CONFIG_APPLIED {1} \
  ] $cips


  # Create instance: clk_wizard_0, and set properties
  set clk_wizard_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wizard:1.0 clk_wizard_0 ]
  set_property -dict [list \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
  ] $clk_wizard_0


  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create instance: axi_noc_mc_ddr4_0, and set properties
  set axi_noc_mc_ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_mc_ddr4_0 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC_CHAN_REGION1 {DDR_CH1} \
    CONFIG.MC_COMPONENT_WIDTH {x16} \
    CONFIG.MC_DATAWIDTH {72} \
    CONFIG.MC_DM_WIDTH {9} \
    CONFIG.MC_DQS_WIDTH {9} \
    CONFIG.MC_DQ_WIDTH {72} \
    CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {true} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {Components} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {16} \
    CONFIG.MC_STACKHEIGHT {1} \
    CONFIG.MC_SYSTEM_CLOCK {Differential} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
    CONFIG.SI_NAMES {} \
    CONFIG.SI_SIDEBAND_PINS {} \
  ] $axi_noc_mc_ddr4_0


  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /static_region/axi_noc_mc_ddr4_0/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /static_region/axi_noc_mc_ddr4_0/S01_INI]

  # Create instance: axi_noc_mc_ddr4_1, and set properties
  set axi_noc_mc_ddr4_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_mc_ddr4_1 ]
  set_property -dict [list \
    CONFIG.CONTROLLERTYPE {DDR4_SDRAM} \
    CONFIG.MC0_CONFIG_NUM {config21} \
    CONFIG.MC0_FLIPPED_PINOUT {false} \
    CONFIG.MC_CHAN_REGION0 {DDR_CH2} \
    CONFIG.MC_COMPONENT_WIDTH {x4} \
    CONFIG.MC_DATAWIDTH {72} \
    CONFIG.MC_INIT_MEM_USING_ECC_SCRUB {true} \
    CONFIG.MC_INPUTCLK0_PERIOD {5000} \
    CONFIG.MC_MEMORY_DEVICETYPE {RDIMMs} \
    CONFIG.MC_MEMORY_SPEEDGRADE {DDR4-3200AA(22-22-22)} \
    CONFIG.MC_NO_CHANNELS {Single} \
    CONFIG.MC_PARITY {true} \
    CONFIG.MC_RANK {1} \
    CONFIG.MC_ROWADDRESSWIDTH {18} \
    CONFIG.MC_STACKHEIGHT {1} \
    CONFIG.MC_SYSTEM_CLOCK {Differential} \
    CONFIG.NUM_CLKS {0} \
    CONFIG.NUM_MC {1} \
    CONFIG.NUM_MCP {4} \
    CONFIG.NUM_MI {0} \
    CONFIG.NUM_NMI {0} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {0} \
  ] $axi_noc_mc_ddr4_1


  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_0 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /static_region/axi_noc_mc_ddr4_1/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {MC_1 {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64}}} \
 ] [get_bd_intf_pins /static_region/axi_noc_mc_ddr4_1/S01_INI]

  # Create instance: axi_noc_cips, and set properties
  set axi_noc_cips [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_cips ]
  set_property -dict [list \
    CONFIG.HBM_NUM_CHNL {16} \
    CONFIG.HBM_REF_CLK_FREQ0 {200.000} \
    CONFIG.HBM_REF_CLK_FREQ1 {200.000} \
    CONFIG.HBM_REF_CLK_SELECTION {External} \
    CONFIG.MI_NAMES {} \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NMI_NAMES {} \
    CONFIG.NUM_CLKS {5} \
    CONFIG.NUM_HBM_BLI {0} \
    CONFIG.NUM_MI {2} \
    CONFIG.NUM_NMI {6} \
    CONFIG.NUM_NSI {2} \
    CONFIG.NUM_SI {3} \
    CONFIG.SI_NAMES {} \
  ] $axi_noc_cips


  set_property -dict [ list \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/M00_AXI]

  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_8000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/M01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {HBM10_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M02_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64}} HBM15_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM10_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M01_AXI {read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} HBM5_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM15_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM5_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM1_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM1_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM6_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM12_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM0_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM6_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM14_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM12_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM0_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM8_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM8_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM14_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM3_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM3_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM4_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM4_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM9_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {5} write_bw {5}} HBM2_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M05_INI {read_bw {5} write_bw {5}} HBM11_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M00_INI {read_bw {800} write_bw {800} read_avg_burst {64} write_avg_burst {64}} HBM9_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM11_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM7_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM13_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM7_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM13_PORT0 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM2_PORT2 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M01_AXI:0x140:M00_AXI:0x1} \
   CONFIG.REMAPS {M00_AXI {{0xF122_0000 0x1_0122_0000 64K} {0xF210_0000 0x1_0210_0000 64K}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M00_INI {read_bw {500} write_bw {500}}} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/S00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {HBM10_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M01_AXI {read_bw {5} write_bw {5} read_avg_burst {4} write_avg_burst {4}} HBM10_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM5_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM15_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM0_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM15_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM1_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM5_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM1_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM0_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM6_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM8_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM14_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M01_INI {read_bw {500} write_bw {500}} HBM12_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM6_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM12_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM8_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM14_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM3_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM3_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM4_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM9_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM4_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M04_INI {read_bw {5} write_bw {5}} M05_INI {read_bw {5} write_bw {5}} HBM9_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM11_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM11_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM7_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM13_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM7_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} HBM2_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M03_INI {read_bw {500} write_bw {500}} HBM2_PORT1 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}} M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}} HBM13_PORT3 {read_bw {250} write_bw {250} read_avg_burst {4} write_avg_burst {4}}} \
   CONFIG.DEST_IDS {M01_AXI:0x140:M00_AXI:0x1} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pcie} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/S01_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {500} write_bw {500}} M00_INI {read_bw {500} write_bw {500}}} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/S01_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M02_INI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}} M00_INI {read_bw {5} write_bw {5} read_avg_burst {64} write_avg_burst {64}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {ps_pmc} \
 ] [get_bd_intf_pins /static_region/axi_noc_cips/S02_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S00_AXI} \
 ] [get_bd_pins /static_region/axi_noc_cips/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S01_AXI} \
 ] [get_bd_pins /static_region/axi_noc_cips/aclk1]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {S02_AXI} \
 ] [get_bd_pins /static_region/axi_noc_cips/aclk2]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI} \
 ] [get_bd_pins /static_region/axi_noc_cips/aclk3]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M01_AXI} \
 ] [get_bd_pins /static_region/axi_noc_cips/aclk4]

  # Create instance: logic0, and set properties
  set logic0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 logic0 ]
  set_property CONFIG.CONST_VAL {0} $logic0


  # Create instance: axi_decoupler, and set properties
  set axi_decoupler [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_decoupler ]
  set_property CONFIG.C_ALL_OUTPUTS {1} $axi_decoupler


  # Create instance: RP1, and set properties
  set RP1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 RP1 ]

  # Create instance: RP2, and set properties
  set RP2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 RP2 ]
  set_property CONFIG.DIN_TO {1} $RP2


  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins axi_noc_cips/M04_INI] [get_bd_intf_pins M04_INI]
  connect_bd_intf_net -intf_net Conn2 [get_bd_intf_pins axi_noc_cips/S00_INI] [get_bd_intf_pins S00_INI]
  connect_bd_intf_net -intf_net Conn3 [get_bd_intf_pins axi_noc_cips/S01_INI] [get_bd_intf_pins S01_INI]
  connect_bd_intf_net -intf_net Conn4 [get_bd_intf_pins axi_noc_cips/M05_INI] [get_bd_intf_pins M05_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M00_AXI [get_bd_intf_pins axi_noc_cips/M00_AXI] [get_bd_intf_pins cips/NOC_PMC_AXI_0]
  connect_bd_intf_net -intf_net axi_noc_cips_M00_INI [get_bd_intf_pins axi_noc_cips/M00_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_cips/M01_AXI]
  connect_bd_intf_net -intf_net axi_noc_cips_M01_INI [get_bd_intf_pins axi_noc_cips/M01_INI] [get_bd_intf_pins axi_noc_mc_ddr4_0/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M02_INI [get_bd_intf_pins axi_noc_cips/M02_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_cips_M03_INI [get_bd_intf_pins axi_noc_cips/M03_INI] [get_bd_intf_pins axi_noc_mc_ddr4_1/S01_INI]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_0_CH0_DDR4_0 [get_bd_intf_pins CH0_DDR4_0_0] [get_bd_intf_pins axi_noc_mc_ddr4_0/CH0_DDR4_0]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_1_CH0_DDR4_0 [get_bd_intf_pins CH0_DDR4_0_1] [get_bd_intf_pins axi_noc_mc_ddr4_1/CH0_DDR4_0]
  connect_bd_intf_net -intf_net cips_CPM_PCIE_NOC_0 [get_bd_intf_pins cips/CPM_PCIE_NOC_0] [get_bd_intf_pins axi_noc_cips/S00_AXI]
  connect_bd_intf_net -intf_net cips_CPM_PCIE_NOC_1 [get_bd_intf_pins cips/CPM_PCIE_NOC_1] [get_bd_intf_pins axi_noc_cips/S01_AXI]
  connect_bd_intf_net -intf_net cips_PCIE0_GT [get_bd_intf_pins gt_pciea1] [get_bd_intf_pins cips/PCIE0_GT]
  connect_bd_intf_net -intf_net cips_PMC_NOC_AXI_0 [get_bd_intf_pins cips/PMC_NOC_AXI_0] [get_bd_intf_pins axi_noc_cips/S02_AXI]
  connect_bd_intf_net -intf_net gt_refclk0_0_1 [get_bd_intf_pins gt_refclk0_0] [get_bd_intf_pins cips/gt_refclk0]
  connect_bd_intf_net -intf_net hbm_ref_clk_0_1 [get_bd_intf_pins hbm_ref_clk_0] [get_bd_intf_pins axi_noc_cips/hbm_ref_clk0]
  connect_bd_intf_net -intf_net hbm_ref_clk_1_1 [get_bd_intf_pins hbm_ref_clk_1] [get_bd_intf_pins axi_noc_cips/hbm_ref_clk1]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins axi_decoupler/S_AXI]
  connect_bd_intf_net -intf_net sys_clk0_0_1 [get_bd_intf_pins sys_clk0_0] [get_bd_intf_pins axi_noc_mc_ddr4_0/sys_clk0]
  connect_bd_intf_net -intf_net sys_clk0_1_1 [get_bd_intf_pins sys_clk0_1] [get_bd_intf_pins axi_noc_mc_ddr4_1/sys_clk0]

  # Create port connections
  connect_bd_net -net Net [get_bd_pins logic0/dout] [get_bd_pins cips/cpm_irq1] [get_bd_pins cips/cpm_irq0] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst]
  connect_bd_net -net RP2_Dout [get_bd_pins RP2/Dout] [get_bd_pins Dout1]
  connect_bd_net -net axi_decoupler_gpio_io_o [get_bd_pins axi_decoupler/gpio_io_o] [get_bd_pins RP1/Din] [get_bd_pins RP2/Din]
  connect_bd_net -net cips_cpm_pcie_noc_axi0_clk [get_bd_pins cips/cpm_pcie_noc_axi0_clk] [get_bd_pins axi_noc_cips/aclk0]
  connect_bd_net -net cips_cpm_pcie_noc_axi1_clk [get_bd_pins cips/cpm_pcie_noc_axi1_clk] [get_bd_pins axi_noc_cips/aclk1]
  connect_bd_net -net cips_noc_pmc_axi_axi0_clk [get_bd_pins cips/noc_pmc_axi_axi0_clk] [get_bd_pins axi_noc_cips/aclk3]
  connect_bd_net -net cips_pl0_ref_clk [get_bd_pins cips/pl0_ref_clk] [get_bd_pins clk_wizard_0/clk_in1]
  connect_bd_net -net cips_pl0_resetn [get_bd_pins cips/pl0_resetn] [get_bd_pins proc_sys_reset_0/ext_reset_in] [get_bd_pins clk_wizard_0/resetn]
  connect_bd_net -net cips_pl2_ref_clk [get_bd_pins cips/pl2_ref_clk] [get_bd_pins cips/dma0_intrfc_clk] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net cips_pmc_axi_noc_axi0_clk [get_bd_pins cips/pmc_axi_noc_axi0_clk] [get_bd_pins axi_noc_cips/aclk2]
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins clk_wizard_0/clk_out1] [get_bd_pins slowest_sync_clk] [get_bd_pins proc_sys_reset_0/slowest_sync_clk] [get_bd_pins axi_decoupler/s_axi_aclk] [get_bd_pins axi_noc_cips/aclk4] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net clk_wizard_0_locked [get_bd_pins clk_wizard_0/locked] [get_bd_pins proc_sys_reset_0/dcm_locked]
  connect_bd_net -net proc_sys_reset_0_interconnect_aresetn [get_bd_pins proc_sys_reset_0/interconnect_aresetn] [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins proc_sys_reset_0/peripheral_aresetn] [get_bd_pins peripheral_aresetn] [get_bd_pins axi_decoupler/s_axi_aresetn] [get_bd_pins smartconnect_0/aresetn]
  connect_bd_net -net proc_sys_reset_1_interconnect_aresetn [get_bd_pins proc_sys_reset_1/interconnect_aresetn] [get_bd_pins cips/dma0_intrfc_resetn]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins logic1/dout] [get_bd_pins cips/dma0_mgmt_cpl_rdy] [get_bd_pins cips/dma0_st_rx_msg_tready] [get_bd_pins cips/dma0_tm_dsc_sts_rdy] [get_bd_pins proc_sys_reset_0/aux_reset_in]
  connect_bd_net -net xlslice_0_Dout [get_bd_pins RP1/Dout] [get_bd_pins Dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
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


  # Create interface ports
  set CH0_DDR4_0_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_0 ]

  set CH0_DDR4_0_1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 CH0_DDR4_0_1 ]

  set gt_pciea1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:gt_rtl:1.0 gt_pciea1 ]

  set gt_refclk0_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 gt_refclk0_0 ]

  set hbm_ref_clk_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $hbm_ref_clk_0

  set hbm_ref_clk_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 hbm_ref_clk_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $hbm_ref_clk_1

  set sys_clk0_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_clk0_0

  set sys_clk0_1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_clk0_1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {200000000} \
   ] $sys_clk0_1


  # Create ports

  # Create instance: static_region
  create_hier_cell_static_region [current_bd_instance .] static_region

  # Create instance: RP1
  create_hier_cell_RP1 [current_bd_instance .] RP1

  # Create instance: RP2
  create_hier_cell_RP2 [current_bd_instance .] RP2

  # Create instance: RP3
  create_hier_cell_RP3 [current_bd_instance .] RP3

  # Create interface connections
  connect_bd_intf_net -intf_net RP1_M00_INI [get_bd_intf_pins RP1/M00_INI] [get_bd_intf_pins static_region/S00_INI]
  connect_bd_intf_net -intf_net S00_INIS_1 [get_bd_intf_pins RP2/S00_INIS] [get_bd_intf_pins RP1/M01_INIS]
  connect_bd_intf_net -intf_net S00_INIS_2 [get_bd_intf_pins RP1/S00_INIS] [get_bd_intf_pins RP2/M01_INIS]
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_pins RP1/S00_INI] [get_bd_intf_pins static_region/M04_INI]
  connect_bd_intf_net -intf_net S01_INI_1 [get_bd_intf_pins static_region/S01_INI] [get_bd_intf_pins RP2/M00_INI]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_0_CH0_DDR4_0 [get_bd_intf_pins static_region/CH0_DDR4_0_0] [get_bd_intf_ports CH0_DDR4_0_0]
  connect_bd_intf_net -intf_net axi_noc_mc_ddr4_1_CH0_DDR4_0 [get_bd_intf_pins static_region/CH0_DDR4_0_1] [get_bd_intf_ports CH0_DDR4_0_1]
  connect_bd_intf_net -intf_net cips_PCIE0_GT [get_bd_intf_ports gt_pciea1] [get_bd_intf_pins static_region/gt_pciea1]
  connect_bd_intf_net -intf_net gt_refclk0_0_1 [get_bd_intf_ports gt_refclk0_0] [get_bd_intf_pins static_region/gt_refclk0_0]
  connect_bd_intf_net -intf_net hbm_ref_clk_0_1 [get_bd_intf_ports hbm_ref_clk_0] [get_bd_intf_pins static_region/hbm_ref_clk_0]
  connect_bd_intf_net -intf_net hbm_ref_clk_1_1 [get_bd_intf_ports hbm_ref_clk_1] [get_bd_intf_pins static_region/hbm_ref_clk_1]
  connect_bd_intf_net -intf_net static_region_M05_INI [get_bd_intf_pins static_region/M05_INI] [get_bd_intf_pins RP2/S00_INI]
  connect_bd_intf_net -intf_net sys_clk0_0_1 [get_bd_intf_ports sys_clk0_0] [get_bd_intf_pins static_region/sys_clk0_0]
  connect_bd_intf_net -intf_net sys_clk0_1_1 [get_bd_intf_ports sys_clk0_1] [get_bd_intf_pins static_region/sys_clk0_1]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins static_region/slowest_sync_clk] [get_bd_pins RP1/aclk] [get_bd_pins RP2/aclk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins static_region/peripheral_aresetn] [get_bd_pins RP1/aresetn] [get_bd_pins RP2/aresetn]
  connect_bd_net -net static_region_Dout [get_bd_pins static_region/Dout] [get_bd_pins RP1/decouple]
  connect_bd_net -net static_region_Dout1 [get_bd_pins static_region/Dout1] [get_bd_pins RP2/decouple]

  # Create address segments
  assign_bd_address -offset 0x020180000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_decoupler/S_AXI/Reg] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM0_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM15_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM7_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_cips/S00_AXI/HBM9_PC1] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force
  assign_bd_address -offset 0xF1220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0xF2100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x020180020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RP2/RP2_DFX/rmBase_0/s_axi_CTRL_BUS/Reg] -force
  assign_bd_address -offset 0x020180010000 -range 0x00010000 -with_name SEG_rmBase_0_Reg_1 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs RP1/RP1_DFX/rmBase_0/s_axi_CTRL_BUS/Reg] -force
  assign_bd_address -offset 0x020180000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_decoupler/S_AXI/Reg] -force
  assign_bd_address -offset 0x004000000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM0_PC0] -force
  assign_bd_address -offset 0x004040000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM0_PC1] -force
  assign_bd_address -offset 0x004500000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM10_PC0] -force
  assign_bd_address -offset 0x004540000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM10_PC1] -force
  assign_bd_address -offset 0x004580000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM11_PC0] -force
  assign_bd_address -offset 0x0045C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM11_PC1] -force
  assign_bd_address -offset 0x004600000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM12_PC0] -force
  assign_bd_address -offset 0x004640000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM12_PC1] -force
  assign_bd_address -offset 0x004680000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM13_PC0] -force
  assign_bd_address -offset 0x0046C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM13_PC1] -force
  assign_bd_address -offset 0x004700000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM14_PC0] -force
  assign_bd_address -offset 0x004740000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM14_PC1] -force
  assign_bd_address -offset 0x004780000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM15_PC0] -force
  assign_bd_address -offset 0x0047C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM15_PC1] -force
  assign_bd_address -offset 0x004080000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM1_PC0] -force
  assign_bd_address -offset 0x0040C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM1_PC1] -force
  assign_bd_address -offset 0x004100000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM2_PC0] -force
  assign_bd_address -offset 0x004140000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM2_PC1] -force
  assign_bd_address -offset 0x004180000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM3_PC0] -force
  assign_bd_address -offset 0x0041C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM3_PC1] -force
  assign_bd_address -offset 0x004200000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM4_PC0] -force
  assign_bd_address -offset 0x004240000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM4_PC1] -force
  assign_bd_address -offset 0x004280000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM5_PC0] -force
  assign_bd_address -offset 0x0042C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM5_PC1] -force
  assign_bd_address -offset 0x004300000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM6_PC0] -force
  assign_bd_address -offset 0x004340000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM6_PC1] -force
  assign_bd_address -offset 0x004380000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM7_PC0] -force
  assign_bd_address -offset 0x0043C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM7_PC1] -force
  assign_bd_address -offset 0x004400000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM8_PC0] -force
  assign_bd_address -offset 0x004440000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM8_PC1] -force
  assign_bd_address -offset 0x004480000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM9_PC0] -force
  assign_bd_address -offset 0x0044C0000000 -range 0x40000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_cips/S01_AXI/HBM9_PC1] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S01_INI/C1_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S01_INI/C1_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_1/S01_INI/C1_DDR_CH2] -force
  assign_bd_address -offset 0xFFA80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_0] -force
  assign_bd_address -offset 0xFFA90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_1] -force
  assign_bd_address -offset 0xFFAA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_2] -force
  assign_bd_address -offset 0xFFAB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_3] -force
  assign_bd_address -offset 0xFFAC0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_4] -force
  assign_bd_address -offset 0xFFAD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_5] -force
  assign_bd_address -offset 0xFFAE0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_6] -force
  assign_bd_address -offset 0xFFAF0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_7] -force
  assign_bd_address -offset 0x000100800000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0] -force
  assign_bd_address -offset 0x000100D10000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti] -force
  assign_bd_address -offset 0x000100D00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg] -force
  assign_bd_address -offset 0x000100D30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm] -force
  assign_bd_address -offset 0x000100D20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu] -force
  assign_bd_address -offset 0x000100D50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti] -force
  assign_bd_address -offset 0x000100D40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg] -force
  assign_bd_address -offset 0x000100D70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm] -force
  assign_bd_address -offset 0x000100D60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu] -force
  assign_bd_address -offset 0x000100CA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti] -force
  assign_bd_address -offset 0x000100C60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela] -force
  assign_bd_address -offset 0x000100C30000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf] -force
  assign_bd_address -offset 0x000100C20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun] -force
  assign_bd_address -offset 0x000100F80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm] -force
  assign_bd_address -offset 0x000100FA0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a] -force
  assign_bd_address -offset 0x000100FD0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d] -force
  assign_bd_address -offset 0x000100F40000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a] -force
  assign_bd_address -offset 0x000100F50000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b] -force
  assign_bd_address -offset 0x000100F60000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c] -force
  assign_bd_address -offset 0x000100F70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d] -force
  assign_bd_address -offset 0x000100F20000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun] -force
  assign_bd_address -offset 0x000100F00000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom] -force
  assign_bd_address -offset 0x000100B80000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm] -force
  assign_bd_address -offset 0x000100B70000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm] -force
  assign_bd_address -offset 0x000100980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm] -force
  assign_bd_address -offset 0xFC000000 -range 0x01000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_cpm] -force
  assign_bd_address -offset 0xFF5E0000 -range 0x00300000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_crl_0] -force
  assign_bd_address -offset 0x000101260000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_crp_0] -force
  assign_bd_address -offset 0xFF0B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2] -force
  assign_bd_address -offset 0xFF020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_i2c_0] -force
  assign_bd_address -offset 0xFF030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_i2c_1] -force
  assign_bd_address -offset 0xFF360000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3] -force
  assign_bd_address -offset 0xFF370000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4] -force
  assign_bd_address -offset 0xFF380000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5] -force
  assign_bd_address -offset 0xFF3A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6] -force
  assign_bd_address -offset 0xFF320000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc] -force
  assign_bd_address -offset 0xFF390000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf] -force
  assign_bd_address -offset 0xFF310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm] -force
  assign_bd_address -offset 0xFF9B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0] -force
  assign_bd_address -offset 0xFF0A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0] -force
  assign_bd_address -offset 0xFF080000 -range 0x00020000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0] -force
  assign_bd_address -offset 0xFF410000 -range 0x00100000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0] -force
  assign_bd_address -offset 0xFF510000 -range 0x00040000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0] -force
  assign_bd_address -offset 0xFF990000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0] -force
  assign_bd_address -offset 0xFF960000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl] -force
  assign_bd_address -offset 0xFFFC0000 -range 0x00040000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0] -force
  assign_bd_address -offset 0xFF980000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0] -force
  assign_bd_address -offset 0x0001011E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes] -force
  assign_bd_address -offset 0x0001011F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl] -force
  assign_bd_address -offset 0x0001012D0000 -range 0x00001000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0] -force
  assign_bd_address -offset 0x0001012B0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0] -force
  assign_bd_address -offset 0x0001011C0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0] -force
  assign_bd_address -offset 0x0001011D0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1] -force
  assign_bd_address -offset 0x000101250000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache] -force
  assign_bd_address -offset 0x000101240000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl] -force
  assign_bd_address -offset 0x000101110000 -range 0x00050000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0] -force
  assign_bd_address -offset 0x000101020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_gpio_0] -force
  assign_bd_address -offset 0x000100280000 -range 0x00001000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0] -force
  assign_bd_address -offset 0x000101010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ospi_0] -force
  assign_bd_address -offset 0x000100310000 -range 0x00008000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0] -force
  assign_bd_address -offset 0xC0000000 -range 0x20000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0] -force
  assign_bd_address -offset 0x000102000000 -range 0x00020000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram] -force
  assign_bd_address -offset 0x000100240000 -range 0x00020000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr] -force
  assign_bd_address -offset 0x000100200000 -range 0x00040000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr] -force
  assign_bd_address -offset 0x000106000000 -range 0x02000000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi] -force
  assign_bd_address -offset 0x000101200000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa] -force
  assign_bd_address -offset 0x0001012A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0] -force
  assign_bd_address -offset 0x000101040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sd_0] -force
  assign_bd_address -offset 0x000101210000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha] -force
  assign_bd_address -offset 0x000101220000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot] -force
  assign_bd_address -offset 0x000102100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_slave_boot_stream] -force
  assign_bd_address -offset 0x000101270000 -range 0x00030000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0] -force
  assign_bd_address -offset 0x000100083000 -range 0x00001000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0] -force
  assign_bd_address -offset 0x000100283000 -range 0x00001000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0] -force
  assign_bd_address -offset 0x000101230000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng] -force
  assign_bd_address -offset 0x0001012F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0] -force
  assign_bd_address -offset 0x000101310000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0] -force
  assign_bd_address -offset 0x000101300000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0] -force
  assign_bd_address -offset 0xFFC90000 -range 0x0000F000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg] -force
  assign_bd_address -offset 0xFFE90000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global] -force
  assign_bd_address -offset 0xFFEB0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global] -force
  assign_bd_address -offset 0xFFE00000 -range 0x00040000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global] -force
  assign_bd_address -offset 0xFF9A0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0] -force
  assign_bd_address -offset 0xFF000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0] -force
  assign_bd_address -offset 0xFF010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_1] -force
  assign_bd_address -offset 0xFF130000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0] -force
  assign_bd_address -offset 0xFF140000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0] -force
  assign_bd_address -offset 0xFF040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_spi_0] -force
  assign_bd_address -offset 0xFF0E0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0] -force
  assign_bd_address -offset 0xFF0F0000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1] -force
  assign_bd_address -offset 0xFF100000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2] -force
  assign_bd_address -offset 0xFF110000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3] -force
  assign_bd_address -offset 0x020180020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs RP2/RP2_DFX/rmBase_0/s_axi_CTRL_BUS/Reg] -force
  assign_bd_address -offset 0x020180010000 -range 0x00010000 -with_name SEG_rmBase_0_Reg_1 -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs RP1/RP1_DFX/rmBase_0/s_axi_CTRL_BUS/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces static_region/cips/PMC_NOC_AXI_0] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces static_region/cips/PMC_NOC_AXI_0] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces static_region/cips/PMC_NOC_AXI_0] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces RP1/RP1_DFX/rmBase_0/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces RP1/RP1_DFX/rmBase_0/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces RP1/RP1_DFX/rmBase_0/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces RP2/RP2_DFX/rmBase_0/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_CH1] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces RP2/RP2_DFX/rmBase_0/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_0/S00_INI/C0_DDR_LOW0] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces RP2/RP2_DFX/rmBase_0/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs static_region/axi_noc_mc_ddr4_1/S00_INI/C0_DDR_CH2] -force

  # Exclude Address Segments
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_4]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_5]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_6]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_adma_7]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_cti]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_dbg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_etm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a720_pmu]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_cti]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_dbg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_etm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_a721_pmu]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_cti]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_ela]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_etf]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_apu_fun]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_atm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2a]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_cti2d]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2a]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2b]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2c]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_ela2d]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_fun]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_cpm_rom]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_atm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_fpd_stm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_coresight_lpd_atm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_cpm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_crl_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_crp_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_gpio_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_i2c_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_i2c_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_4]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_5]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_6]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_pmc_nobuf]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ipi_psm]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_secure_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_iou_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_lpd_xppu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ctrl]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ocm_ram_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ocm_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_aes]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_bbram_ctrl]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfi_cframe_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_cfu_apb_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_dma_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_cache]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_efuse_ctrl]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_global_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_gpio_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_iomodule_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ospi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ppu1_mdm_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_qspi_ospi_flash_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_data_cntlr]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_instr_cntlr]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_ram_npi]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rsa]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_rtc_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sd_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sha]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_sysmon_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_inject_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_tmr_manager_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_trng]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_pmc_xppu_npi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_psm_global_reg]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_atcm_global]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_r5_1_btcm_global]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_r5_tcm_ram_global]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_rpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_sbsauart_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_scntr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_scntrs_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_spi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_1]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_0] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_ttc_3]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_apu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_crf_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_afi_2]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_cci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_gpv_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_maincci_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slave_xmpu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_slcr_secure_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmu_0]
  exclude_bd_addr_seg -target_address_space [get_bd_addr_spaces static_region/cips/CPM_PCIE_NOC_1] [get_bd_addr_segs static_region/cips/NOC_PMC_AXI_0/pspmc_0_psv_fpd_smmutcu_0]


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_gid_msg -ssname BD::TCL -id 2053 -severity "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."

