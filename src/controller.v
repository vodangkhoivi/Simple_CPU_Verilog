module controller(
    input clk,
    input rst,
    input [2:0] opcode,
    input zero,

    output reg sel,
    output reg rd,
    output reg ld_ir,
    output reg halt,
    output reg inc_pc,
    output reg ld_ac,
    output reg ld_pc,
    output reg wr,
    output reg data_e
);
    localparam INST_ADDR  = 3'd0;
    localparam INST_FETCH = 3'd1;
    localparam INST_LOAD  = 3'd2;
    localparam IDLE       = 3'd3;
    localparam OP_ADDR    = 3'd4;
    localparam OP_FETCH   = 3'd5;
    localparam ALU_OP     = 3'd6;
    localparam STORE      = 3'd7;
    localparam HLT = 3'b000;
    localparam SKZ = 3'b001;
    localparam ADD = 3'b010;
    localparam AND = 3'b011;
    localparam XOR = 3'b100;
    localparam LDA = 3'b101;
    localparam STO = 3'b110;
    localparam JMP = 3'b111;
    reg [2:0] state;
    reg [2:0] next_state;
    wire ALUOP;

    assign ALUOP = (opcode == ADD) ||
                   (opcode == AND) ||
                   (opcode == XOR) ||
                   (opcode == LDA);
    always @(posedge clk) begin
        if (rst) begin
            state <= INST_ADDR;
        end else begin
            state <= next_state;
        end
    end
    always @(*) begin
        case (state)

            INST_ADDR: begin
                next_state = INST_FETCH;
            end

            INST_FETCH: begin
                next_state = INST_LOAD;
            end

            INST_LOAD: begin
                next_state = IDLE;
            end

            IDLE: begin
                next_state = OP_ADDR;
            end

            OP_ADDR: begin
                if (opcode == HLT)
                    next_state = OP_ADDR;
                else
                    next_state = OP_FETCH;
            end

            OP_FETCH: begin
                next_state = ALU_OP;
            end

            ALU_OP: begin
                next_state = STORE;
            end

            STORE: begin
                next_state = INST_ADDR;
            end

            default: begin
                next_state = INST_ADDR;
            end

        endcase
    end
    always @(*) begin
        // Default values
        sel    = 1'b0;
        rd     = 1'b0;
        ld_ir  = 1'b0;
        halt   = 1'b0;
        inc_pc = 1'b0;
        ld_ac  = 1'b0;
        ld_pc  = 1'b0;
        wr     = 1'b0;
        data_e = 1'b0;

        case (state)

            INST_ADDR: begin
                sel = 1'b1;
            end

            INST_FETCH: begin
                sel = 1'b1;
                rd  = 1'b1;
            end

            INST_LOAD: begin
                sel   = 1'b1;
                rd    = 1'b1;
                ld_ir = 1'b1;
            end

            IDLE: begin
                sel   = 1'b1;
                rd    = 1'b1;
                ld_ir = 1'b1;
            end
            OP_ADDR: begin
                sel = 1'b0;

                if (opcode == HLT) begin
                    halt   = 1'b1;
                    inc_pc = 1'b0;
                end else begin
                    inc_pc = 1'b1;
                end
            end

            OP_FETCH: begin
                sel = 1'b0;

                if (ALUOP) begin
                    rd = 1'b1;
                end
            end

            ALU_OP: begin
                sel = 1'b0;

                if (ALUOP) begin
                    rd = 1'b1;
                end

                if ((opcode == SKZ) && (zero == 1'b1)) begin
                    inc_pc = 1'b1;
                end

                if (opcode == JMP) begin
                    ld_pc = 1'b1;
                end

                if (opcode == STO) begin
                    wr     = 1'b1;
                    data_e = 1'b1;
                end
            end

            STORE: begin
                sel = 1'b0;

                if (ALUOP) begin
                    rd    = 1'b1;
                    ld_ac = 1'b1;
                end

                if (opcode == JMP) begin
                    ld_pc = 1'b1;
                end

                if (opcode == STO) begin
                    wr     = 1'b1;
                    data_e = 1'b1;
                end
            end

            default: begin
                sel    = 1'b0;
                rd     = 1'b0;
                ld_ir  = 1'b0;
                halt   = 1'b0;
                inc_pc = 1'b0;
                ld_ac  = 1'b0;
                ld_pc  = 1'b0;
                wr     = 1'b0;
                data_e = 1'b0;
            end

        endcase
    end

endmodule
