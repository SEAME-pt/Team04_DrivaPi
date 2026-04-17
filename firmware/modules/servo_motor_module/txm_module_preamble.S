    .text
    .align 4
    .syntax unified
    .section .preamble, "ax"

    .global __txm_module_preamble
    .global servo_motor_module_start
    .global _txm_module_thread_shell_entry
    .global _txm_module_callback_request_thread_entry

__txm_module_preamble:
    .dc.l      0x4D4F4455
    .dc.l      0x6
    .dc.l      0x1
    .dc.l      32
    .dc.l      0x44525653
    .dc.l      0x02000007
    .dc.l      _txm_module_thread_shell_entry - . - 0
    .dc.l      servo_motor_module_start - . - 0
    .dc.l      0
    .dc.l      6
    .dc.l      8192
    .dc.l      _txm_module_callback_request_thread_entry - . - 0
    .dc.l      6
    .dc.l      4096
    .dc.l      __code_size__
    .dc.l      __data_size__
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
    .dc.l      0
