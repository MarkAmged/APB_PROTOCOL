module APB_Slave (
    input PCLK,
    input PRESETn,
    input PSELx,
    input PENABLE,
    input PWRITE,
    input [31:0] PADDR,
    input [31:0] PWDATA,
    output reg PREADY,
    output reg [31:0] PRDATA
);

    reg [31:0] memory [0:7];

    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            PRDATA <= 32'b0;
            PREADY <= 1'b0;
        end
        else begin
            if (PSELx && PENABLE) begin
                if (PWRITE) begin
                    memory[PADDR[2:0]] <= PWDATA;
                    PREADY <= 1'b1;
                end
                else begin
                    PRDATA <= memory[PADDR[2:0]];
                    PREADY <= 1'b1;
                end
            end 
            else begin
                PREADY <= 1'b0;
            end
        end
    end
endmodule
