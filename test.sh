#/bin/bash
for s in $(cat variables.json | jq -r "to_entries|map(\"\(.key)=\(.value|tostring)\")|.[]" ); do
    echo $s
    sed -i -e 's/'$s'/'$s'/g' .env
done