################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2024.2
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

##################################################################
# DESIGN PROCs
##################################################################

proc getIPNameFromFileName {fileName} {
    # Strip everything before and including the last slash "/"
    set fileName [file tail $fileName]
    
    # Remove the file extension
    set baseName [file rootname $fileName]
    
    # Replace underscores with colons
    set ipName [string map {"_" ":"} $baseName]
    
    # Correct the vendor field to replace the first colon with a period
    regsub {^([^:]+):} $ipName {\1.} ipName
    
    # Correct the last colon in the version number to a period
    # This targets the pattern where the version number is at the end, e.g., ":1:0"
    regsub {:(\d+):(\d+)$} $ipName {:\1.\2} ipName
    
    return $ipName
}

proc addIPToRepo {absProjPath absIPfilePath} {
    # construct abs IP repo path
    set absIPrepopath "$absProjPath/vckDFXplatform.ipdefs/IPs"
    set absIPrepopath [file normalize $absIPrepopath]

    # Check if the ZIP file exists
    if {![file exists $absIPfilePath]} {
        puts "Error: ZIP file $absIPfilePath does not exist."
        return -1
    }
    
    # Update the IP catalog to add the IP from the ZIP file to the specified repository
    set result [catch {update_ip_catalog -add_ip $absIPfilePath -repo_path $absIPrepopath} errMsg]
    
    # Check if the update was successful
    if {$result != 0} {
        puts "Error updating IP catalog with $absIPfilePath: $errMsg"
        return -1
    } else {
        puts "IP catalog updated successfully with $absIPfilePath. IP added to repository at $absIPrepopath."
    }
    
    return 0
}

proc checkIPExists {ip_vlnv} {
    # Search for the IP in the project's IP catalog based on its VLNV
    set ip_defs [get_ipdefs -all -filter {VLNV == $ip_vlnv}]
    
    # If the list of IP definitions is not empty, the IP exists
    if {[llength $ip_defs] > 0} {
        return 1
    } else {
        return 0 
    }
}

proc createBDs { design_name} {
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
}

