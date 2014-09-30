usage=`df -Pm / | tail -n1`
count=`echo $usage | cut -f 4 -d \ `
let count--
echo $count	
sudo dd if=/dev/zero of=~/EMPTY bs=1M count=$count
sudo rm -f ~/EMPTY
sudo sync
sudo shutdown -h 0