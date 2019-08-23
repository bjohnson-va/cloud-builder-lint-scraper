#!/bin/sh

declare -a found;

function notFound() {
	buildId=$2;
	line=${1##*-};
	line=${line##*:};

	echo "--------------------\nWill record:\n$line\nif not already recorded\n---------------------";

	f=1;
	for i in "${found[@]}"
	do
		:
		check=${i##*-}
		check=${check##*:}
		echo "---\nComparing\n$line\nto\n$check\n---";
		if [[ $line == $check ]]; then
			echo "Found duplicate";
			f=0
			break;
		fi
	done
	echo "Done checking found";
	if [[ $f == 1 ]]; then
		echo "Recording!"
		l=$(echo "$line" | sed -e 's/^[[:space:]]*//');
		echo "$buildId,\"$l\"" >> unique.csv;
		found+=("$line");
	fi
}

echo "buildId,error" > unique.csv;

while read -r line
do
  if [[ $line == "" ]]; then 
        continue;
  elif [[ $line == Step* ]]; then
	notFound "$line" "$buildId";
  else 
	found=()
	buildId=$line;
  fi

done < $1
