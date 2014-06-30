function parse {
    rm -f temp_list.txt
    grep -r $1 -e '.*' | grep -e "reddit.com\/r\/" | grep -v "%" | perl -pe 's/.*reddit.com.r.[^\/]*\/"\>([^\<]*).............([0-9]*).*/  , "\1,\2"/g' >> temp_list.txt

    echo $1Raw = [ >> $1.js.temp
    cat temp_list.txt | sort | uniq >> $1.js.temp
    echo -n "    ]" >> $1.js.temp
    cat $1.js.temp | perl -0pe "s/\[\n  ,/\[\n   /g" | perl -pe "s/\0//g" > $1.js
    rm $1.js.temp
    rm temp_list.txt
}

parse sfw
parse nsfw