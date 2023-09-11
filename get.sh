
# TODO: 
# - ADD ARRAYS and naming the book automatically..... or maybe ask for the bookname with the title as default name...
# - Add option to download the book in bg&


USAGE="Usage: get.sh [BOOK] [OUTPUT_FILE]"

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

site=https://libgen.is/

function get_links()
{
	# --data-urlencode "lg_topic=libgen" \
	local book=$1;
	search_res=$(curl --get \
		--data-urlencode "req=$book" \
		--data-urlencode "open=0" \
		--data-urlencode "view=simple" \
		--data-urlencode "res=25" \
		--data-urlencode "phrase=1" \
		--data-urlencode "column=def" \
		--silent \
		https://libgen.is/search.php);
		# --progress-bar \
	echo $search_res | pup 'tr a[href^="book/index.php?"] json{}' | jq '.[] | .href, .text';

}


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

	# echo $page
	# echo $page | pup 'div#download > ul > li > a'
	# echo $page | pup 'div#download > ul > li > a json{}'
	# echo $page | pup 'div#download a json{}' | jq '.[] | .href, .text'
	# echo $page
	echo $page | pup 'div#download > ul > li > a json{}' | jq '.[] | .href, .text';

	# echo "book/index.php?md5=9F2B390517083CF4485BA524B80815F5" | grep "md5=(.*)" -o # WHY DOES THIS NOT WORK BTW 

}

# TODO: Turn the list from jq into 2 arrays and return the selection index from fzf to get the url index
# function combine_links()
# {
# 	# Turns the list of links into a single string...
# }

# TODO: add a q option to exit
link=$(get_links $BOOKNAME | fzf ) # get selected link from books list

# Exit if the user doesnt select any book
if [[ -z $link ]]; then
	exit 0
fi

# Get the book md5 Value from the link url
book_md5=$(echo $link | cut -d "=" -f 2)
book_md5="${book_md5/\"/}"


download_link=$(get_book_links $book_md5 | fzf)  # Get Book Download links

# removing "" from the url....
download_link="${download_link//\"/}"


# ! I REMOVED A COOKIE HEADER FROM HERE, LETS CHECK IF IT WORKS WITHOUT IT !

# DOWNLOADD THE PDF
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



# After selecting the book name we can also show the book cover and info on the right...
# OR ON THE FIRST SCREEN ITSELF....
# We can make the user select the order to query the sources....
# We can also add an fzf shortcut to clear the cache....
# Preferences -> DONT Clear Cache every search...., CLEAR BY DEFAULT. 
# 							SHOW IMAGE OPTION TOO !!!
# 							Maybe ask for the preferences the first time the user runs the thing....

# ALSO ADD SEARCH OPTIONS in the script options...
# 	https://library.lol/covers/1514000/1a699911f1094229b4d6c5df601a09ad-d.jpg
# USE CHARM !!! , https://oit.ua.edu/wp-content/uploads/2020/12/Linux_bash_cheat_sheet-1.pdf,
# 			https://devdocs.io/, https://devhints.io/bash, https://learnxinyminutes.com/docs/bash/
# 			tldr https://cheat-sheets.org/project/tldr/command/cut/

# https://seb.jambor.dev/posts/improving-shell-workflows-with-fzf/
# https://www.baeldung.com/linux/fzf-command
# https://thevaluable.dev/file-management-tools-linux-shell/

# Take a list of books and download them concurrently...
