# set -a
# alias fzf="fzf --height 40% --layout=reverse --border" # HMM this didnt work.

USAGE="Usage: get.sh BOOK OUTPUT_FILE"

if ! [[ $# -eq 2 ]]; then
	echo $USAGE
	exit 1
else
	BOOKNAME="$1"
	OUTPUT_FILE="$2"

	# basic url escaping bookname
	BOOKNAME="${BOOKNAME// /+}"

	# Check if file already exists
	if [[ -f $OUTPUT_FILE ]]; then
		echo "ERROR: File $OUTPUT_FILE already exists"
		exit 1
	fi

	# "the code book" -> the # lmao
	# echo $BOOKNAME
	# echo $OUTPUT_FILE
	# exit 0
fi

# Searching and Parsing the Results Table
book=$1;
search_res=$(curl --get \
	--data-urlencode "req=$book" \
	--data-urlencode "open=0" \
	--data-urlencode "view=simple" \
	--data-urlencode "res=25" \
	--data-urlencode "phrase=1" \
	--data-urlencode "column=def" \
	--progress-bar \
	https://libgen.is/search.php);

eval "RESULTS=($(echo $search_res | pup 'table.c > tbody > tr json{}' | jq -r -f ./BookDescriptions.jq))"


declare -a LINKS
declare -a TITLES

declare -i counter=0
# Looping over all the details to extract the `title` and `url`
for details in "${RESULTS[@]}"; do
	# Extracting title and links
	title="$(echo "$details" | grep -o "title : \(.*\)$" | cut -d: -f2-)"
	link="$(echo "$details" | grep -o "link : \(.*\)$" | cut -d: -f2-)"

	# WE need to add a ${counter}: for fzf to get the selection number from fzf selection later
	title="${counter}~$title"
	counter+=1

	TITLES+=("$title")
	LINKS+=("$link")
done

# https://stackoverflow.com/a/59877763/9596267 (arrays cant be exported without a hack....)
# Exporting $RESULTS for use in fzf --preview pane function `preview_book_details`
export MY_ARRAY=$(IFS='|'; echo "${RESULTS[*]}")

function get_index()
{
	declare -i index=$(echo "$1" | cut -d~ -f1)
	echo $index
}

function preview_book_details()
{
	# https://stackoverflow.com/a/59877763/9596267
	IFS='|'; RESULTS=($MY_ARRAY); unset IFS
	echo "${RESULTS[$1]}"
}

# We need to export a function to be able to use it in fzf preview
export -f preview_book_details


# get selected link from books list
link=$(
	printf "%s\n" "${TITLES[@]}" |\
	fzf \
		-d~ \
		--with-nth 2 \
		--margin 2% \
		--layout=reverse \
		--no-sort \
		--no-multi \
		--border \
		--header="Select Results for \"${BOOKNAME}\"" \
		--preview='preview_book_details {n}'
) 

# Exit if the user doesnt select any book
if [[ -z $link ]]; then
	exit 0
fi

# GET LINK FROM SELECTED BOOK TITLE
index=$(get_index $link)
link="${LINKS[$index]}"

# Extracting md5 parameter value from url
book_md5=$(echo $link | cut -d "=" -f 2)

function get_book_links()
{
	local md5=$1

	local bookpage="https://library.lol/main/$md5" # Use for getting book info "book/index.php?md5=9F2B390517083CF4485BA524B80815F5"; 

	# echo bookpage is $bookpage
	# bookpage="https://library.lol/main/1A699911F1094229B4D6C5DF601A09AD"

	local page=$(curl $bookpage --compressed \
		-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/117.0' \
		-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
		-H 'Accept-Language: en-US,en;q=0.5' \
		-H 'Accept-Encoding: gzip, deflate, br' \
		-H 'DNT: 1' \
		-H 'Upgrade-Insecure-Requests: 1' \
		-H 'Connection: keep-alive' \
		-H 'Sec-Fetch-Dest: document' \
		-H 'Sec-Fetch-Mode: navigate' \
		-H 'Sec-Fetch-Site: cross-site' \
		-H 'Sec-Fetch-User: ?1'
	)

	echo $page | pup 'div#download > ul > li > a json{}' | jq -r '.[] | .href, .text';
}

# Get Book Download links
download_link=$(get_book_links $book_md5 \
									| fzf --margin 2% \
										--layout=reverse \
										--no-sort \
										--no-multi \
										--border \
										--header="Select Results for \"${BOOKNAME}\"")


# DOWNLOAD THE PDF
curl "$download_link" \
	-H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/117.0' \
	-H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' \
	-H 'Accept-Language: en-US,en;q=0.5' \
	-H 'Accept-Encoding: gzip, deflate, br' \
	-H 'Referer: https://library.lol/' \
	-H 'DNT: 1' \
	-H 'Connection: keep-alive' \
	-H 'Upgrade-Insecure-Requests: 1' \
	-H 'Sec-Fetch-Dest: document' \
	-H 'Sec-Fetch-Mode: navigate' \
	-H 'Sec-Fetch-Site: cross-site' \
	-H 'Sec-Fetch-User: ?1' \
	-H 'TE: trailers' \
	--progress-bar \
	-o $OUTPUT_FILE
