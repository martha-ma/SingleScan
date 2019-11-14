	component kernel is
		port (
			alarm_select_export     : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			clk_clk                 : in    std_logic                     := 'X';             -- clk
			epcs_flash_dclk         : out   std_logic;                                        -- dclk
			epcs_flash_sce          : out   std_logic;                                        -- sce
			epcs_flash_sdo          : out   std_logic;                                        -- sdo
			epcs_flash_data0        : in    std_logic                     := 'X';             -- data0
			laser_fifo_in_valid     : in    std_logic                     := 'X';             -- valid
			laser_fifo_in_data      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			laser_fifo_in_ready     : out   std_logic;                                        -- ready
			power_led_export        : out   std_logic;                                        -- export
			protocol_fifo_out_valid : out   std_logic;                                        -- valid
			protocol_fifo_out_data  : out   std_logic_vector(31 downto 0);                    -- data
			protocol_fifo_out_ready : in    std_logic                     := 'X';             -- ready
			reset_reset_n           : in    std_logic                     := 'X';             -- reset_n
			scl_export              : out   std_logic;                                        -- export
			sda_export              : inout std_logic                     := 'X';             -- export
			spird_fifo_in_valid     : in    std_logic                     := 'X';             -- valid
			spird_fifo_in_data      : in    std_logic_vector(31 downto 0) := (others => 'X'); -- data
			spird_fifo_in_ready     : out   std_logic;                                        -- ready
			spiwr_fifo_out_valid    : out   std_logic;                                        -- valid
			spiwr_fifo_out_data     : out   std_logic_vector(31 downto 0);                    -- data
			spiwr_fifo_out_ready    : in    std_logic                     := 'X';             -- ready
			status_led_export       : out   std_logic;                                        -- export
			w5500_cs_export         : out   std_logic;                                        -- export
			w5500_int_in_port       : in    std_logic                     := 'X';             -- in_port
			w5500_int_out_port      : out   std_logic;                                        -- out_port
			w5500_rst_export        : out   std_logic                                         -- export
		);
	end component kernel;

	u0 : component kernel
		port map (
			alarm_select_export     => CONNECTED_TO_alarm_select_export,     --      alarm_select.export
			clk_clk                 => CONNECTED_TO_clk_clk,                 --               clk.clk
			epcs_flash_dclk         => CONNECTED_TO_epcs_flash_dclk,         --        epcs_flash.dclk
			epcs_flash_sce          => CONNECTED_TO_epcs_flash_sce,          --                  .sce
			epcs_flash_sdo          => CONNECTED_TO_epcs_flash_sdo,          --                  .sdo
			epcs_flash_data0        => CONNECTED_TO_epcs_flash_data0,        --                  .data0
			laser_fifo_in_valid     => CONNECTED_TO_laser_fifo_in_valid,     --     laser_fifo_in.valid
			laser_fifo_in_data      => CONNECTED_TO_laser_fifo_in_data,      --                  .data
			laser_fifo_in_ready     => CONNECTED_TO_laser_fifo_in_ready,     --                  .ready
			power_led_export        => CONNECTED_TO_power_led_export,        --         power_led.export
			protocol_fifo_out_valid => CONNECTED_TO_protocol_fifo_out_valid, -- protocol_fifo_out.valid
			protocol_fifo_out_data  => CONNECTED_TO_protocol_fifo_out_data,  --                  .data
			protocol_fifo_out_ready => CONNECTED_TO_protocol_fifo_out_ready, --                  .ready
			reset_reset_n           => CONNECTED_TO_reset_reset_n,           --             reset.reset_n
			scl_export              => CONNECTED_TO_scl_export,              --               scl.export
			sda_export              => CONNECTED_TO_sda_export,              --               sda.export
			spird_fifo_in_valid     => CONNECTED_TO_spird_fifo_in_valid,     --     spird_fifo_in.valid
			spird_fifo_in_data      => CONNECTED_TO_spird_fifo_in_data,      --                  .data
			spird_fifo_in_ready     => CONNECTED_TO_spird_fifo_in_ready,     --                  .ready
			spiwr_fifo_out_valid    => CONNECTED_TO_spiwr_fifo_out_valid,    --    spiwr_fifo_out.valid
			spiwr_fifo_out_data     => CONNECTED_TO_spiwr_fifo_out_data,     --                  .data
			spiwr_fifo_out_ready    => CONNECTED_TO_spiwr_fifo_out_ready,    --                  .ready
			status_led_export       => CONNECTED_TO_status_led_export,       --        status_led.export
			w5500_cs_export         => CONNECTED_TO_w5500_cs_export,         --          w5500_cs.export
			w5500_int_in_port       => CONNECTED_TO_w5500_int_in_port,       --         w5500_int.in_port
			w5500_int_out_port      => CONNECTED_TO_w5500_int_out_port,      --                  .out_port
			w5500_rst_export        => CONNECTED_TO_w5500_rst_export         --         w5500_rst.export
		);

