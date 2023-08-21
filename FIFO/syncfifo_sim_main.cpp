#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vsync_fifo.h"
#define VTOP Vsync_fifo

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
        top->winc = 0;
        top->rinc = 0;
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

        if(sim_time == 12 || sim_time == 52 || sim_time == 64) {
            top->winc = 1;
        }
        if(sim_time == 50 || sim_time == 62) {
            top->winc = 0;
        }

        // wclk上升沿改变wdata
        if(top->clk == 1)
            top->wdata = pclk_cnt;

        if(sim_time == 70 || sim_time == 80) {
            top->rinc = 1;
        }

        if(sim_time == 72){
            top->rinc = 0;
        }

        top->eval();

        if(sim_time >= 6 && top->clk == 1) {
            // monitoring something
            pclk_cnt++;
        }

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
