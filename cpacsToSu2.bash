#! /bin/bash

# author: Malo Drougard

# This script generates su2 files from a set of capcs files
# It takes an input directory where the original cpacs files are
# and create in the current directrory a Results folder to put results.
# For each cpacs file a .smx and .su2 files will be created.
# Requirements:
# 	1) CPACS2SUMO
#	2) SUMO
#	3) adaptation to the local machine


# cpacs input files directrory 
creatorD="./CpacsInputs"

# parameters symbole 
p="d"	# (tested with one letter)  
# paramaters values <- use to differentiate files 
l="0 5 10 15"

# 0->keep the temp files and log allOther-> keep only the important files
clean=1

workD="$(pwd)"
resultD="$workD/Results"
cpacs2SumoD="/home/makem/JobProject/SkStage/CPACS2SUMO"	# change to your capcs2sumo dir

# create dir results
if [ !  -d "Results"  ]
then
  mkdir Results
fi


for i in $l
do 
  caseD="${resultD}/$p$i"
  mkdir $caseD
  
  # init file name
  creatorF="creator-$p$i.000000.cpacs.xml"	# here you have the naming convention
  cpacsF="$p$i.cpacs.xml"
  smxF="$p$i.smx"
  su2F="$p$i.su2"
  
  if [ ! -f $creatorD/$creatorF ] 
  then 
    echo "Creator file $creatorD/$creatorF not found! "
  else
    cp $creatorD/$creatorF $caseD/$cpacsF
    #copy to input for sumo
    cp $caseD/$cpacsF $cpacs2SumoD/ToolInput/ 
    #move to sumo work dir
    cd $cpacs2SumoD/CPACS2SUMO/
    python CPACS2SUMO.py $cpacs2SumoD/ToolInput/$cpacsF > $caseD/cpacs2sumo.out 2>&1
    
    if [ $clean -ne 0 ]
    then 
      rm $caseD/cpacs2sumo.out
    fi
  
    cp $cpacs2SumoD/ToolOutput/ToolOutput.smx $caseD/$smxF 
    
    mkdir $caseD/temp # we use a temp dir to delete the unwanted file at end
    cd $caseD/temp
    cp $caseD/$smxF $caseD/temp/
    dwfsumo -batch -output=su2 -tetgen-options=pq1.4V $caseD/temp/$smxF
    cp $caseD/temp/$su2F $caseD/
    
    if [ $clean -ne 0  ] 
    then 
      rm -r $caseD/temp
    fi
    
    cd $caseD  
  
  fi 
  
  cd $workD
  
done  
 






