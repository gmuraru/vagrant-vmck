#!/bin/bash -ex

cd "$( dirname "${BASH_SOURCE[0]}" )"

trap "vagrant destroy -f" EXIT

curl "${VMCK_ARCHIVE_URL}" -o archive.zip
curl "${VMCK_SCRIPT_URL}" -o script.sh
curl "${VMCK_ARTIFACT_URL}" -o artifact.zip

chmod +x script.sh

vagrant up
(
set +e
vagrant ssh -- 'cd /vagrant; ./script.sh' 1> result.out 2> result.err
echo $? > result.exit_code
)

exit_code=$(cat result.exit_code)
base64 result.out > stdout.tmp
cat stdout.tmp | tr -d '\n' > stdout

base64 result.err > stderr.tmp
cat stderr.tmp | tr -d '\n' > stderr


jq -n \
    --rawfile out stdout \
    --rawfile err stderr \
    --arg code $exit_code \
    '{stdout: $out, stderr: $err, exit_code: $code,}' > out.json

curl -X POST "${VMCK_CALLBACK_URL}" -d @out.json \
     --header "Content-Type: application/json"
