module sigmoid_plan(
    input [15:0] a,  
    output reg  [15:0] result,
	 input clk
);


reg [15:0]b,c,d; 
reg sign_a,sign_b,sign_c,sign_d,sign_result;
reg [4:0] exp_a ,exp_b,exp_c,exp_d,exp_result;
reg [9:0] mant_a,mant_b,mant_c,mant_d,mant_result;

reg [4:0]exp_diff;
reg [19:0] mant_product;
reg [10:0] mant_temp;

reg[3:0] state;

initial 
begin	
	state=4'b0000;
end


always@(posedge clk)
begin
case(state)
4'b0000: begin 
			if(a>= 16'b0000000000000000 &&  a< 16'b0011110000000000) begin b=16'b0011010000000000; state=3'b001; end
			else if(a>=16'b0011110000000000 && a<16'b0100000011000000) begin b=16'b0011000000000000; state =3'b001; end
			else if(a>=16'b0100000011000000 && a<16'b0100010100000000) begin b=16'b0010100000000000; state=3'b001; end
			else begin result=16'b0011110000000000; state=4'b0000; end
			end
			
4'b0001: begin
			sign_a = a[15];
			exp_a = a[14:10];
			mant_a = a[9:0];
			sign_b = b[15];
			exp_b = b[14:10];
			mant_b= b[9:0];
			state=4'b0010;
			end
			
4'b0010: begin	
		sign_c=sign_a ^ sign_b;
		state=4'b011;
		end
		
4'b0011: begin 
		exp_c= exp_a + exp_b - 5'b01111;
		state = 4'b0100;
		end

4'b0100: begin	
		 mant_product = {1'b1, mant_a} * {1'b1, mant_b};
			if (mant_product[19]==1'b1) begin
			mant_c = mant_product[19:10];
			exp_c=exp_c +  5'b00000;
        
		end 
		else begin
        mant_c = mant_product[19:10];
		end
    state = 4'b0101;
		end
		
4'b0101: begin 
			c={sign_c,exp_c,mant_c};
			state=4'b0110;
		end
		
4'b0110: begin 
			if(a>= 16'b0000000000000000 &&  a< 16'b0011110000000000) begin d=16'b0011100000000000; state=4'b0111; end
			else if(a>=16'b0011110000000000 && a<16'b0100000011000000) begin d=16'b0011100100000000; state =4'b0111; end
			else if(a>=16'b0100000011000000 && a<16'b0100010100000000) begin d=16'b0011101011000000; state=4'b0111; end
			else begin result=16'b0011110000000000; state=4'b0000; end
			end
			
4'b0111: begin if(c[14:0] < d[14:0]) begin b=c; c=d; d=b; end
			state=4'b1000;
			end
			
4'b1000: begin 
			if(c[14:0] < d[14:0]) begin b=c; c=d; d=b; end
			sign_c = c[15];
			exp_c = c[14:10];
			mant_c = c[9:0];
			sign_d = d[15];
			exp_d = d[14:10];
			mant_d= d[9:0];
			exp_result = exp_c;
			exp_diff=exp_c-exp_d;
			state=4'b1001;
			end
4'b1001: begin 
			mant_temp = {1'b1,mant_d};
			mant_temp=mant_temp >> exp_diff;
			state=4'b1010;
			end
4'b1010: begin
			if(sign_c == sign_d) begin mant_result=mant_temp[9:0] + mant_c; end
			sign_result = sign_c;			  
			state=4'b1011;
			end
4'b1011: begin            
            state = 4'b1100;	
			end
4'b1100:begin
			result = {sign_result, exp_result[4:0], mant_result[9:0]};
			state=4'b1101;
			end
4'b1101:begin
			b=16'b0;
			d=16'b0;
			c=16'b0;
			state=4'b0000;
			end
			
endcase
end
endmodule
