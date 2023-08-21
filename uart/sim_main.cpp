#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vuart_tx.h"
#define VTOP Vuart_tx

#include "verilated_vpi.h"
#include "verilated.h"
#include <stdio.h>
#include <iostream>

using namespace std;

#define MAX_SIM_TIME 3000
uint64_t sim_time = 0;
uint64_t pclk_cnt = 0;

void sys_reset(VTOP *top, uint64_t &sim_time){
    
    top->rst_n = 1;

    if(sim_time >= 2 && sim_time < 6) {
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
            top->pi_flag = 0;
        }

        if(sim_time == 8 || sim_time == 500) {
            top->pi_data = 0xe7;
            top->pi_flag = 1;
            printf("clk is %d\n",top->clk);
            printf("work_en is %d\n"),
        }

        if(sim_time >= 6 && top->clk == 1) {
            // monitoring something
            pclk_cnt++;
        }

        if(sim_time <= 10)
            printf("sim_time is %d, pi_data is %d\n",sim_time , top->pi_data);

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
