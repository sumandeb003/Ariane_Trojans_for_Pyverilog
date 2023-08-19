# Notes:

1. `blocking.v` and `vectoradd.v` are the original trojan-free Verilog designs taken from the `verilogcode` directory of the [Pyverilog](https://github.com/PyHDI/Pyverilog) repository.

2. `blocking_TP1.v` contains the trojan type TP1 (DoS)

3. `vectoradd_TP1.v` contains the trojan type TP1 (DoS)

3. `vectoradd_TP2.v` contains the trojan type TP2 (Data Corruption)

4. `vectoradd_TP3.v` contains the trojan type TP3 (Address Manipulation)

5. The `A to Z of Using HW2VEC for Hardware Trojan Detection.ipynb` file mentions how I installed HW2VEC and used it for detecting hardware trojans (HTs). It refers to the file `use_case_2.py` in this repository.
6. **The directories `axi2apb_TP1`, `axi2apb_TP2`, and `axi2apb_TP3` contain the original trojans TP1, TP2 and TP3, respectively, inserted in the AXI-to-APB conversion module of the RISC-V-based Ariane SoC**. The original codebase of the Ariane SoC can be found [here](http://www.github.com/lowRISC/ariane).

7. If you use any of these trojans in your work, kindly cite the following paper:

Suman Deb, Anupam Chattopadhyay, Avi Mendelson. *A RISC-V SoC with Hardware Trojans: Case Study on Trojan-ing the On-Chip Protocol Conversion*. 31st IFIP/IEEE Conference on Very Large Scale Integration and System-on-Chip (VLSI-SoC), 2023. 
