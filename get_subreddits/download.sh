rm -r sfw
mkdir sfw
for i in $(seq 1 169); do
    wget -O ./sfw/$i.txt http://redditlist.com/page-$i
done

rm -r nsfw
mkdir nsfw
for i in $(seq 1 29); do
    wget -O ./nsfw/$i.txt http://redditlist.com/nsfw/page-$i
done