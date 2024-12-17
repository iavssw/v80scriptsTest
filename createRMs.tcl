proc createRPrm { i RMname IPname ctlAddr } {

  if { $i eq "" || $RMname eq "" } {
    catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "createRPrm() - Empty argument(s)!"}
    return
  }

  create_bd_design -boundary_from_container [get_bd_cells /RP${i}/RP${i}_DFX] $RMname

  # # Save current instance; Restore later
  # set oldCurInst [current_bd_instance .]
  # puts "oldCurInst: $oldCurInst"
  # Set New BD as current
  current_bd_design [get_bd_designs $RMname]

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.1 axi_noc_0 ]
  set_property -dict [list \
    CONFIG.MI_NAMES {} \
    CONFIG.MI_SIDEBAND_PINS {} \
    CONFIG.NUM_MI {1} \
    CONFIG.NUM_SI {2} \
    CONFIG.SI_SIDEBAND_PINS {0,0} \
    CONFIG.NUM_NMI {2} \
    CONFIG.NUM_NSI {1} \
  ] $axi_noc_0

  # AXI ctrl
  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_8000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {5} write_bw {5} read_avg_burst {1} write_avg_burst {1}}} \
   CONFIG.INI_STRATEGY {load} \
  ] [get_bd_intf_pins axi_noc_0/S00_INI]

  # AXI-MM
  # set AXI-MM BW here?
  set_property -dict [ list \
    CONFIG.INI_STRATEGY {driver} \
  ] [get_bd_intf_pins axi_noc_0/M00_INI]

  set_property -dict [ list \
    CONFIG.INI_STRATEGY {driver} \
  ] [get_bd_intf_pins axi_noc_0/M01_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M01_INI {read_bw {500} write_bw {500}}} \
   CONFIG.DEST_IDS {} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
  ] [get_bd_intf_pins axi_noc_0/S01_AXI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI:S00_AXI} \
  ] [get_bd_pins axi_noc_0/aclk0]

############################################################################################################

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_0

############################################################################################################

  # Create IP
  set baseName [create_bd_cell -type ip -vlnv $IPname $RMname]

############################################################################################################

  # Create interface connections
  connect_bd_intf_net -intf_net Conn11 [get_bd_intf_pins $baseName/input_stream1] [get_bd_intf_pins input_stream0]
  connect_bd_intf_net -intf_net Conn12 [get_bd_intf_pins $baseName/input_stream2] [get_bd_intf_pins input_stream1]
  connect_bd_intf_net -intf_net Conn21 [get_bd_intf_pins $baseName/output_stream1] [get_bd_intf_pins output_stream0]
  connect_bd_intf_net -intf_net Conn22 [get_bd_intf_pins $baseName/output_stream2] [get_bd_intf_pins output_stream1]
  connect_bd_intf_net -intf_net axi_noc_0_S00_AXI [get_bd_intf_pins smartconnect_0/S00_AXI] [get_bd_intf_pins axi_noc_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_S00_DFX_INI [get_bd_intf_pins S00_DFX_INI] [get_bd_intf_pins axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_DFX_INI [get_bd_intf_pins M00_DFX_INI] [get_bd_intf_pins axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M01_DFX_INI [get_bd_intf_pins M01_DFX_INI] [get_bd_intf_pins axi_noc_0/M01_INI]
  connect_bd_intf_net -intf_net rmBase_0_m_axi_DATA_BUS_ADDR0 [get_bd_intf_pins $baseName/m_axi_AXI_MM1] [get_bd_intf_pins axi_noc_0/S00_AXI]
  connect_bd_intf_net -intf_net rmBase_0_m_axi_DATA_BUS_ADDR1 [get_bd_intf_pins $baseName/m_axi_AXI_MM2] [get_bd_intf_pins axi_noc_0/S01_AXI]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins $baseName/s_axi_CTRL_BUS]

  # Create port connections
  connect_bd_net -net clk_wizard_0_clk_out1 [get_bd_pins rp_aclk] [get_bd_pins smartconnect_0/aclk] [get_bd_pins axi_noc_0/aclk0] [get_bd_pins $baseName/ap_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_aresetn [get_bd_pins rp_aresetn] [get_bd_pins smartconnect_0/aresetn] [get_bd_pins $baseName/ap_rst_n]

  # Create address segments: Hardcoded Addresses for DDR
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces $RMname/Data_m_axi_AXI_MM1] [get_bd_addr_segs M00_DFX_INI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces $RMname/Data_m_axi_AXI_MM1] [get_bd_addr_segs M00_DFX_INI/Reg_1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces $RMname/Data_m_axi_AXI_MM1] [get_bd_addr_segs M00_DFX_INI/Reg_2] -force
  assign_bd_address -offset 0x00000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces $RMname/Data_m_axi_AXI_MM2] [get_bd_addr_segs M01_DFX_INI/Reg] -force
  assign_bd_address -offset 0x050000000000 -range 0x80000000 -target_address_space [get_bd_addr_spaces $RMname/Data_m_axi_AXI_MM2] [get_bd_addr_segs M01_DFX_INI/Reg_1] -force
  assign_bd_address -offset 0x060000000000 -range 0x000800000000 -target_address_space [get_bd_addr_spaces $RMname/Data_m_axi_AXI_MM2] [get_bd_addr_segs M01_DFX_INI/Reg_2] -force
  assign_bd_address -offset $ctlAddr -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_DFX_INI] [get_bd_addr_segs $RMname/s_axi_CTRL_BUS/Reg] -force

  #cleanup BD
  regenerate_bd_layout
  validate_bd_design
  save_bd_design

  # Restore current instance
  # current_bd_design [get_bd_designs v80DFXplatform]
  # regenerate_bd_layout
}


