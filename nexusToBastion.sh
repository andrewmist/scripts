#!/bin/bash

#//am 20170210 script: nexusToBastion.sh
# by parsing catalina.properties  - $1 parameter
# Basically: it sinks Modules from Nexus to Bastion
# doctor@virtualdocker:~$ rsync --del -rave "ssh -i /media/sf_vm_shared/KPOregon1.pem" /deployment/* ec2-user@52.37.111.117:/home/ec2-user/svsportaldeployment/
# Required getArtifact.sh
# Example:
######################################################################################

CNT=0;
DEST_ROOT="/deployment/global/modules";

PKGS=('com.svs.web.module' 'com.svs.web.module.b2b');
######################################################################################
clear;

TMP="$(pwd)/.tmp";


if [ "$#" -ne "0" ] ; then
  CATALINA_PROPS="$1";

  if [ -f "$CATALINA_PROPS" ]; then
    LINES=`grep 'wr\?m-*' $CATALINA_PROPS | cut -f1,2,3,4,5 -d"/"`;
    CNT_PARCED=`grep -c 'wr\?m-*' $CATALINA_PROPS`;

    for PKG in "${PKGS[@]}"; do
      echo "****************** Package: $PKG ************************";
      sleep 3;

      for DEST in $LINES; do
        ARTIFACT="${DEST##*/}"
 	
        ./getArtifact.sh $ARTIFACT '' $PKG;
    
        if [ "0" == "$?" ]; then
          FN="$(ls $TMP)";
          SZ="$(stat -c%s $TMP/$FN)";

          if [ "$SZ" != "0" ]; then       
            sudo rm -rf $DEST_ROOT/$ARTIFACT;
            sudo mkdir $DEST_ROOT/$ARTIFACT;

            sudo cp $FN $DEST_ROOT/$ARTIFACT/.;
            sudo chmod 777 -R $DEST_ROOT/$ARTIFACT;

            rsync --del -rave "ssh -i /media/sf_vm_shared/KPOregon1.pem" $DEST_ROOT/$ARTIFACT/* ec2-user@52.37.111.117:/home/ec2-user/svsportaldeployment/global/modules/$ARTIFACT
            #rsync --del -rave "ssh -i /media/sf_vm_shared/KPOregon1.pem" $DEST_ROOT/$ARTIFACT/ ec2-user@52.37.111.117:/home/ec2-user/svsportaldeployment

            CNT=$((CNT+1));
            rm $FN;
          else
            echo -e "\n\n******************* NOTHING DEPLOYED ***********************";
            echo " File: has 0-file size!";
            echo -e "************************************************************\n"
          fi;
        else
           echo -e "";
           echo "Download from NEXUS failed: '$PKG'-'$ARTIFACT'";
           sleep 2;
        fi;
      done
      
    done

    echo "******************************************************************************************************";
    echo "  $CNT_PARCED w|r|m Modules found in $CATALINA_PROPS, Processed: $CNT";
    echo "******************************************************************************************************";
  else
    echo "*******************************************************************************************************";
    echo "  Expected '$CATALINA_PROPS' does NOT exist! Exiting..."
    exit 0;
  fi;
else
  echo "*************************************";
  echo "*  Please provide Context! Exiting.. ";
  echo "*************************************";
  exit 0;
fi

