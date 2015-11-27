function parse {
    grep -r $1 -e '.*' | grep -B 2 listing-stat | perl -pe "s/\n/newline/g" | perl -pe "s/reddit.com.r./\n/g" | perl -pe "s/(.*). target.*listing-stat..(.*)..span.*/\1;\2/g" | perl -pe "s/,//g" | perl -pe "s/;/,/g" | grep -v ".txt:" | perl -pe 's/^(.*)/  , "\1"/g' > temp_list.txt

    echo module $2 where > $2.elm.temp
    echo "$1Raw : List String" >> $2.elm.temp
    echo $1Raw = [ >> $2.elm.temp
    cat temp_list.txt | sort | uniq >> $2.elm.temp
    echo -n " ]" >> $2.elm.temp
    cat $2.elm.temp > $2.elm
    rm $2.elm.temp
    rm temp_list.txt
}

parse sfw Sfw
parse nsfw Nsfw

echo "please manually remove comma in line 4 of Sfw.elm and Nsfw.elm"