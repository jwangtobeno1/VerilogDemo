#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vround_robin_arbiter.h"
#define VTOP Vround_robin_arbiter

#include "verilated.h"
#include <stdio.h>
#include <iostream>

using namespace std;

#define MAX_SIM_TIME 300
uint64_t sim_time = 0;
uint64_t pclk_cnt = 0;

void sys_reset(VTOP *top, uint64_t &sim_time){
    
    top->rst_n = 1;

    if(sim_time >= 1 && sim_time < 6) {
        top->rst_n = 0;
    }
}

int main(int argc, char** argv, char** env) {

    VerilatedContext* contextp = new VerilatedContext;
    VTOP* top = new VTOP{contextp};
#if SIMVCD
    VerilatedVcdC* tfp = new VerilatedVcdC;
#endif

#if SIMVCD
    contextp->traceEverOn(true);
    top->trace(tfp,99);
    tfp->open("waveform.vcd");
#endif

    contextp->commandArgs(argc, argv);

    // loop

    while(!Verilated::gotFinish() && sim_time < MAX_SIM_TIME){
        // 复位逻辑
        sys_reset(top, sim_time);

        // 测试输入逻辑
        top->clk ^= 1;

        top->eval();

        if(top->clk == 1) {
            pclk_cnt++;
            // monitoring something
            printf("top->grant is %d\n", top->grant);
        }

        if(sim_time == 10)
            top->req = 6;
        if(sim_time == 12)
            top->req = 7;
        if(sim_time == 14)
            top->req = 4;
        if(sim_time == 16)
            top->req = 1;
        if(sim_time == 18)
            top->req = 3;
        if(sim_time == 22)
            top->req = 15;
        if(sim_time == 24)
            top->req = 10;
        if(sim_time == 26)
            top->req = 5;

        tfp->dump(sim_time);
        sim_time++;
    }

    top->final();
#if SIMVCD
    tfp->close();
#endif
    delete top;
    delete contextp;
    return 0;

}
