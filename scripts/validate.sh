#!/usr/bin/env bash
# Runs the checks that do not need AWS credentials.
# Install terraform, tflint, kustomize, kubeconform, and actionlint first,
# or let a missing tool fail this script so the gap is obvious.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

echo "== terraform fmt =="
terraform fmt -check -recursive infra

echo "== terraform init and validate =="
for dir in infra/bootstrap infra/envs/dev infra/envs/dev-platform; do
  echo "-- $dir"
  terraform -chdir="$dir" init -backend=false -input=false
  terraform -chdir="$dir" validate
done

if command -v tflint >/dev/null 2>&1; then
  echo "== tflint =="
  (cd infra && tflint --init && tflint --recursive)
else
  echo "tflint is not installed" >&2
  exit 1
fi

echo "== kustomize build | kubeconform =="
kustomize build --load-restrictor LoadRestrictionsNone deploy/k8s/overlays/dev | kubeconform \
  -kubernetes-version 1.35.0 \
  -strict \
  -summary \
  -ignore-missing-schemas

echo "== actionlint =="
actionlint

echo "All local checks passed."
