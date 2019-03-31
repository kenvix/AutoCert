chmod +x *.sh
source ./data/config.sh

export ACME_MERGED_PARAMS="--cron "

echo "$ $ACME_MERGED_PARAMS"

./acme.sh $ACME_MERGED_PARAMS 