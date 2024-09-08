module APB_tb;

    reg PCLK;
    reg PRESETn;
    reg TRANSFER;
    reg [31:0] address;
    reg [31:0] write_data;
    reg write_en;
    wire [31:0] read_data;

    // Instantiate APB Wrapper
    APB_WRAPPER WRAPPER (
        .PCLK(PCLK),
        .PRESETn(PRESETn),
        .TRANSFER(TRANSFER),
        .address(address),
        .write_data(write_data),
        .write_en(write_en),
        .read_data(read_data)
    );

    // Clock generation
    initial begin
        PCLK = 0;
        forever
        #5 PCLK = ~PCLK;
    end

    initial begin
        PRESETn = 0;
        TRANSFER = 0;
        address = 32'h0;
        write_data = 32'h0;
        write_en = 0;

        // Apply reset
        @(negedge PCLK);
        PRESETn = 1;
        @(negedge PCLK);

        // Test Write Operation (write to address 4)
        address = 32'h4;        
        write_data = 32'hABCD;  // Data to write
        write_en = 1;           
        TRANSFER = 1;           // Start transfer (setup phase)
        @(negedge PCLK);
        // Remain in transfer for the access phase
        @(negedge PCLK);        // Allow one more clock for access
        TRANSFER = 0;           // End transfer
        @(negedge PCLK);

        // Wait for a few clock cycles to ensure the write completes
        repeat(2) @(negedge PCLK);

        // Test Read Operation (read from address 4)
        address = 32'h4;        // Same address
        write_en = 0;           
        TRANSFER = 1;           // Start transfer (setup phase)
        @(negedge PCLK);
        // Remain in transfer for the access phase
        @(negedge PCLK);        // Allow one more clock for access
        TRANSFER = 0;           // End transfer
        @(negedge PCLK);

        // Wait for a few clock cycles for read completion
        @(negedge PCLK);
        @(negedge PCLK);

        // Display the read data value
        $display("Read Data: %h", read_data);  // Should be 32'hABCD

        $stop;
    end

endmodule
