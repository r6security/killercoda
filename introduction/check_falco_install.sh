echo "Installing scenario... Please wait!"
i=1
sp="/-\|"
echo -n ' '
while [ "x$(kubectl -n falco get pods 2>&1 | grep 'falco' | awk '{ print $2 }' | head -n 1)x" != "x2/2x" ]
do
  printf "\b${sp:i++%${#sp}:1}"
  sleep 1
done
echo DONE
echo Now you can start working!
