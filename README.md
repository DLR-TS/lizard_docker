# cpplint_docker

This is a project offering a minimal docker project for doing code complexity 
analysis with (terryyin/lizard)[https://github.com/terryyin/lizard]

## Description 
With this project you can use the lizard tool to calculate code complexity.


## Getting started

This project requires make and docker installed and configured for your user.

1. Clone the project:
```bash
git clone git@gitlab.dlr.de:csa/lizard.git
```
2. Build the docker container:
```bash 
make build
```
3. Use lizard on a project using the provided make target:
```bash
make lizard CPP_PROJECT_DIRECTORY=$(realpath ./hello_world)
```
```bash
/home/akoerner/repos/csa/test/lizard git:(master) ✗ > make lizard CPP_PROJECT_DIRECTORY=$(realpath ./hello_world)

================================================
  NLOC    CCN   token  PARAM  length  location  
------------------------------------------------
       3      1     12      0       3 hello@4-6@./hello_world/src/hello.cpp
       1      1     10      1       1 main@3-3@./hello_world/hello_world.cpp
3 file analyzed.
==============================================================
NLOC    Avg.NLOC  AvgCCN  Avg.token  function_cnt    file
--------------------------------------------------------------
      1       0.0     0.0        0.0         0     ./hello_world/include/hello.h
      5       3.0     1.0       12.0         1     ./hello_world/src/hello.cpp
      2       1.0     1.0       10.0         1     ./hello_world/hello_world.cpp

===============================================================================================================
No thresholds exceeded (cyclomatic_complexity > 15 or length > 1000 or nloc > 1000000 or parameter_count > 100)
==========================================================================================
Total nloc   Avg.NLOC  AvgCCN  Avg.token   Fun Cnt  Warning cnt   Fun Rt   nloc Rt
------------------------------------------------------------------------------------------
         8       2.0     1.0       11.0        2            0      0.00    0.00

```
