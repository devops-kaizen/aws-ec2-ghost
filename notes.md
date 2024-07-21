docker run -d --name some-ghost -e "{{ ghost_env }}" -p "{{ ghost_port_mapping }}" -v "{{ ghost_volume_name }}:/var/lib/ghost/content" "{{ ghost_image }}"


docker run -d --name some-ghost -e NODE_ENV=development -e url=https://blog.vivekteega.com -e database__connection__filename=/var/lib/ghost/content/data/ghost.db -p 2368:2368 -v some-ghost-data:/var/lib/ghost/content ghost

docker run -d --name some-ghost -e NODE_ENV=development -e url=https://blog.vivekteega.com -e database__connection__filename=/var/lib/ghost/content/data/ghost.db -p 2368:2368 -v some-ghost-data:/var/lib/ghost/content ghost


sudo docker run -d --name some-ghost -p 2368:2368 --mount source=ghost-data,targ
et=/var/lib/ghost/content -e https://blog.vivekteega.com -e NODE_ENV=production ghost


sudo docker run -d --name some-ghost -v some-ghost-data:/var/lib/ghost/content -p 2368:2368 -e NODE_ENV=development -e url=http://blog.vivekteega.com ghost
