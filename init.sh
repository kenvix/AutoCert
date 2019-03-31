if [ -z $AUTOCERT_INITED ]
then
    if [ ! -x "./data/config.sh" ]; then
        echo "Error: ./data/config.sh not found or not executable"
        echo "Please modify config.sh.example and copy it to ./data/config.sh"
        exit 170
    fi
    export AUTOCERT_INITED=1
fi

source ./data/config.sh

RunACME(){
    if [ "$ACME_MERGED_PARAMS" ]
    then
        echo "$ $ACME_MERGED_PARAMS"
        ./acme.sh $ACME_MERGED_PARAMS 
        return $?
    fi
}