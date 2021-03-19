echo "OR"
echo "http://$ip:4084/"
echo " "
echo "Do you want Patch Nulled Version of virtulizor now? Y/N"
read licNULL
# NULLING VIRTULIZOR 
if ([ "$licNULL" == "y" ] || [ "$licNULL" == "y" ]); then	
	echo "Wait while i will do the magic..."
	wget -O p.sh https://raw.githubusercontent.com/python-911/virtulizor/main/patch.sh && chmod 777 p.sh ./p.sh
	echo "Succesfully nulled virtulizor..."
	echo "For everything else hit me on https://github.com/python-911"
	echo "After update or reboot license may be invalid"
	echo "You can patch the nulled version anytime by using below command"
	echo "To use nulled type ./p.sh and enjoy..."

# REVBOOOOT
echo "You will need to reboot this machine to load the correct kernel"
echo -n "Do you want to reboot now ? [y/N]"
read rebBOOT

echo "Nulled version is not for commericial use please buy license form Softaculous Virtualizor !"

if ([ "$rebBOOT" == "Y" ] || [ "$rebBOOT" == "y" ]); then	
	echo "The system is now being RESTARTED"
	reboot;
fi
