source ./init.sh

export ACME_MERGED_PARAMS="--issue "

for domain in ${ACME_DOMAINS[@]}
do
export ACME_MERGED_PARAMS+=" -d $domain"
done

export ACME_MERGED_PARAMS+=" $ISSUE_PARAMS"

RunACME