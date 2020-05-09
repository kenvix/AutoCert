if [ -z $AUTOCERT_INITED ]
then
    if [ ! -x "./config.sh" ]; then
        echo "Error: ./config.sh not found or not executable"
        echo "Please modify config.sh.example and copy it to ./config.sh"
        exit 170
    fi
    export AUTOCERT_INITED=1
fi

source ./config.sh

RunACME(){
    if [ "$ACME_MERGED_PARAMS" ]
    then
        echo "$ $ACME_MERGED_PARAMS"
        ./acme.sh $ACME_MERGED_PARAMS 
        return $?
    fi
}