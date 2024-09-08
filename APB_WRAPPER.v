module APB_WRAPPER(
    input PCLK,            // Clock source
    input PRESETn,         // Active LOW Reset
    input TRANSFER,        // Signal to start the transfer (Handshake)
    input [31:0] address,  // Address for the APB transaction
    input [31:0] write_data, // Data to be written (for write operations)
    input write_en,        // Write enable (1 for write, 0 for read)

    output [31:0] read_data // Read data from the slave
);

    wire PSELx;
    wire PENABLE;
    wire PWRITE;
    wire [31:0] PADDR;
    wire [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire PREADY;

    APB_Master MASTER (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PREADY(PREADY),      
        .PRDATA(PRDATA),     
        .TRANSFER(TRANSFER),
        .address(address),
        .write_data(write_data),
        .write_en(write_en),
        .PADDR(PADDR),
        .PSELx(PSELx),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PWDATA(PWDATA),
        .read_data(read_data)
    );

    APB_Slave SLAVE (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .PSELx(PSELx),
        .PENABLE(PENABLE),
        .PREADY(PREADY),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA)
    );

endmodule
