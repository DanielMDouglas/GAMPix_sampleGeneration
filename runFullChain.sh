#!/bin/bash

#SBATCH --partition=neutrino
#
#SBATCH --job-name=lndsm-sp
#SBATCH --output=logs/output-%j.txt
#SBATCH --error=logs/output-%j.txt
#
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=10g
#SBATCH --gpus=v100:1
#
#SBATCH --time=10:00:00
#
#SBATCH --array=1-100

SINGULARITY_IMAGE_PATH=/sdf/group/neutrino/images/larcv2_ub20.04-cuda11.3-cudnn8-pytorch1.10.0-larndsim-2022-11-03.sif

# OUTDIR=/sdf/group/neutrino/dougl215/singleParticle/singleParticle_3GeV
OUTDIR=$1

# I've been using a UUID from the OS to make unique filenames
# these are very long and can be quite ugly
# you can also just use the slurm batch index
ID=$(cat /proc/sys/kernel/random/uuid) 
#ID=$SLURM_ARRAY_TASK_ID # this will just assume a the index of the slurm job (less safe to being clobbered by new outputs!)

G4MACRO=$2

EDEPDIR=${OUTDIR}/edep-sim
mkdir -p $EDEPDIR
EDEPOUTPUT=${EDEPDIR}/edep_single_particle_${ID}.root

# COMMAND="edep-sim -g nd_hall_only_lar_TRUE_1.gdml -e 1000 -o ${EDEPOUTPUT} g4.mac"
# COMMAND="edep-sim -g nd_hall_only_lar_TRUE_1.gdml -e 1000 -o ${EDEPOUTPUT} g4_stoppingMuon.mac"
# COMMAND="edep-sim -g nd_hall_only_lar_TRUE_1.gdml -e 1000 -o ${EDEPOUTPUT} g4_LE_5particle.mac"
# COMMAND="edep-sim -g nd_hall_only_lar_TRUE_1.gdml -e 1000 -o ${EDEPOUTPUT} ${G4MACRO}"
COMMAND="edep-sim -g SeaOfArgon.gdml -e 1000 -o ${EDEPOUTPUT} ${G4MACRO}"

singularity exec -B /sdf,/scratch,/lscratch ${SINGULARITY_IMAGE_PATH} ${COMMAND}

#-----------------------

DUMPTREEDIR=${OUTDIR}/dumpTree
mkdir $DUMPTREEDIR
DUMPTREEOUTPUT=${DUMPTREEDIR}/dumpTree_single_particle_${ID}.h5

COMMAND="python3 dumpTree.py ${EDEPOUTPUT} ${DUMPTREEOUTPUT}"

singularity exec -B /sdf,/scratch,/lscratch ${SINGULARITY_IMAGE_PATH} ${COMMAND}

