
#!/bin/bash

var1='oc rsh'
var2= 'heketi-cli'


cluster () {

oc get all -n glusterfs
oc get nodes
oc get pods -o wide -n glusterfs
oc get sc
oc get pvc
oc get pv
oc get serviceaccount

}

heketi() {




#### enter the mode of Setup

PS3="Choose the glusterfs mode "
options=(Converged Independent)
select mode in "${options[@]}";
do
  echo -e "\nyou picked $mode ($REPLY)"
  if [[ $mode == "Converged" ]]; then
    echo -e "Gluster is in $mode mode \n"
    cluster
    break;
  else
    echo "Gluster is in $mode mode"
    break;
  fi
done
