module APB_Master(
	input PCLK,               //Clock. The rising edge of PCLK times all transfers on the APB.
	input PRESETn,            //Reset. The APB reset signal is active LOW.
	input TRANSFER,           //APB enable signal. If high APB is activated else APB is disabled
	input [31:0] PRDATA,      //Read Data from slave.The selected slave drives this bus during read cycles when PWRITE is LOW.
	input PREADY,             //Ready. The slave uses this signal to extend an APB transfer.
	input [31:0] address,     // Address for the APB transaction.
	input [31:0] write_data,  // Data to be written (for write operations)
    input write_en,           // Write enable (1 for write, 0 for read)

	output reg PSELx,         //Select. The APB bridge unit generates this signal to each peripheral bus slave. It indicates that the slave device is selected and that a data transfer is required.
	output reg PENABLE,       //Enable. This signal indicates the second and subsequent cycles of an APB transfer.
	output reg PWRITE,		  //Direction. This signal indicates an APB write access when HIGH and an APB read access when LOW.
	output reg [31:0] PADDR,  //Address. This is the APB address bus. It is driven by the peripheral bus bridge unit.
	output reg [31:0] PWDATA, //Write data. This bus is driven by the peripheral bus bridge unit during write cycles when PWRITE is HIGH.
	output reg [31:0] read_data
	);

	localparam IDLE = 0;
	localparam SETUP = 1;
	localparam ACCESS = 2;

	reg [1:0] state , next_state;

    // STATE
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;  // Reset to IDLE state
        end else begin
            state <= next_state;  // Move to the next state
        end
    end

    // NEXT STATE
    always @(*) begin
        case (state)
            IDLE: begin
                if (TRANSFER) begin
                    next_state = SETUP;  // Move to SETUP on transfer signal
                end else begin
                    next_state = IDLE;   // Remain in IDLE
                end
            end

            SETUP: begin
                next_state = ACCESS;  // Go to ACCESS after setup
            end

            ACCESS: begin
                if (PREADY) begin
                    next_state = IDLE;  // Return to IDLE after successful transfer
                end else begin
                    next_state = ACCESS; // Remain in ACCESS until PREADY
                end
            end

            default: next_state = IDLE;  // Default state is IDLE
        endcase
    end

    // OUTPUT
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PADDR <= 32'b0;
            PSELx <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE <= 1'b0;
            PWDATA <= 32'b0;
            read_data <= 32'b0;
        end else begin
            case (state)
                IDLE: begin
                    PSELx <= 1'b0;
                    PENABLE <= 1'b0;
                end

                SETUP: begin
                    PADDR <= address;     // Set the address bus
                    PWRITE <= write_en;   // Set write direction based on write_en
                    PSELx <= 1'b1;        // Select the slave
                    PWDATA <= write_data; // Set the write data
                    PENABLE <= 1'b0;      // PENABLE is low in the setup phase
                end

                ACCESS: begin
                    PENABLE <= 1'b1;  // Enable data transfer in the access phase
                    if (!write_en && PREADY) begin
                        read_data <= PRDATA; // Capture the read data during read operation
                    end
                end
            endcase
        end
    end

endmodule