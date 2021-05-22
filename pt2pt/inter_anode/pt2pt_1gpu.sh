OUTPUT="${1}.gpu"
NMPIPROCS=$2
NPPN=$3

module load cuda/11.2/11.2.2
module load openmpi/4.0.5
module load gdrcopy/2.1

export UCX_HOME=/apps/rhel8/ucx/1.9.0/gcc8.3.1_cuda11.2.2_gdrcopy2.1
export LD_LIBRARY_PATH=${UCX_HOME}/lib:${LD_LIBRARY_PATH}

WORKDIR=`pwd`
OMBDIR=${WORKDIR}/../../programs/omb-5.7-anode/libexec/osu-micro-benchmarks
PROG_LATENCY=${OMBDIR}/mpi/pt2pt/osu_multi_lat
PROG_BANDWIDTH=${OMBDIR}/mpi/pt2pt/osu_mbw_mr
PROG_OPTION="-m 4194304 -d cuda"

mpirun -np $NMPIPROCS --map-by ppr:${NPPN}:node \
       --mca pml ucx --mca osc ucx \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x UCX_WARN_UNUSED_ENV_VARS=n \
       ${PROG_LATENCY} ${PROG_OPTION} D D > ${OUTPUT}.latency

mpirun -np $NMPIPROCS --map-by ppr:${NPPN}:node \
       --mca pml ucx --mca osc ucx \
       -x PATH \
       -x LD_LIBRARY_PATH \
       -x UCX_WARN_UNUSED_ENV_VARS=n \
       ${PROG_BANDWIDTH} ${PROG_OPTION} D D > ${OUTPUT}.bandwidth

module purge
