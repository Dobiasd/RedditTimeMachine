function parse {
    grep -r $1 -e '.*' | grep -e "reddit.com\/r\/" | grep -v "%" | perl -pe 's/.*reddit.com.r.[^\/]*\/"\>([^\<]*).............([0-9]*).*/ , "\1,\2"/g' > temp_list.txt

    echo module $2 where > $2.elm.temp
    echo "$1Raw : [String]" >> $2.elm.temp
    echo $1Raw = [ >> $2.elm.temp
    cat temp_list.txt | sort | uniq >> $2.elm.temp
    echo -n " ]" >> $2.elm.temp
    cat $2.elm.temp | perl -0pe "s/\[\n ,/\[\n /g" | perl -pe "s/\0//g" > $2.elm
    rm $2.elm.temp
    rm temp_list.txt
}

parse sfw Sfw
parse nsfw Nsfw