rm -r sfw
mkdir sfw
for i in $(seq 1 34); do
    wget -O ./sfw/$i.txt http://redditlist.com/?page=$i
done

rm -r nsfw
mkdir nsfw
for i in $(seq 1 7); do
    wget -O ./nsfw/$i.txt http://redditlist.com/nsfw?page=$i
done