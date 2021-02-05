#!/bin/bash

APPNAME=$(basename "$0")

usage()
{
	echo "usage : $APPNAME"
	echo "  -c <dev-msa_msa_sms_?>    container id where it must run."
	echo "  -r    run locally"
	echo "  -h    this help"
	exit -1
}

if [ $# -eq 0 ]
then
    usage
    exit 0
fi

CONTAINER=()
LOCALLY=0
while [ $# -ne 0 ]
do
	OPTION=$1

	case ${OPTION} in
    -c)
        shift
        CONTAINER="$1 ${CONTAINER}"
        ;;
    -r)
        shift
        LOCALLY=1
        ;;
    -h)
        usage
        exit 0
        ;;
	*)
		echo "Invalid option ${OPTION}"
		usage
		;;
	esac
	shift
done

# if there is a list of containers to run on
if [ ${#CONTAINER[@]} -ne 0 ]
then
    for ctnr in $CONTAINER
    do
        echo "launch on $ctnr"
        docker cp -L "$0" $ctnr:/tmp/.
        [ $? ] && docker exec $ctnr "/tmp/$APPNAME" -r
        docker exec $ctnr /bin/rm -f "/tmp/$APPNAME"
    done
    exit 0
fi

if [ $LOCALLY -eq 0 ]
then
    exit 0
fi

# === MAIN =====================================================================
declare -a BPMN_FILES

# to move: /opt/fmc_repository/Datafiles/operatorPrefix/customerId/bpmn/<bpmn file>
BPMN_FILES=($(/usr/bin/printf '%s\n' "/opt/fmc_repository/Datafiles/*/*/bpmn/*.bpmn"))

# number of BPMN files
NB_BPMN_FILES=${#BPMN_FILES[@]}

# if this number is 1 and glob returned the search pattern then there is no file
if [ \( $NB_BPMN_FILES -eq 1 \) -a \( "${BPMN_FILES[0]}" == '/opt/fmc_repository/Datafiles/*/*/bpmn/*.bpmn' \) ]
then
    echo 'No BPMN file to process.'
    exit 0
fi

# loop on all BPMN files
for i in $(seq 0 $(($NB_BPMN_FILES - 1)) )
do
    BPMN_FILE="${BPMN_FILES[$i]}"
    BPMN_FILENAME=$(basename "$BPMN_FILE")

    if [ -f "/opt/fmc_repository/Bpmn/$BPMN_FILENAME" ]
    then
        echo "WARNING, '$BPMN_FILE' is skipped because '/opt/fmc_repository/Bpmn/$BPMN_FILENAME' already exists."
        # next loop
    else

        # OPERATORPREFIX=$(sed -e 's;^/opt/fmc_repository/Datafiles/\([^/]*\)/.*$;\1;' <<< "$BPMN_FILE")
        CUSTOMERID=$(sed -e 's;^/opt/fmc_repository/Datafiles/[^/]*/\([^/]*\)/.*$;\1;' <<< "$BPMN_FILE")

        ENTITY_FILE="/opt/fmc_entities/$CUSTOMERID.xml"
        TMP_ENTITY_FILE="$ENTITY_FILE".tmp.$$

        if [ ! -f "$ENTITY_FILE" ]
        then
            # create the entity file
            printf '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n' >  "$ENTITY_FILE"
            printf '<ConfigurationMap>\n'                                      >> "$ENTITY_FILE"
            printf '\t<Bpmn>\n'                                                >> "$ENTITY_FILE"
            printf '\t\t<entry>\n'                                             >> "$ENTITY_FILE"
            printf '\t\t\t<key>%s</key>\n'         "Bpmn/$BPMN_FILENAME"       >> "$ENTITY_FILE"
            printf '\t\t\t<value>%s</value>\n'     "Bpmn/$BPMN_FILENAME"       >> "$ENTITY_FILE"
            printf '\t\t</entry>\n'                                            >> "$ENTITY_FILE"
            printf '\t</Bpmn>\n'                                               >> "$ENTITY_FILE"
            printf '</ConfigurationMap>\n'                                     >> "$ENTITY_FILE"
        else
            # we reformat "$ENTITY_FILE" so that 'sed' commands work without any issue
            XMLLINT_INDENT=$(printf '\t') xmllint --format "$ENTITY_FILE" > "$TMP_ENTITY_FILE"
            \mv -f "$TMP_ENTITY_FILE" "$ENTITY_FILE"

            # is the <Bpmn> section missing ?
            if ! ( echo 'dir /ConfigurationMap/Bpmn' | xmllint --shell "$ENTITY_FILE" | grep -qs '/ > ELEMENT Bpmn' )
            then
                # no, create section before </ConfigurationMap>
                sed -i '/<\/ConfigurationMap>/i \
\t<Bpmn> \
\t</Bpmn>'      "$ENTITY_FILE"
            fi

            # add entry before </Bpmn>
            sed -i '/<\/Bpmn>/i \
\t\t<entry> \
\t\t\t<key>Bpmn/'"$BPMN_FILENAME"'</key> \
\t\t\t<value>Bpmn/'"$BPMN_FILENAME"'</value> \
\t\t</entry>'      "$ENTITY_FILE"
        fi

        # move BPMN file
        mkdir -p /opt/fmc_repository/Bpmn
        \mv -f "$BPMN_FILE"  /opt/fmc_repository/Bpmn/.

        echo "File '$BPMN_FILE' moved, entity file '$ENTITY_FILE' updated."
    fi
done

exit 0
