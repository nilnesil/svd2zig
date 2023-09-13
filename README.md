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
./zig-cache/bin/svd2zig path/to/svd/file path/to/output.zig
zig fmt path/to/output.zig
```

## Suggested location to find SVD file:

https://github.com/posborne/cmsis-svd

## How to use the generated code:

Have a look at [this blogpost](https://scattered-thoughts.net/writing/mmio-in-zig) for all the details,
a example modified from rbino's [STM32F407 blink project](https://github.com/rbino/zig-stm32-blink) to set and read some registers to make led blink on stm32f103c8t6:
```zig
// registers.zig is the generated file,
// which is generated from STM32F103xx.svd in "https://github.com/posborne/cmsis-svd/blob/master/data/STMicro/STM32F103xx.svd"
const regs = @import("registers.zig");

pub fn main() void {
    systemInit();

    // Enable GPIOC port
    regs.RCC.APB2ENR.modify(.{ .IOPCEN = 1 });

    // Set pin 13 mode to general purpose output
    regs.GPIOC.CRH.modify(.{
        .MODE13 = 0b01,
    });

    // Set pin 13
    regs.GPIOC.BSRR.modify(.{
        .BS13 = 1,
    });

    while (true) {
        // Read the LED state
        var leds_state = regs.GPIOC.IDR.read();
        // Set the LED output to the negation of the currrent output
        regs.GPIOC.ODR.modify(.{
            .ODR13 = ~leds_state.IDR13,
        });

        // Sleep for some time
        var i: u32 = 0;
        while (i < 6000000) {
            asm volatile ("nop");
            i += 1;
        }
    }
}

fn systemInit() void {
    // This init does these things:
    // - Enables the FPU coprocessor
    // - Sets the external oscillator to achieve a clock frequency of 72MHz
    // - Sets the correct PLL prescalers for that clock frequency
    // - Enables the flash data and instruction cache and sets the correct latency for 72MHz

    // Enable FPU coprocessor
    // WARN: currently not supported in qemu, comment if testing it there
    // regs.FPU_CPACR.CPACR.modify(.{ .CP = 0b11 });

    // Enable HSI
    regs.RCC.CR.modify(.{ .HSION = 1 });

    // Wait for HSI ready
    while (regs.RCC.CR.read().HSIRDY != 1) {}

    // Select HSI as clock source
    regs.RCC.CFGR.modify(.{ .SW = 0 });

    // Enable external high-speed oscillator (HSE)
    regs.RCC.CR.modify(.{ .HSEON = 1 });

    // Wait for HSE ready
    while (regs.RCC.CR.read().HSERDY != 1) {}

    // Set prescalers for 72 MHz: HPRE = 0, PPRE1 = DIV_2, PPRE2 = 0
    regs.RCC.CFGR.modify(.{ .PPRE1 = 0b100 });

    // Disable PLL before changing its configuration
    regs.RCC.CR.modify(.{ .PLLON = 0 });

    // Set PLL prescalers and HSE clock source
    regs.RCC.CFGR.modify(.{
        .PLLSRC = 1,
        .PLLMUL = 9,
    });

    // Enable PLL
    regs.RCC.CR.modify(.{ .PLLON = 1 });

    // Wait for PLL ready
    while (regs.RCC.CR.read().PLLRDY != 1) {}

    // Enable flash data and instruction cache and set flash latency to 2 wait states
    regs.FLASH.ACR.modify(.{ .LATENCY = 0b010 });

    // Select PLL as clock source
    regs.RCC.CFGR.modify(.{ .SW = 0b10 });

    // // Wait for PLL selected as clock source
    var cfgr = regs.RCC.CFGR.read();
    while (cfgr.SWS != 0b10) : (cfgr = regs.RCC.CFGR.read()) {}

    // Disable HSI
    regs.RCC.CR.modify(.{ .HSION = 0 });
}
```
## Zig Version
0.11.0