proc create_root_design { parentCell design_name BD_freq ctlAddr ip_vlnv RM_name} {
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
  set M00_INI [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name M00_INI_internoc direction O left 0 right 0 } \
   } \
  M00_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {driver} \
   CONFIG.INI_STRATEGY {driver} \
   ] $M00_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports M00_INI]

  set S00_INI [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:inimm_rtl:1.0 -portmaps { \
   INTERNOC { physical_name S00_INI_internoc direction I left 0 right 0 } \
   } \
  S00_INI ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {64} \
   CONFIG.COMPUTED_STRATEGY {load} \
   CONFIG.INI_STRATEGY {load} \
   ] $S00_INI
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports S00_INI]

  set input_stream [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 -portmaps { \
   TDATA { physical_name input_stream_tdata direction I left 127 right 0 } \
   TDEST { physical_name input_stream_tdest direction I left 7 right 0 } \
   TID { physical_name input_stream_tid direction I left 0 right 0 } \
   TKEEP { physical_name input_stream_tkeep direction I left 15 right 0 } \
   TLAST { physical_name input_stream_tlast direction I left 0 right 0 } \
   TREADY { physical_name input_stream_tready direction O } \
   TSTRB { physical_name input_stream_tstrb direction I left 15 right 0 } \
   TUSER { physical_name input_stream_tuser direction I left 0 right 0 } \
   TVALID { physical_name input_stream_tvalid direction I } \
   } \
  input_stream ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ $BD_freq \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {1} \
   CONFIG.INSERT_VIP {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.PHASE {0.0} \
   CONFIG.TDATA_NUM_BYTES {16} \
   CONFIG.TDEST_WIDTH {8} \
   CONFIG.TID_WIDTH {1} \
   CONFIG.TUSER_WIDTH {1} \
   ] $input_stream
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports input_stream]

  set output_stream [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 -portmaps { \
   TDATA { physical_name output_stream_tdata direction O left 127 right 0 } \
   TDEST { physical_name output_stream_tdest direction O left 7 right 0 } \
   TID { physical_name output_stream_tid direction O left 0 right 0 } \
   TKEEP { physical_name output_stream_tkeep direction O left 15 right 0 } \
   TLAST { physical_name output_stream_tlast direction O left 0 right 0 } \
   TREADY { physical_name output_stream_tready direction I } \
   TSTRB { physical_name output_stream_tstrb direction O left 15 right 0 } \
   TUSER { physical_name output_stream_tuser direction O left 0 right 0 } \
   TVALID { physical_name output_stream_tvalid direction O } \
   } \
  output_stream ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ $BD_freq \
   CONFIG.INSERT_VIP {0} \
   CONFIG.PHASE {0.0} \
   ] $output_stream
  set_property HDL_ATTRIBUTE.LOCKED {TRUE} [get_bd_intf_ports output_stream]


  # Create ports
  set aclk1 [ create_bd_port -dir I -type clk -freq_hz $BD_freq aclk1 ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {output_stream:input_stream} \
   CONFIG.ASSOCIATED_RESET {ap_rst_n} \
   CONFIG.CLK_DOMAIN {/static_region/clk_wizard_0_clk_out1} \
   CONFIG.FREQ_TOLERANCE_HZ {0} \
   CONFIG.INSERT_VIP {0} \
   CONFIG.PHASE {0.0} \
 ] $aclk1
  set ap_rst_n [ create_bd_port -dir I -type rst ap_rst_n ]
  set_property -dict [ list \
   CONFIG.INSERT_VIP {0} \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $ap_rst_n

  # Create instance: ${ip_instance_name}, and set properties
  # set ${ip_instance_name} [ create_bd_cell -type ip -vlnv xilinx.com:hls:hlsRM2:1.0 ${ip_instance_name} ]
  set ip_instance_name "${RM_name}_0"
  set ip_instance [create_bd_cell -type ip -vlnv $ip_vlnv $ip_instance_name]

  # Create instance: axi_noc_0, and set properties
  set axi_noc_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_noc:1.0 axi_noc_0 ]
  set_property -dict [list \
    CONFIG.NUM_CLKS {2} \
    CONFIG.NUM_NMI {1} \
    CONFIG.NUM_NSI {1} \
  ] $axi_noc_0


  set_property -dict [ list \
   CONFIG.APERTURES {{0x201_8000_0000 1G}} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/M00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {driver} \
 ] [get_bd_intf_pins /axi_noc_0/M00_INI]

  set_property -dict [ list \
   CONFIG.CONNECTIONS {M00_INI {read_bw {500} write_bw {500}}} \
   CONFIG.NOC_PARAMS {} \
   CONFIG.CATEGORY {pl} \
 ] [get_bd_intf_pins /axi_noc_0/S00_AXI]

  set_property -dict [ list \
   CONFIG.INI_STRATEGY {load} \
   CONFIG.CONNECTIONS {M00_AXI {read_bw {500} write_bw {500} read_avg_burst {4} write_avg_burst {4}}} \
 ] [get_bd_intf_pins /axi_noc_0/S00_INI]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M00_AXI:S00_AXI} \
 ] [get_bd_pins /axi_noc_0/aclk0]

  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {} \
 ] [get_bd_pins /axi_noc_0/aclk1]

  # Create instance: smartconnect_0, and set properties
  set smartconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:smartconnect:1.0 smartconnect_0 ]
  set_property CONFIG.NUM_SI {1} $smartconnect_0


  # Create interface connections
  connect_bd_intf_net -intf_net S00_INI_1 [get_bd_intf_ports S00_INI] [get_bd_intf_pins axi_noc_0/S00_INI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_AXI [get_bd_intf_pins axi_noc_0/M00_AXI] [get_bd_intf_pins smartconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net axi_noc_0_M00_INI [get_bd_intf_ports M00_INI] [get_bd_intf_pins axi_noc_0/M00_INI]
  connect_bd_intf_net -intf_net ${ip_instance_name}_m_axi_DATA_BUS_ADDR [get_bd_intf_pins ${ip_instance_name}/m_axi_DATA_BUS_ADDR] [get_bd_intf_pins axi_noc_0/S00_AXI]
  connect_bd_intf_net -intf_net ${ip_instance_name}_output_stream [get_bd_intf_ports output_stream] [get_bd_intf_pins ${ip_instance_name}/output_stream]
  connect_bd_intf_net -intf_net input_stream_1 [get_bd_intf_ports input_stream] [get_bd_intf_pins ${ip_instance_name}/input_stream]
  connect_bd_intf_net -intf_net smartconnect_0_M00_AXI [get_bd_intf_pins smartconnect_0/M00_AXI] [get_bd_intf_pins ${ip_instance_name}/s_axi_CTRL_BUS]

  # Create port connections
  connect_bd_net -net aclk1_1 [get_bd_ports aclk1] [get_bd_pins axi_noc_0/aclk0] [get_bd_pins axi_noc_0/aclk1] [get_bd_pins ${ip_instance_name}/ap_clk] [get_bd_pins smartconnect_0/aclk]
  connect_bd_net -net ap_rst_n_1 [get_bd_ports ap_rst_n] [get_bd_pins ${ip_instance_name}/ap_rst_n]

  # Create address segments
  assign_bd_address -external -dict [list offset 0x00000000 range 0x80000000 name SEG_axi_noc_0_C0_DDR_LOW0x4 offset 0x000800000000 range 0x000380000000 name SEG_axi_noc_0_C0_DDR_LOW1x4] -target_address_space [get_bd_addr_spaces ${ip_instance_name}/Data_m_axi_DATA_BUS_ADDR] [get_bd_addr_segs M00_INI/Reg] -force
  assign_bd_address -offset $ctlAddr -range 0x00010000 -target_address_space [get_bd_addr_spaces S00_INI] [get_bd_addr_segs ${ip_instance_name}/s_axi_CTRL_BUS/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  #cleanup BD
  regenerate_bd_layout

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


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
set RM_name "RMconv5"

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

# get absolute paths
set IPname [getIPNameFromFileName $relIPfilePath]
set absProjPath [file normalize $relProjPath]
set absIPfilePath [file normalize $relIPfilePath]
# puts "Determined IP name: $IPname"

# Open Project
open_project "$absProjPath/vckDFXplatform.xpr"

# Update Compile order -> not needed?
update_compile_order -fileset sources_1

# # Constructing the absolute path to the top block design file then open the top block design
set bdFilePath "$absProjPath/vckDFXplatform.srcs/sources_1/bd/vckDFXplatform/vckDFXplatform.bd"
open_bd_design $bdFilePath

# add IP to local project repository
addIPToRepo $absProjPath $absIPfilePath
# todo: make check if IP is already present logic

# User HLS axi-lite control base address
# Do not change or it won't work
set baseAddress 0x020180000000

# Loop to create and then populate designs 1 through 9
for {set i 1} {$i <= 9} {incr i} {
    # Define the design name for this iteration
    set design_name_RP "RP${i}_${RM_name}"
    
    # Calculate the control address for this design
    set ctlAddr [expr $baseAddress + (0x10000 * $i)]
    set hexctlAddress [format "0x%016X" $ctlAddr]
    
    # Assuming parentCell is predefined or consistently '/'
    set parentCell "/"
    
    # CreateBDs to ensure the design is ready
    createBDs $design_name_RP
    
    # Now populate the design with components
    create_root_design $parentCell $design_name_RP $BD_freq $hexctlAddress $IPname $RM_name

    # set BD file string
    # set simAndSynthBDValue "RP${i}_RM1.bd:${design_name_RP}.bd"
    set simAndSynthBDValue "RP${i}_RMbase.bd:${design_name_RP}.bd"
    puts $simAndSynthBDValue

    # # Add BD to submodule
    current_bd_design [get_bd_designs vckDFXplatform]
    set_property -dict [list \
      CONFIG.LIST_SIM_BD $simAndSynthBDValue \
      CONFIG.LIST_SYNTH_BD $simAndSynthBDValue \
    ] [get_bd_cells RP${i}/RP${i}_DFX]
}

# set top as current design and validate
current_bd_design [get_bd_designs vckDFXplatform]
validate_bd_design
save_bd_design

# generate block design
generate_target all [get_files $absProjPath/vckDFXplatform.srcs/sources_1/bd/vckDFXplatform/vckDFXplatform.bd]

# Create Child DFX runs using Abstract Shell
for {set i 1} {$i <= 9} {incr i} {
  # Use the base name in constructing the run name dynamically
  set runName "${baseRunName}_${i}_impl_dfx"
  
  # Define the instance path dynamically based on the iteration
  # Adjust the below line as necessary, especially ${RM_name} which needs to be defined
  set instancePath "vckDFXplatform_i/RP${i}/RP${i}_DFX:RP${i}_${RM_name}_inst_0"
  
  # Create the run with the specified name, parent run, flow, and reconfigurable module instance
  create_run $runName -parent_run impl_dfx -flow {Vivado Implementation 2023} -rm_instance $instancePath
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
