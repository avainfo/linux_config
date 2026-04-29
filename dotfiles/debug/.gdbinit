set pagination off
set print pretty on
set print elements 0
set breakpoint pending on
define bt10
  backtrace 10
end
define btfull
  backtrace full
end
define threads
  info threads
end
define regs
  info registers
end
define maps
  info proc mappings
end
