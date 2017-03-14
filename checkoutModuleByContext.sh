#!/bin/bash
:
#//am TODAY!!! script: checkoutModulesByContext.sh
# Purpose: pulls wm- or wrm- modules from SVN_ROOT to DESTination foloder
# Basically: it sinks Modules in SVN with deployed Modules
# Example: sh checkoutModuesByContext catalina.properties
######################################################################################

SVN_ROOT_org="http://gforge.comdata.local/svn/wsappconf/trunk/integration/";
SVN_ROOT="http://172.16.30.32/svn/wsappconf/trunk/integration/";
CNT=0;
######################################################################################
clear;

if [ "$#" -ne "0" ] ; then
  CATALINA_PROPS="$1";

  if [ -f "$CATALINA_PROPS" ]; then
    LINES=`grep 'wr\?m-*' $CATALINA_PROPS | cut -f1,2,3,4,5 -d"/"`;

    CNT_PARCED=`grep -c 'wr\?m-*' $CATALINA_PROPS`;

    for DEST in $LINES; do
      #DEST=${DEST/modules/andrew};
      REPO="$SVN_ROOT$DEST";
      #echo "SRC: $REPO, DEST: $DEST";
      echo "Checkingout latest $DEST....";

      svn --username=anonymous --password='' --force -q co $REPO $DEST;
      svn --username=anonymous --password='' revert -R $DEST;
      CNT=$((CNT+1));
    done

    echo "******************************************************************************************************";
    echo "  $CNT_PARCED w|r|m Modules found in $CATALINA_PROPS, SVNProcessed: $CNT";
    echo "******************************************************************************************************";
  else
    echo "*******************************************************************************************************";
    echo "  Expected '$CATALINA_PROPS' does NOT exist! Exiting..."
    echo "  AVAILABLE Contexts: "
    echo "*******************************************************************************************************";
    exit 0;
  fi;
else
  echo "*************************************";
  echo "*  Please provide Context! Exiting.. ";
  echo "*************************************";
  exit 0;
fi
