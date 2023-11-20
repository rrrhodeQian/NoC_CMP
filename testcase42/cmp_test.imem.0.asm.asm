F0000000  // NOP  // Program for single packet read and write from processor       
81400000  // load datamem[0] into R10    			//load packet to be sent out in register file
81600001  // load datamem[1] into R11    			//load packet to be sent out in register file
81800002  // load datamem[2] into R12   			//load packet to be sent out in register file
8020C003  // load NIC[3] into R1  					//read the output channel status register -- output channel: CPU->NIC
8C200010  // VBNEZ r1, 4                    //if full, read again until empty
8540C002  // store r10 into NIC[2]					//send packet out to NIC
8020C003  // load NIC[3] into r1  					//read the output channel status register
8C20001c  // VBNEZ r1, 7                    //if full, read again until empty
8560C002  // store r11 into NIC[2]					//send packet out to NIC
8020C003  // load NIC[3] into r1  					//read the output channel status register
8C200028  // VBNEZ R1, 10                   //if full, read again until empty
8580C002  // store R12 into NIC[2]				//send packet out to NIC
8040C001  // load NIC[1] into R2					//read the input channel status register
88400034  // VBEZ R2, 13                  //if empty, read again
80A0C000  // store NIC[0] into R5	// LW
8040C001  // load NIC[1] into R2					//read the input channel status register
88400040  // VBEZ R2, 16
81E0C000  // store NIC[0] into R15	// LW
8040C001  // load NIC[1] into R2					//read the input channel status register
8840004C  // VBEZ R2, 19
8320C000  // store NIC[0] into R25
ABC5C801  // VANDab, R30, R5, R25; 101010 rD=11110(30) rA=00010(2) rB=00011(3) 000 00(8-bits) 000001(AND Operation)
ABEF0004  // VNOT, R31, R15
87C0000A  // VSD R30, 10                    //write R5 to datamem[5], data=mem[0]
87E0000B  // VSD R31, 11                    //write R15 to datamem[6], data=mem[0]
00000000  // NOP End Program 
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
00000000