##################################################################
# MAIN FLOW
##################################################################
# source ./create9bitstreams.tcl

##################################################################
# USER DEFINITION
##################################################################
# Define project relative path
set relProjPath "./vckDFXplatform"

# Define IP relative path
set relIPfilePath "./xilinx_com_hls_convKernel_1_0.zip"

# Define BD base name
# set RM_name "RMbase"
set RM_name "RMtesttt"

# Define child runs base name
set baseRunName "tile"

# Define Frequency
# 100MHz
set BD_freq 99999000
#200MHz
# set BD_freq 199998000

# Set number of threads of your machine
set numberOfThreads 10 

##################################################################
# Editiing Below may break stuff
##################################################################

# User HLS axi-lite control base address
# Do not change or it won't work
set baseAddress 0x020180000000

set IPname "xilinx.com:hls:rpRM:1.0"

for {set i 1} {$i <= 3} {incr i} {
  # Define the design name for this iteration
  set RPrmName "RP${i}_${RM_name}"

  # Calculate the control address for this design
  set ctlAddr [expr $baseAddress + (0x10000 * $i)]
  set hexctlAddress [format "0x%016X" $ctlAddr]

  createRPrm $i $RPrmName $IPname $hexctlAddress

  current_bd_design [get_bd_designs v80DFXplatform]

  # set simAndSynthBDValue "RP${i}_RM1.bd:${design_name_RP}.bd"
  set simAndSynthBDValue "RP${i}_DFX.bd:${RPrmName}.bd"

  # Add BD to submodule
  current_bd_design [get_bd_designs v80DFXplatform]
  set_property -dict [list \
    CONFIG.LIST_SIM_BD $simAndSynthBDValue \
    CONFIG.LIST_SYNTH_BD $simAndSynthBDValue \
  ] [get_bd_cells RP${i}/RP${i}_DFX]
}

current_bd_design [get_bd_designs v80DFXplatform]
validate_bd_design
save_bd_design

# generate block design
# generate_target all [get_files $absProjPath/vckDFXplatform.srcs/sources_1/bd/vckDFXplatform/vckDFXplatform.bd]
generate_target all [get_files  /mnt/sdb1/v80/HWrunsDFX/6_rp3DFX_test/prj.srcs/sources_1/bd/v80DFXplatform/v80DFXplatform.bd]

# Create Child DFX runs using Abstract Shell
for {set i 1} {$i <= 3} {incr i} {
  # Use the base name in constructing the run name dynamically
  set runName "${baseRunName}_${i}_impl_dfx"
  
  # Define the instance path dynamically based on the iteration
  # Adjust the below line as necessary, especially ${RM_name} which needs to be defined
  set instancePath "v80DFXplatform_i/RP${i}/RP${i}_DFX:RP${i}_${RM_name}_inst_0"
  
  # Create the run with the specified name, parent run, flow, and reconfigurable module instance
  create_run $runName -parent_run impl -flow {Vivado Implementation 2024} -rm_instance $instancePath
}

# force sync
save_bd_design

# Construct the launch_runs command using the baseRunName then trim trailing space
set runsToLaunch ""
for {set i 1} {$i <= 9} {incr i} {
  append runsToLaunch "${baseRunName}_${i}_impl_dfx "
}
set runsToLaunch [string trim $runsToLaunch]

puts $runsToLaunch

# Now, launch all runs dynamically constructed above
launch_runs $runsToLaunch -to_step write_device_image -jobs $numberOfThreads

# Loop through each run name and wait for it to complete
foreach runName $runsToLaunch {
    wait_on_run $runName
}