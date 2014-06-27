rm temp_list.txt
rm temp_page.txt
#for i in $(seq 1 169); do
for i in $(seq 1 17); do
    wget -O temp_page.txt http://redditlist.com/page-$i
    cat temp_page.txt | grep -e "reddit.com\/r\/" | grep -v "%" | perl -pe 's/.*reddit.com.r.[^\/]*\/"\>([^\<]*).............([0-9]*).*/  , ("\1", \2)/g' >> temp_list.txt
done

echo module Sfw where > Sfw.elm.temp
echo "sfw : [(String, Int)]" >> Sfw.elm.temp
echo sfw = [ >> Sfw.elm.temp
cat temp_list.txt | sort | uniq >> Sfw.elm.temp
echo -n "    ]" >> Sfw.elm.temp
cat Sfw.elm.temp | perl -0pe "s/\[\n  ,/\[\n   /g" | perl -pe "s/\0//g" > Sfw.elm
rm Sfw.elm.temp
rm temp_list.txt
rm temp_page.txt

rm temp_list.txt
rm temp_page.txt
#for i in $(seq 1 29); do
for i in $(seq 1 3); do
    wget -O temp_page.txt http://redditlist.com/nsfw/page-$i
    cat temp_page.txt | grep -e "reddit.com\/r\/" | grep -v "%" | perl -pe 's/.*reddit.com.r.[^\/]*\/"\>([^\<]*).............([0-9]*).*/  , ("\1", \2)/g' >> temp_list.txt
done

echo module Nsfw where > Nsfw.elm.temp
echo "nsfw : [(String, Int)]" >> Nsfw.elm.temp
echo nsfw = [ >> Nsfw.elm.temp
cat temp_list.txt | sort | uniq | perl -0pe "s/\[\n,/\[\n /g" >> Nsfw.elm.temp
echo -n "    ]" >> Nsfw.elm.temp
cat Nsfw.elm.temp | perl -0pe "s/\[\n  ,/\[\n   /g" | perl -pe "s/\0//g" > Nsfw.elm
rm Nsfw.elm.temp
rm temp_list.txt
rm temp_page.txt