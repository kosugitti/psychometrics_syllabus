rm(list=ls())

muG <- 50
effA <- 5
effB <- 3
effAB <- 7

a1b1 = muG + effA + effB + effAB
a1b2 = muG + effA - effB - effAB
a2b1 = muG - effA + effB - effAB
a2b2 = muG - effA - effB + effAB

