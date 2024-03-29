FROM ubuntu:22.04
ENV USER=root
ENV PASSWORD=password1
ENV DEBIAN_FRONTEND=noninteractive 
ENV DEBCONF_NONINTERACTIVE_SEEN=true
COPY pacman /dos/pacman
RUN apt-get update && \
	echo "tzdata tzdata/Areas select Europe" > ~/tx.txt && \
	echo "tzdata tzdata/Zones/America select Amsterdam" >> ~/tx.txt && \
	debconf-set-selections ~/tx.txt && \
	apt-get install -y tightvncserver ratpoison dosbox novnc websockify net-tools && \
	mkdir ~/.vnc/ && \
	mkdir ~/.dosbox && \
	echo $PASSWORD | vncpasswd -f > ~/.vnc/passwd && \
	chmod 0600 ~/.vnc/passwd && \
	echo "set border 0" > ~/.ratpoisonrc  && \
	echo "exec dosbox -conf ~/.dosbox/dosbox.conf -fullscreen -c 'MOUNT C: /dos' -c 'C:' -c 'cd pacman' -c 'mspac'">> ~/.ratpoisonrc && \
	export DOSCONF=$(dosbox -printconf) && \
	cp $DOSCONF ~/.dosbox/dosbox.conf && \
	sed -i 's/usescancodes=true/usescancodes=false/' ~/.dosbox/dosbox.conf && \
	openssl req -x509 -nodes -newkey rsa:2048 -keyout ~/novnc.pem -out ~/novnc.pem -days 3650 -subj "/C=BE/ST=AN/L=AN/O=AN/OU=AN/CN=AN emailAddress=gratien.dhaese@gmail.com"
EXPOSE 6080
CMD vncserver && websockify -D --web=/usr/share/novnc/ --cert=~/novnc.pem 6080 localhost:5901 && tail -f /dev/null
