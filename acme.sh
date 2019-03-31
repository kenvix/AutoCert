chmod +x *.sh
source ./data/config.sh

./acme/acme.sh --home ./data/acme $@