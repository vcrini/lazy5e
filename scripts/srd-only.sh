#!/usr/bin/env zsh
set -euo pipefail

if ! command -v yq >/dev/null 2>&1; then
  echo "errore: yq non trovato nel PATH"
  exit 1
fi

DATA_DIR="${1:-data}"

filter_key() {
  local file="$1"
  local key="$2"
  yq -i ".${key} = (.${key} // [] | map(select(.srd == true or .srd52 == true)))" "${file}"
}

filter_key "${DATA_DIR}/monster.yaml" "monsters"
filter_key "${DATA_DIR}/item.yaml" "items"
filter_key "${DATA_DIR}/spell.yaml" "spells"
filter_key "${DATA_DIR}/class.yaml" "classes"
filter_key "${DATA_DIR}/race.yaml" "races"
filter_key "${DATA_DIR}/feat.yaml" "feats"
yq -i '.books = []' "${DATA_DIR}/book.yaml"
yq -i '.adventures = []' "${DATA_DIR}/adventure.yaml"

echo "SRD filter applicato su ${DATA_DIR}:"
echo "  monsters:   $(yq '.monsters | length' "${DATA_DIR}/monster.yaml")"
echo "  items:      $(yq '.items | length' "${DATA_DIR}/item.yaml")"
echo "  spells:     $(yq '.spells | length' "${DATA_DIR}/spell.yaml")"
echo "  classes:    $(yq '.classes | length' "${DATA_DIR}/class.yaml")"
echo "  races:      $(yq '.races | length' "${DATA_DIR}/race.yaml")"
echo "  feats:      $(yq '.feats | length' "${DATA_DIR}/feat.yaml")"
echo "  books:      $(yq '.books | length' "${DATA_DIR}/book.yaml")"
echo "  adventures: $(yq '.adventures | length' "${DATA_DIR}/adventure.yaml")"
