#!/bin/bash

#Block virtulizor Auto Fetch licenise 
echo "127.0.0.1 api.virtualizor.com" >> /etc/hosts
echo "127.0.0.1 virtualizor.com" >> /etc/hosts

# Remove old license file and create new

chattr -i /usr/local/virtualizor/license2.php
rm -rf /usr/local/virtualizor/license2.php 

echo "Hjmlibt2xQwIofmgmyphvYwlIkdFSdDYfyAthBMY+iegRhBIsZ+eX7gbqupbvVVehppPOZx/ZzGdJsWLKVGvpVK13JXGppNj2qekBGekHcclWQte653R4DjbctI80Z0qxSKKxG/4nr7Z0dPUk8O74VlEG75R0lxluzwt4VPCjP1HI2Xd/UeivkflKTIloL2EJ2X5hftgtwHd/VvvGlZr+fla6/ibhK+iGa8Vx1GVkT37RNDjU6mvMU7u678bPJgPzXn+B30E9iS5bewpJsDWRaMnfwFDLxla5aU6eeU7Xr4+Tl0/mKNWiUb32tH57PUVh3/1en5PudiSpRL5M2PuCJB2TZEViHde2LhV1TYGefv/tp8utRSVDrmAr5li2PlYkYkqKKSjiiF8U/CjOe+lab6gmg4ZmfWe6lZj5LtDg7laDkO2GY8QnjZ5/m/MBTuZLFrL4E6/cOMJsszWNFHgJu+Ae2w46wiYo7IsWEYLETY5bKOSDX2VksK+tGj2pnUlDejhowzLTbdbgT7EBskDupy2zPBm5/Tadf8Ny/eNxfQN5h9efp6foL4Wc6s=" >> /usr/local/virtualizor/license2.php
