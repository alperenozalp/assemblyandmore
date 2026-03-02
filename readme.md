# Algorithms & Digital Design Portfolio

This repository contains low-level implementations of fundamental algorithms written in **Assembly** and a hardware design written in **Verilog**.
The goal of this project is to better understand how high-level concepts map directly to **machine-level execution** and **hardware logic**.

---

## 📂 Project Structure

```
.
├── ALU-Verilog/     # Arithmetic Logic Unit implemented in Verilog (FPGA-oriented)
├── Bubble Sort/     # Bubble Sort implementation in Assembly
└── Knapsack/        # 0/1 Knapsack implementation in Assembly
```

---

## 🔧 1. Bubble Sort (Assembly)

### 📌 Description

Implements the **Bubble Sort** algorithm entirely in Assembly language.

This version:

* Sorts an integer array in ascending order
* Demonstrates:

  * Memory addressing
  * Loop control with registers
  * Conditional branching
  * Manual swap operations

## 🎒 2. 0/1 Knapsack (Assembly)

### 📌 Description

Implements the classic **0/1 Knapsack optimization problem** using Assembly.

The program:

* Evaluates item weights and values
* Computes the maximum achievable value under a weight constraint
* Uses manual stack/register management to simulate algorithmic logic


## ⚙️ 3. ALU Design (Verilog)

### 📌 Description

A hardware-level **Arithmetic Logic Unit (ALU)** written in Verilog.

Supported operations typically include:

* Addition
* Subtraction
* AND / OR / XOR
* Shift operations
* Comparison

Designed to be synthesized on FPGA platforms (e.g., Basys-style boards).


