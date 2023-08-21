#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vasync_fifo.h"
#define VTOP Vasync_fifo

#include "verilated.h"
#include <stdio.h>
#include <iostream>

using namespace std;

#define MAX_SIM_TIME 300
uint64_t sim_time = 0;
uint64_t pclk_cnt = 0;

void sys_reset(VTOP *top, uint64_t &sim_time){
    
    top->wrst_n = 1;
    top->rrst_n = 1;

    if(sim_time >= 1 && sim_time < 6) {
        top->winc = 0;
        top->rinc = 0;
        top->wrst_n = 0;
        top->rrst_n = 0;
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
        if(sim_time % 5 == 0){
            top->wclk ^= 1;
        }
        
        if(sim_time % 4 == 0){
            top->rclk ^= 1;
        }

        if(sim_time == 12) {
            top->winc = 1;
        }

        // wclk上升沿改变wdata
        if(sim_time % 5 == 0 && top->wclk == 1)
            top->wdata = sim_time % 255;

        if(sim_time == 14) {
            top->rinc = 1;
        }

        top->eval();

        if(top->wclk == 1) {
            // monitoring something
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
