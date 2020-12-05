----------------------------------------------------------------------------

----------------- COMPONENTES -----------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;

PACKAGE componentes IS

	COMPONENT fsm IS
		PORT (
		clock, clear: IN std_logic;
		sinal_controle_ula: OUT std_logic;
		ativar_memoria, reset, ativar1, ativar2: OUT std_logic;
		endereco_ram: OUT integer RANGE 0 TO 7;
		endereco_rom: OUT integer RANGE 0 TO 7
		);
	END COMPONENT;

	COMPONENT registrador IS
		PORT(
		clock, reset, ativar1: IN std_logic;
		datain: IN std_logic_vector(7 DOWNTO 0);
		dataout: OUT std_logic_vector(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ula IS
		PORT(
		sinal_de_controle: IN std_logic;
		A: IN std_logic_vector(7 DOWNTO 0);
		B: IN std_logic_vector(7 DOWNTO 0);
		dataout: OUT std_logic_vector(7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ram IS
		PORT(
		ativar,clock: IN std_logic;
		endereco : IN integer RANGE 0 TO 7;
		datain : IN std_logic_vector (7 DOWNTO 0);
		dataout : OUT std_logic_vector (7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT rom IS
		PORT(
		endereco : IN integer RANGE 0 TO 7;
		dataout : OUT std_logic_vector (7 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT rom2 IS
		PORT(
		endereco : IN integer RANGE 0 TO 7;
		dataout : OUT std_logic_vector (7 DOWNTO 0)
		);
	END COMPONENT;
	
END componentes;

----------------- ULA -----------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY ula IS
	PORT(
	sinal_de_controle: IN std_logic;
	A: IN std_logic_vector(7 DOWNTO 0);
	B: IN std_logic_vector(7 DOWNTO 0);
	dataout: OUT std_logic_vector(7 DOWNTO 0)
	);
END ula;

ARCHITECTURE calcula OF ula IS
	BEGIN
	ula_calcula: PROCESS(sinal_de_controle)
		BEGIN
		CASE sinal_de_controle IS
		
			WHEN '1' =>
			dataout <= A + B; -- SOMA
			
			WHEN '0' =>
			dataout <= A and B; -- AND
			
			WHEN OTHERS => NULL;
			
		END CASE;
	END PROCESS ula_calcula;
END calcula;

----------------- RAM -----------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ram IS
	GENERIC(
	bits : integer := 8;
	linhas: integer := 8
	);
	PORT(
	ativar,clock: IN std_logic;
	endereco : IN integer RANGE 0 TO linhas-1;
	datain : IN std_logic_vector (bits-1 DOWNTO 0);
	dataout : OUT std_logic_vector (bits-1 DOWNTO 0)
	);
END ram;

ARCHITECTURE memoria OF ram IS

	TYPE vetor IS ARRAY (0 TO linhas-1) OF
	std_logic_vector (bits-1 DOWNTO 0);
	SIGNAL memory: vetor;
	
	BEGIN
	PROCESS(clock,ativar)
		BEGIN
		IF(ativar='1') THEN
			IF(clock'EVENT and clock='1') THEN
				memory(endereco) <= datain;
			END IF;
		END IF;
	END PROCESS;
	dataout <= memory(endereco);
END memoria;

----------------- ROM -----------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rom IS
	GENERIC(
	bits : integer := 8;
	linhas: integer := 8
	);
	PORT(
	endereco : IN integer RANGE 0 TO linhas-1;
	dataout : OUT std_logic_vector (bits-1 DOWNTO 0)
	);
END rom;

ARCHITECTURE mem OF rom IS

	TYPE vetor IS ARRAY (0 TO linhas-1) OF
	std_logic_vector (bits-1 DOWNTO 0);
	
	CONSTANT memory: vetor := (
	"00000110",
	"01010111",
	"00001111",
	"01011100",
	"00110000",
	"00011011",
	"00100010",
	"00001101");
	
	BEGIN
	
	dataout <= memory(endereco);
END mem;

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;

ENTITY rom2 IS
	GENERIC(
	bits : integer := 8;
	linhas: integer := 8
	);
	PORT(
	endereco : IN integer RANGE 0 TO linhas-1;
	dataout : OUT std_logic_vector (bits-1 DOWNTO 0)
	);
END rom2;

ARCHITECTURE mem2 OF rom2 IS

	TYPE vetor IS ARRAY (0 TO linhas-1) OF
	std_logic_vector (bits-1 DOWNTO 0);
	
	CONSTANT memory: vetor := (
	"00111010",
	"00010100",
	"00010110",
	"00110011",
	"01001111",
	"01001010",
	"01001110",
	"00010100");
	
	BEGIN
	dataout <= memory(endereco);
	
END mem2;

----------------- REGISTRADOR -----------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY registrador IS
	PORT(
	clock, reset, ativar1: IN std_logic;
	datain: IN std_logic_vector(7 DOWNTO 0);
	dataout: OUT std_logic_vector(7 DOWNTO 0)
	);
END registrador;

ARCHITECTURE reg OF registrador IS
	BEGIN
	PROCESS(clock, reset)
		BEGIN
		IF reset = '1' THEN
			dataout <= (OTHERS => '0');
		ELSIF clock'EVENT and clock = '1' THEN
			IF ativar1 = '1' THEN
				dataout <= datain;
			END IF;
		END IF;
	END PROCESS;
END reg;

----------------- PIPELINE -----------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY fsm IS
	PORT (
	clock, clear: IN std_logic;
	sinal_controle_ula: OUT std_logic;
	ativar_memoria, reset, ativar1, ativar2: OUT std_logic;
	endereco_ram: OUT integer RANGE 0 TO 7;
	endereco_rom: OUT integer RANGE 0 TO 7
	);
END fsm;

ARCHITECTURE state OF fsm IS

	TYPE estados IS (n0, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n14, n15);
	SIGNAL estado:estados;
	
	BEGIN
	PROCESS(clock,clear)
		BEGIN
		IF clear ='0'THEN
			estado <= n0;
		ELSE
			IF (clock 'EVENT AND clock = '1') THEN
				CASE estado IS
					WHEN n0 =>
					estado<=n1;
					sinal_controle_ula <= '1';
					endereco_ram <= 0;
					endereco_rom <= 0;
					ativar_memoria <= '1';
					
					WHEN n1 =>
					estado<=n2;
					sinal_controle_ula <= '0';
					endereco_ram <= 1;
					endereco_rom <= 1;
					ativar_memoria <= '1';
					
					WHEN n2 =>
					estado<=n3;
					sinal_controle_ula <= '1';
					endereco_ram <= 2;
					endereco_rom <= 2;
					ativar_memoria <= '1';
					
					WHEN n3 =>
					estado<=n4;
					sinal_controle_ula <= '0';
					endereco_ram <= 3;
					endereco_rom <= 3;
					ativar_memoria <= '1';
					
					WHEN n4 =>
					estado<=n5;
					sinal_controle_ula <= '1';
					endereco_ram <= 4;
					endereco_rom <= 4;
					ativar_memoria <= '1';
					
					WHEN n5 =>
					estado<=n6;
					sinal_controle_ula <= '0';
					endereco_ram <= 5;
					endereco_rom <= 5;
					ativar_memoria <= '1';
					
					WHEN n6 =>
					estado<=n7;
					sinal_controle_ula <= '1';
					endereco_ram <= 6;
					endereco_rom <= 6;
					ativar_memoria <= '1';
					
					WHEN n7 =>
					estado<=n8;
					sinal_controle_ula <= '0';
					endereco_ram <= 7;
					endereco_rom <= 7;
					ativar_memoria <= '1';
					
					WHEN n8 =>
					estado<=n9;
					endereco_ram <= 0;
					ativar_memoria <= '0';
					
					WHEN n9 =>
					estado<=n10;
					endereco_ram <= 1;
					ativar_memoria <= '0';
					
					WHEN n10 =>
					estado<=n11;
					endereco_ram <= 2;
					ativar_memoria <= '0';
					
					WHEN n11 =>
					estado<=n12;
					endereco_ram <= 3;
					ativar_memoria <= '0';
					
					WHEN n12 =>
					estado<=n13;
					endereco_ram <= 4;
					ativar_memoria <= '0';
					
					WHEN n13 =>
					estado<=n14;
					endereco_ram <= 5;
					ativar_memoria <= '0';
					
					WHEN n14 =>
					estado<=n15;
					endereco_ram <= 6;
					ativar_memoria <= '0';
					
					WHEN n15 =>
					estado<=n0;
					endereco_ram <= 7;
					ativar_memoria <= '0';
					
				END CASE;
			END IF;
		END IF;
	END PROCESS;
END state;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.ALL;
USE work.componentes.all;

ENTITY pipeline IS
	PORT (
	clock: IN std_logic;
	dataout: OUT std_logic_vector( 7 DOWNTO 0)
	);
END pipeline;

ARCHITECTURE main OF pipeline IS

	SIGNAL controle_ula: std_logic;
	SIGNAL ativar_ram: std_logic;
	SIGNAL sinal_endereco_ram: integer RANGE 0 TO 7;
	SIGNAL sinal_endereco_rom: integer RANGE 0 TO 7;
	SIGNAL sinal_ula_1: std_logic_vector(7 DOWNTO 0);
	SIGNAL sinal_ula_2: std_logic_vector(7 DOWNTO 0);
	SIGNAL ativar_sinal: std_logic;
	SIGNAL ativar_sinal_2: std_logic;
	SIGNAL sinal_reset: std_logic;
	SIGNAL rom1_reg1: std_logic_vector(7 DOWNTO 0);
	SIGNAL rom2_reg2: std_logic_vector(7 DOWNTO 0);
	SIGNAL dataout_ula: std_logic_vector(7 DOWNTO 0);
	SIGNAL reg_memoria: std_logic_vector(7 DOWNTO 0);

	BEGIN

	fsm_1: fsm PORT MAP(
		clock => clock,
		clear => '1',
		sinal_controle_ula => controle_ula,
		ativar_memoria => ativar_ram,
		ativar1 => ativar_sinal,
		ativar2 => ativar_sinal_2,
		reset => sinal_reset,
		endereco_ram => sinal_endereco_ram,
		endereco_rom => sinal_endereco_rom
	);

	reg1: registrador PORT MAP(
		clock => clock,
		reset => sinal_reset,
		ativar1 => ativar_sinal,
		datain => rom1_reg1,
		dataout => sinal_ula_1
	);

	reg2: registrador PORT MAP(
		clock => clock,
		reset => sinal_reset,
		ativar1 => ativar_sinal,
		datain => rom2_reg2,
		dataout => sinal_ula_2
	);

	reg3: registrador PORT MAP(
		clock => clock,
		reset => sinal_reset,
		ativar1 => ativar_sinal_2,
		datain => dataout_ula,
		dataout => reg_memoria
	);

	rom_1: rom PORT MAP(
		endereco => sinal_endereco_rom,
		dataout => rom1_reg1
	);

	rom_2: rom2 PORT MAP(
		endereco => sinal_endereco_rom,
		dataout => rom2_reg2
	);

	memoria: ram PORT MAP(
		ativar => ativar_ram,
		clock => clock,
		endereco => sinal_endereco_ram,
		datain => reg_memoria,
		dataout => dataout
	);

	ula_1: ula PORT MAP (
		sinal_de_controle => controle_ula,
		A => sinal_ula_1,
		B => sinal_ula_2,
		dataout => dataout_ula
	);

END main;

----------------------------------------------------------------------------