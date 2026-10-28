#!/usr/bin/env python3
"""Fill the dev overlay from the dev stack's Terraform outputs.

Run from the repository root after `terraform apply` in infra/envs/dev:

    python3 scripts/configure-dev-overlay.py

The certificate ARN and the hostname are written into the Ingress.
The ECR repository URL is written into the Kustomize image name.
An existing non-bootstrap tag is left alone, because CI owns that tag.
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DEV = ROOT / "infra" / "envs" / "dev"
INGRESS = ROOT / "deploy" / "k8s" / "overlays" / "dev" / "ingress.yaml"
OVERLAY = ROOT / "deploy" / "k8s" / "overlays" / "dev"


def terraform_output() -> dict:
    result = subprocess.run(
        ["terraform", "output", "-json"],
        cwd=DEV,
        check=True,
        capture_output=True,
        text=True,
    )
    raw = json.loads(result.stdout)
    return {key: value["value"] for key, value in raw.items()}


def replace_annotation(text: str, name: str, value: str) -> str:
    needle = f"{name}: "
    lines = []
    found = False
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith(needle):
            indent = line[: len(line) - len(stripped)]
            lines.append(f"{indent}{name}: {value}")
            found = True
        else:
            lines.append(line)
    if not found:
        sys.exit(f"did not find annotation {name} in {INGRESS}")
    return "\n".join(lines) + "\n"


def replace_host(text: str, host: str) -> str:
    lines = []
    found = False
    for line in text.splitlines():
        stripped = line.lstrip()
        if stripped.startswith("host: ") and not found:
            indent = line[: len(line) - len(stripped)]
            lines.append(f"{indent}host: {host}")
            found = True
        else:
            lines.append(line)
    if not found:
        sys.exit(f"did not find a host in {INGRESS}")
    return "\n".join(lines) + "\n"


def current_tag() -> str:
    text = (OVERLAY / "kustomization.yaml").read_text()
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("newTag:"):
            return stripped.split(":", 1)[1].strip()
    return "bootstrap"


def main() -> None:
    outputs = terraform_output()
    arn = outputs["acm_certificate_arn"]
    host = outputs["app_hostname"]
    repository = outputs["ecr_repository_url"]

    ingress = INGRESS.read_text()
    ingress = replace_annotation(
        ingress, "alb.ingress.kubernetes.io/certificate-arn", arn
    )
    ingress = replace_host(ingress, host)
    INGRESS.write_text(ingress)

    tag = current_tag()
    name_line = None
    kustomization = (OVERLAY / "kustomization.yaml").read_text()
    for line in kustomization.splitlines():
        if "newName:" in line:
            name_line = line
            break
    placeholder = name_line is not None and "ACCOUNT_ID" in name_line
    if tag != "bootstrap" and not placeholder:
        print(f"Leaving image tag {tag} in place. CI owns it.")
        tag_to_set = tag
    else:
        tag_to_set = "bootstrap"

    subprocess.run(
        ["kustomize", "edit", "set", "image", f"ad={repository}:{tag_to_set}"],
        cwd=OVERLAY,
        check=True,
    )
    print(f"Ingress host: {host}")
    print(f"Certificate: {arn}")
    print(f"Image: {repository}:{tag_to_set}")
    print("Review the diff, commit it, and push. Argo CD syncs main.")


if __name__ == "__main__":
    main()
