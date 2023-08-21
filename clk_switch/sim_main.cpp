#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vclk_sw_ff.h"
#define VTOP Vclk_sw_ff

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
        top->clka ^= 1;

        if(sim_time % 2==0)
            top->clkb ^= 1;

        top->eval();

        if(top->clka == 1) {
            pclk_cnt++;
            // monitoring something
        }

        if(sim_time == 10)
            top->sel = 1;
        if(sim_time == 52)
            top->sel = 0;
        if(sim_time == 98)
            top->sel = 1;
        if(sim_time == 176)
            top->sel = 0;
        if(sim_time == 257)
            top->sel = 1;

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
