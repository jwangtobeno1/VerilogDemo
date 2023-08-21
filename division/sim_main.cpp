#ifndef SIMVCD
#define SIMVCD 1
#endif

#if SIMVCD
#include "verilated_vcd_c.h"
#endif

#include "Vodd_div.h"
#define VTOP Vodd_div

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
    
    top->clk_in ^= 1;
    top->eval();
#if SIMVCD
    contextp->timeInc(1);
    tfp->dump(contextp->time());
#endif
    top->clk_in ^= 1;
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
    top->clk_in = 0;
    top->rst = 0;

    int n = 6;
    while(n-- > 0) {clk_init();}
    cout << "begin simulation" << endl;
    top->rst = 1;
    
    // loop

    uint16_t loop = 0;
    while(!Verilated::gotFinish() && contextp->time() < MAX_SIM_TIME){

        clk_init();

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
