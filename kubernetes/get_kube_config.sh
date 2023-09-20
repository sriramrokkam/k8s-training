#!/bin/bash
#

if [ "$(id -u)" -eq 0 ]; then
	echo "ERROR: Please do not run this script as root."
	exit 1
fi

# This is the central location where all the kube.config files are stored
BASE_URL=".ingress.trn-admin.k8s-trainings.c.eu-de-2.cloud.sap"

# This is the location in the local filesystem where the kube.config file needs to be placed
mkdir -p $HOME/.kube
TARGET=$HOME/.kube/config

if [ $# -eq 3 ]; then
	TRAINING=$1
	PARTID=$2
	PASSWORD=$3
else
	echo -n "Please enter the training name: "
	read -r TRAINING
	echo -n "Please enter your participant ID: "
	read -r PARTID
	echo -n "Please enter the password: "
	read -sr PASSWORD
fi

PARTID=$(printf %04d $((10#$PARTID)))

echo -e "\n"

if [ -f "$TARGET" ]; then
	echo -e "${TARGET} already exists. Attempting to store kubeconfig file to ${HOME}/.kube/${TRAINING}.config."
	echo "You can try to merge them manually or run"
	echo "  export KUBECONFIG='${HOME}/.kube/${TRAINING}.config'"
	echo "to activate it for your current session."
	TARGET=$HOME/.kube/$TRAINING.config
fi

CFG_URL="https://${TRAINING}${BASE_URL}/kubeconfigs/part-${PARTID}.yaml"
TMPFILE=$(mktemp -u)

curl -u "${TRAINING}:${PASSWORD}" -s -S -k -o "$TMPFILE" "$CFG_URL"

if [ $? -ne 0 ] || [ -n "$(grep '<html>' $TMPFILE)" ]; then
	echo "ERROR: Did not receive a valid kube.config file."
	echo "       Please check that you entered the correct training ID and participant ID."
	rm -f "$TMPFILE"
	exit 1
fi

mkdir -p "$(dirname $TARGET)"
mv "$TMPFILE" "$TARGET"

echo -e "\n*** Successfully copied kube config to local $TARGET"
