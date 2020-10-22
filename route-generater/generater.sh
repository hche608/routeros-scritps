mkdir export
echo "/ip firewall address-list" > ./export/$2.rsc
curl "$1" | sed "s/^/add list=$3 address=/" >> ./export/$2.rsc

