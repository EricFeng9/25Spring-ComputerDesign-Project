-- Copyright 1986-2017 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2017.4 (win64) Build 2086221 Fri Dec 15 20:55:39 MST 2017
-- Date        : Fri May  9 02:24:31 2025
-- Host        : Lekge2025 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               E:/Sustech/25Spring_ComputerDesign/Project/25Spring-ComputerDesign-Project/cpu_1/cpu_1.srcs/sources_1/ip/clk_100mhz_to_10mhz/clk_100mhz_to_10mhz_stub.vhdl
-- Design      : clk_100mhz_to_10mhz
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcsg324-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity clk_100mhz_to_10mhz is
  Port ( 
    clk_out1 : out STD_LOGIC;
    clk_out2 : out STD_LOGIC;
    clk_in1 : in STD_LOGIC
  );

end clk_100mhz_to_10mhz;

architecture stub of clk_100mhz_to_10mhz is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "clk_out1,clk_out2,clk_in1";
begin
end;
