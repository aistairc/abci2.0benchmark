#!/bin/sh
#$-l rt_AF=1
#$-cwd
#$-l h_rt=0:10:00

source /etc/profile.d/modules.sh

# number of processes/node (GPUs)
NPPN=8
# total MPI processes
NMPIPROCS=$(($NHOSTS * $NPPN))
# number of processes/socket
NPPS=$(($NPPN / 2))

module load openmpi/4.0.5
mpirun -np $NMPIPROCS --map-by ppr:${NPPS}:socket -tag-output hostname
module purge

source ./mpi.sh "${JOB_NAME}.${JOB_ID}" $NMPIPROCS $NPPN $NPPS
source ./mpi-cpu.sh "${JOB_NAME}.${JOB_ID}" $NMPIPROCS $NPPN $NPPS
source ./nccl.sh "${JOB_NAME}.${JOB_ID}" $NMPIPROCS $NPPN $NPPS

