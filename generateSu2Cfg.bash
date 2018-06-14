#! /bin/bash

# iterative values
machs="0.5 0.7 0.9 1.1 1.3"
angleOAs="1 3"

# constant values for all files
numberOfIter="2000"
refArea="90"

templateF="template.cfg"


count=0

for m in $machs
do 
  for a in $angleOAs
  do
    echo "generate configuration with m=$m aOA=$a"
    
    newF="input-m$m-a$a.cfg"
    cp $templateF $newF
  
    # change mach number in new input file
    sed -i "s/MACH_NUMBER = .*/MACH_NUMBER = $m/" $newF
    # change angle of attack
    sed -i "s/AoA = .*/AoA = $a/" $newF
    
    # change iterations
    sed -i "s/EXT_ITER = .*/EXT_ITER = $numberOfIter/" $newF
    # change reference area
    sed -i "s/REF_AREA = .*/REF_AREA = $refArea/" $newF
    
    count=$(($count + 1))
    
  done
      
  
done 

echo "Generation of su2 configuration files ended: $count files generated"



