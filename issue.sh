chmod +x *.sh
source ./data/config.sh

export ACME_MERGED_PARAMS="--issue "

for domain in ${ACME_DOMAINS[@]}
do
export ACME_MERGED_PARAMS+=" -d $domain"
done

export ACME_MERGED_PARAMS+=" $ISSUE_PARAMS"

echo "$ $ACME_MERGED_PARAMS"

./acme.sh $ACME_MERGED_PARAMS 