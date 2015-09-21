#!/bin/sh

#metto in una funzione il controllo del file
function check_file {
  NOMEFILE=$1
  CHECKOK="No syntax errors detected in "
 
  OUTPUT="$(php -l  $NOMEFILE)"
 
  #verifico il messaggio di esito restituito
  if ! [ "$OUTPUT" == "$CHECKOK$NOMEFILE" ]
  then
    echo "Ho trovato un errore aggiustalo prima di fare il commit:: "$NOMEFILE
    echo "=== >>> ERRORE NEL PARSING DEL FILE <<< ==="
    exit 1
  fi
}


PROJECT=`php -r "echo dirname(dirname(dirname(realpath('$0'))));"`
STAGED_FILES_CMD=`git diff --cached --name-only --diff-filter=ACMR HEAD | grep \\\\.php`

# Determine if a file list is passed
if [ "$#" -eq 1 ]
then
	oIFS=$IFS
	IFS='
	'
	SFILES="$1"
	IFS=$oIFS
fi
SFILES=${SFILES:-$STAGED_FILES_CMD}

echo "Checking PHP Lint..."
for FILE in $SFILES
do
	#php -l -d display_errors=0 $PROJECT/$FILE
    check_file "$PROJECT/$FILE"
    
    FILES="$FILES $PROJECT/$FILE"
done

if [ "$FILES" != "" ]
then
	echo "Running Code Sniffer..."
	./vendor/bin/phpcs  --encoding=utf-8 -n -p $FILES
	#./vendor/bin/phpcs --standard=PSR1 --encoding=utf-8 -n -p $FILES
	if [ $? != 0 ]
	then
		echo "Fix the error before commit."
		exit 1
	fi
fi

echo "fermo tutto"
exit 1

exit $?