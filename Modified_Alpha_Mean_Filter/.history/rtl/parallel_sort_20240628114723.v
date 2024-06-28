module parallel_sort #
(    
    parameter    DN = 25,    //数据个数
    parameter    DW = 8,    //数据位宽
    parameter    DW_sequence = $clog2(DN)
)
(
    input                               clk             , //时钟信号
    input                               rst_n           , //复位信号
    input                               sort_sig        , //排序开始信号
    input       [DW*DN-1:0]             data_unsort     , //未排序数据

    output reg  [DW_sequence*DN-1:0]    sequence_sorted , //根据输入数据排序后对应的序号
    output reg                          sort_finish       //排序结束信号
);

//------------------------------------------------
// Internal Variables
integer i,j;

reg        [DN-1:0]             temp[DN-1:0]        ; //排序过程变量
reg                             cnt_sort            ; //排序计数器
reg        [2:0]                FSM_state_sort      ; //状态机
reg        [DW_sequence*DN-1:0] sequence_sorted_temp; //各个序号对应的排序值


localparam    Initial   = 3'b001; //初始化
localparam    Sort      = 3'b010; //排序、计算和数
localparam    Convert   = 3'b100; //反转

//------------------------------------------------
// 排序状态机
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        FSM_state_sort <= Initial;
    else 
        case(FSM_state_sort)
        Initial:
            begin
            if(sort_sig)
                FSM_state_sort <= Sort;
            else
                FSM_state_sort <= Initial;
            end
        
        Sort:
            begin
            if(cnt_sort == 1'd1)
                FSM_state_sort <= Convert;
            else
                FSM_state_sort <= Sort;
            end
        
        Convert:
            begin
            FSM_state_sort <= Initial;
            end
        
        default: FSM_state_sort <= Initial;
        endcase 
end

//------------------------------------------------
// 排序计数器
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        cnt_sort <= 0;
    else if(FSM_state_sort == Initial)
        cnt_sort <= 0;
    else if(FSM_state_sort == Sort)
        cnt_sort <= cnt_sort + 1'b1;
    else
        cnt_sort <= cnt_sort;
end

//------------------------------------------------
// 排序结束信号
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        sort_finish <= 1'b0;
    else if(cnt_sort == 1'b1)
        sort_finish <= 1'b1;
    else
        sort_finish <= 1'b0;
end
    
//------------------------------------------------
// 并行比较
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n) begin    //复位信号
        for(i=0;i<DN;i=i+1) begin 
            temp[i] = 0;
        end
    end
    else if(sort_sig) begin    //排序开始信号
        for(i=0;i<DN;i=i+1) begin
            for(j=0;j<DN;j=j+1) begin
                if(i>j) begin
                    if(data_unsort[i*DW+:DW]>=data_unsort[j*DW+:DW]) 
                        temp[i][j] <= 1;
                    else    
                        temp[i][j] <= 0;
                end
                else begin
                    if(data_unsort[i*DW+:DW]>data_unsort[j*DW+:DW])
                        temp[i][j] <= 1;
                    else
                        temp[i][j] <= 0;
                end
            end
        end
    end
end

//------------------------------------------------
// 计算和数
always @(posedge clk or negedge rst_n)


//------------------------------------------------
// 计算排序后的原始序号
always @(posedge clk or negedge rst_n)
    if(!rst_n)
        sequence_sorted <= 0;
    else if(FSM_state_sort == Convert)
        for(i=0;i<DN;i=i+1) begin
            sequence_sorted[sequence_sorted_temp[i*DW_sequence+:DW_sequence]*DW_sequence+:DW_sequence] <= i; 
        end 
    else
        sequence_sorted <= sequence_sorted;
    
endmodule