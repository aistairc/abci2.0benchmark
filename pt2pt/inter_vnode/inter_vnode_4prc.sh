#!/bin/sh
#$-l rt_F=2
#$-cwd
#$-l h_rt=0:10:00

source /etc/profile.d/modules.sh
module load cuda/11.2/11.2.2
module load gcc/7.4.0
module load openmpi/4.0.5
module load gdrcopy/2.0

export UCX_HOME=/apps/centos7/ucx/1.7.0/gcc7.4.0_cuda11.2.2_gdrcopy2.0
export LD_LIBRARY_PATH=${UCX_HOME}/lib:${LD_LIBRARY_PATH}

WORKDIR=`pwd`
OMBDIR=${WORKDIR}/../../programs/omb-5.7-vnode/libexec/osu-micro-benchmarks
PROG_LATENCY=${OMBDIR}/mpi/pt2pt/osu_multi_lat
PROG_BANDWIDTH=${OMBDIR}/mpi/pt2pt/osu_mbw_mr
PROG_OPTION="-m 4194304"

# number of processes/node (GPUs)
NPPN=4
# total MPI processes
NMPIPROCS=$(($NHOSTS * $NPPN))
# number of processes/socket
NPPS=$(($NPPN / 2))

mpirun -np $NMPIPROCS --map-by ppr:${NPPS}:socket -tag-output hostname

mpirun -np $NMPIPROCS --map-by ppr:${NPPS}:socket \
       --mca pml ucx --mca osc ucx \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x UCX_WARN_UNUSED_ENV_VARS=n \
       ${PROG_LATENCY} ${PROG_OPTION} H H > ${JOB_NAME}.latency

mpirun -np $NMPIPROCS --map-by ppr:${NPPS}:socket \
       --mca pml ucx --mca osc ucx \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x UCX_WARN_UNUSED_ENV_VARS=n \
       ${PROG_BANDWIDTH} ${PROG_OPTION} H H > ${JOB_NAME}.bandwidth

