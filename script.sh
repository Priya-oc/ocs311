
mkdir ocs311
cd ocs311

## Cluster details

cluster () {
mkdir cluster
cd cluster
oc get all -n $NS > all.txt
oc get nodes > nodes.txt
oc get pods -o wide -n $NS > pods.txt
oc get sc -o yaml > storageclass.yaml
oc get pvc -o yaml > pvc.yaml
oc get pv -o yaml > pv.yaml
oc get serviceaccount -n $NS > sa.txt
oc version   > oc_version.txt
oc get pods --all-namespaces -o wide > all_pods.txt
}

## Fetch heketi details

heketi() {

mkdir heketi
cd heketi
var2=`oc get pods -n $NS|grep heketi|awk '{ print $1 }'|head -1`
oc exec $var2 -n $NS heketi-cli topology info > heketi_topology.txt
oc exec $var2 -n $NS heketi-cli db dump > heketi_dump.yaml
oc exec $var2 -n $NS heketi-cli volume list > volume_list.txt
oc exec $var2 -n $NS -- rpm -qa|grep heketi > heketi_rpm.txt
oc exec $var2 -n $NS -- bash -c for i in $(heketi-cli volume list | awk '{ print $1 " " $6 }' | sed 's/^.\{,3\}//'); do heketi-cli volume info $i; done | grep -e "Name:" -e "Size:"  > volume_size.txt
oc logs $var2 -n $NS > heketi_logs.txt
oc exec $var2 -n $NS  heketi-cli server operations info > heketi_ops.txt
cd ..
}

## Details from gluster pod:

gluster() {
for pod in $(oc -n $NS get pods -o wide | awk '{if($1~"glusterfs")print $1}'); do echo "The data is being captured from $pod";
mkdir $pod
cd $pod
oc exec $pod -n $NS -- bash -c 'for i in $(gluster v list); do echo $i ; gluster v heal $i info;done' > heal_info.txt;
oc exec $pod -n $NS -- ps ef > ps.txt;
oc exec $pod -n $NS -- gluster volume info > volume_info.txt;
oc exec $pod -n $NS -- gluster volume status > volume_status.txt;
oc exec $pod -n $NS -- lvs --all --units k --reportformat=json > lvs.txt;
oc exec -n $NS $pod -- gluster pool list > pool_list.txt;
oc exec -n $NS $pod -- gluster peer status > peer_status.txt;
oc exec -n $NS $pod -- df > df.txt;
oc exec -n $NS $pod -- systemctl status glusterd.service gluster-blockd.service gluster-block-target.service tcmu-runner.service > service_status.txt;
oc exec -n $NS $pod -- rpm -qa|egrep "glusterfs|gluster-block|tcmu-runner|targetcli|rtslib|configshell" > rpm.txt;
oc exec  $pod -n $NS -- gluster v get all all> volume_all.txt;
oc exec  $pod -n $NS -- pvs >  pvs.txt;
oc exec  $pod -n $NS -- vgs --all --units k --reportformat=json >  vgs.txt;
oc exec $pod -n $NS -- targetcli ls > target_cli.txt
oc exec  $pod -n $NS cat /var/lib/heketi/fstab > fstab.txt;
oc exec  $pod -n $NS cat /var/lib/glusterd/glusterd.info > glusterd_info.txt
oc exec  $pod -n $NS gluster volume get all cluster.op-version > cluster.op-version.txt
oc exec  $pod -n $NS tail -n100 /var/log/glusterfs/glusterd.log > glusterd.log
oc exec  $pod -n $NS ls -l / > ls.txt
cd ..
done
}

#!/bin/bash

## Choice selection 
PS3="Choose the Glusterfs Mode: "
options=(Converged Independent)
select mode in "${options[@]}";
do
  echo -e "\nyou picked $mode ($REPLY)"
  if [[ $mode == "Converged" ]]; then
    echo -e "You've selected $mode \n"
    read -p 'Enter Namspace where glusterfs pods are running: ' NS
    echo "You've entered $NS project"
    cluster
    heketi
    gluster
    break;
  else
    echo "You've selected $mode"
    break;
  fi
done
