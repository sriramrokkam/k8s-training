#!/usr/bin/env bash
set -euo pipefail

OWN_DIR="$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")"
REPO_ROOT="$OWN_DIR/../"

COMMAND="${1:-generate}"

TEMPLATES=()
while IFS= read -r file; do
  TEMPLATES+=("$file")
done < <(
  grep -rl --include="*.yaml" -e '<cluster-name>.<project-name>' \
    "$REPO_ROOT/kubernetes" "$REPO_ROOT/sample-app" \
    | sed "s|$REPO_ROOT/||"
)

echo "Found ${#TEMPLATES[@]} template(s) with matching <cluster-name>.<project-name>"
echo ""

if [[ "$COMMAND" == "clean" ]]; then
  for DEST in "${TEMPLATES[@]}"; do
    FILE="$REPO_ROOT/${DEST%.yaml}.replaced.yaml"
    if [[ -f "$FILE" ]]; then
      rm "$FILE"
      echo "Deleted: ${DEST%.yaml}.replaced.yaml"
    fi
  done
  exit 0
elif [[ "$COMMAND" != "generate" ]]; then
  echo "Usage: $(basename "$0") [generate|clean]" >&2
  echo "  generate  Replace placeholders and write files (default)" >&2
  echo "  clean     Delete the generated files" >&2
  exit 1
fi

# Extract the API server URL from the current kubeconfig context
SERVER_URL=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')

# The Gardener API server URL pattern:
#   https://api.<cluster-name>.<project-name>.shoot.canary.k8s-hana.ondemand.com
# or more generally any subdomain before .shoot.canary.k8s-hana.ondemand.com
INGRESS_SUFFIX="shoot.canary.k8s-hana.ondemand.com"

if [[ "$SERVER_URL" != *".$INGRESS_SUFFIX"* ]]; then
  echo "Error: current kubeconfig server URL does not look like a Gardener cluster URL." >&2
  echo "  Got: $SERVER_URL" >&2
  echo "  Expected something matching: *.<cluster-name>.<project-name>.$INGRESS_SUFFIX" >&2
  exit 1
fi

# construct ingress hostname string
GARDENER_PROJECTNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f3)
GARDENER_CLUSTERNAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}' | cut -d. -f2)
INGRESS_HOSTNAME=h.ingress.${GARDENER_CLUSTERNAME}.${GARDENER_PROJECTNAME}.shoot.canary.k8s-hana.ondemand.com

if [[ -z "$GARDENER_CLUSTERNAME" || -z "$GARDENER_PROJECTNAME" ]]; then
  echo "Error: could not derive cluster-name and project-name from: $SERVER_URL" >&2
  exit 1
fi

echo "Cluster name : $GARDENER_CLUSTERNAME"
echo "Project name : $GARDENER_PROJECTNAME"
echo ""

for DEST in "${TEMPLATES[@]}"; do
  SRC="$REPO_ROOT/$DEST"
  OUT="$REPO_ROOT/${DEST%.yaml}.replaced.yaml"

  if [[ ! -f "$SRC" ]]; then
    echo "Warning: template not found, skipping: $SRC" >&2
    continue
  fi

  sed \
    -e "s/<cluster-name>/$GARDENER_CLUSTERNAME/g" \
    -e "s/<project-name>/$GARDENER_PROJECTNAME/g" \
    "$SRC" > "$OUT"

  echo "Generated: ${DEST%.yaml}.replaced.yaml"
done

echo ""
echo "Done. The .replaced.yaml files contain real cluster/project names and are gitignored."
