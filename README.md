# svd2zig

Generate [Zig](https://ziglang.org/) header files from
[CMSIS-SVD](http://www.keil.com/pack/doc/CMSIS/SVD/html/index.html) files for accessing MMIO
registers.

## Features

This is a fork of [svd4zig](https://github.com/rbino/svd4zig).

Features taken from rbino's `svd4zig`:
- This was the one used as a starting point
- 100% in Zig
- Naming conventions are taken from the datasheet (i.e. all caps), so it's easy to follow along
- Strong Assumptions™ in the svd are targeted towards STM32 devices (the original used a
  STM32F767ZG and STM32F407, this fork was developed with an STM32F103)
- The tool doesn't just output registers but also other information about the device (e.g.
  interrupts)
- Registers are modeled with packed structs (see [this
  post](https://scattered-thoughts.net/writing/mmio-in-zig) from the original authors)

New features:

## Build:

```
zig build -Drelease-safe
```

## Usage:

```
./zig-cache/bin/svd2zig path/to/svd/file > path/to/output.zig
zig fmt path/to/output.zig
```

## Suggested location to find SVD file:

https://github.com/posborne/cmsis-svd

## How to use the generated code:

Have a look at [this blogpost](https://scattered-thoughts.net/writing/mmio-in-zig) for all the details,
 a short example to set and read some registers:
```zig
// registers.zig is the generated file
const regs = @import("registers.zig");

// Enable HSI
regs.RCC.CR.modify(.{ .HSION = 1 });

// Wait for HSI ready
while (regs.RCC.CR.read().HSIRDY != 1) {}

// Select HSI as clock source
regs.RCC.CFGR.modify(.{ .SW0 = 0, .SW1 = 0 });

// Enable external high-speed oscillator (HSE)
regs.RCC.CR.modify(.{ .HSEON = 1 });

// Wait for HSE ready
while (regs.RCC.CR.read().HSERDY != 1) {}

```
## Zig Version
0.9.0


