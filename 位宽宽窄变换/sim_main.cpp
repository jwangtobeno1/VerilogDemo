#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vwide2narrow.h"
#define VTOP Vwide2narrow

#include "verilated.h"
#include <stdio.h>
#include <iostream>

using namespace std;

#define MAX_SIM_TIME 300
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
        top->clk ^= 1;  // 2个sim_time一个周期

        top->eval();

        if(top->clk == 1){
            // monitoring something
            // cout << pclk_cnt << endl;
            pclk_cnt++;
        }

        top->wide_din = 0;
        if(pclk_cnt == 15) {
            top->wide_din = 0xf0;
        }
        if(pclk_cnt == 16) {
            top->wide_din = 0x65;
        }
        if(pclk_cnt == 17) {
            top->wide_din = 0x5a;
        }
        if(pclk_cnt == 18) {
            top->wide_din = 0x73;
        }
        if(pclk_cnt == 19) {
            top->wide_din = 0xc4;
        }
        if(pclk_cnt == 20) {
            top->wide_din = 0xd2;
        }
        if(pclk_cnt == 21) {
            top->wide_din = 0x1f;
        }
        if(pclk_cnt == 22) {
            top->wide_din = 0xbd;
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
