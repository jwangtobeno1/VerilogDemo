#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vpingpong_buf.h"
#define VTOP Vpingpong_buf

#include "verilated.h"
#include <stdio.h>
#include <iostream>
#include <string>
using namespace std;

VerilatedContext* contextp = new VerilatedContext;
VTOP* top = new VTOP{contextp};
#if SIMVCD
    VerilatedVcdC* tfp = new VerilatedVcdC;
#endif

#define MAX_SIM_TIME 300

void clk_init(){
    
    top->clk ^= 1;
    top->eval();
#if SIMVCD
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif
    top->clk ^= 1;
    top->eval();
#if SIMVCD
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif

}

int main(int argc, char** argv, char** env) {

#if SIMVCD
    contextp->traceEverOn(true);
    top->trace(tfp,99);
    tfp->open("obj_dir/simx.vcd");
#endif

    contextp->commandArgs(argc, argv);

    // init
    top->clk = 0;
    top->rst_n = 0;

    top->wr_addr = 0;
    top->wr_data = 0;
    top->wr_en = 0;
    top->rd_addr = 0;
    top->switch_buf = 0;
    int n = 6;
    while(n-- > 0) {clk_init();}
    cout << contextp->time() << endl;
    top->rst_n = 1;
    
    // loop
    uint16_t wr_addr = 0;
    uint16_t wr_data = 0;
    uint8_t switch_buf = 0;
    uint8_t wr_en = 1;
    uint16_t rd_addr = 0;

    uint16_t loop = 0;
    while(!Verilated::gotFinish() && contextp->time() < MAX_SIM_TIME){

        top->wr_addr = wr_addr;
        top->wr_data = wr_data;
        top->wr_en = wr_en;
        top->rd_addr = rd_addr;
        top->switch_buf = switch_buf;

        clk_init();

        if(wr_addr >= 0 && wr_addr < 16) {
            wr_addr++;
        } else {
            wr_addr = 0;
        }

        if(wr_data <= 66) {
            wr_data++;
        } else {
            wr_data = 0;
        }

        if(wr_addr == 16) {
            switch_buf = 1;
        } else {
            switch_buf = 0;
        }

        if(loop == 15 || loop == 25)
            wr_en = 0;
        else
            wr_en = 1;
        
        if(rd_addr >= 0 && rd_addr < 16) {
            rd_addr++;
        } else {
            rd_addr = 0;
        }

        loop++;
    }

    top->final();
#if SIMVCD
    tfp->close();
#endif
    delete top;
    delete contextp;
    return 0;

}
