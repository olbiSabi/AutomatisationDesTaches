#!/bin/ksh

# Encodage html
ENCODING='"utf-8"'
CSS='"background-color: #00ffff; text-align: center; font-weight: bold"'
# Variable contenant le chemin vers les fichers LOGCTM
FILEAPP=/home/talhent/production/LOGCTM
# Variable contenant le chemin du rendu LOGCTM
RENDU=/home/talhent/production/renduCTM.html
# Variable contenant le chemin vers les donnée de parametrage
ADERHPARAM=/home/talhent/production/PARAMETRE.txt
# Variable contenant le chemin les mots clé désignant les erreurs
MOTS_CLE_ERROR=/home/talhent/production/MotsCles.txt

# Condition pour créée un fichier html si elle n'existe pas
if test -f $RENDU; then
	rm $RENDU
	else
	touch $RENDU
fi
#-------- Fonction permettant de parcourrir les logs à la recherche d'erreur ------
DetectionErreur()
{
oldIFS=$IFS # Sauvegarde du séparateur de champ
IFS=$'\n' # nouveau séparateur de champ, le caratère fin de ligne
for MotsCles in $(<$MOTS_CLE_ERROR)
do
	x=$(grep "$MotsCles" $FILEAPP/$1)
	if test -z $x; then
	echo ""
	else
	echo $x"+| "
	fi
done
IFS=$oldIFS # rétablisement du séparateur de champ par défaut
}


#Code pour la mise en forme en html(balise html)
echo "<!DOCTYPE html> <html> <head> <meta charset=$ENCODING /> <title>Compte-rendu</title> <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td {padding: 10px;}
</style></head><body><table> <tr style=$CSS><td>JOB-CTM</td><td>Description</td><td>Heure début</td><td>Heure fin</td><td>Durée</td><td>Fréquence</td><td>Erreurs </td></tr>" >> $RENDU
#boucle pour parcourir tous les fichiers ce trouvant dans les dossier appropié.
for FILE in `ls $FILEAPP`
do
	Fichier=$(echo $FILE| awk -F . '{print $1}')
	#Definition de nouvelle variable fils de JOB
	DESC="DESC"$Fichier
	FREQ="FREQ"$Fichier
	PREC="PREC"$Fichier
	#Definition d'une variable heure de fin de JOB et début de JOB
	HEURE_DEBUT=$(grep -E ^"JOB :" $FILEAPP/$FILE | awk '{print $7}' | sed -n 1p)
	HEURE_FIN=$(grep -E ^"JOB :" $FILEAPP/$FILE | awk '{print $7}' | sed -n 2p)
	
	#Décomposition de l'heure de début en Hd:Md/Sd
	Hd=$(echo $HEURE_DEBUT | cut -d: -f1)
	Md=$(echo $HEURE_DEBUT | cut -d: -f2)
	Sd=$(echo $HEURE_DEBUT | cut -d: -f3)
	TempsDebutEnSecond=$(echo $Hd $Md $Sd | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	
	#Décomposition de l'heure de fin en Hf:Mf/Sf
	Hf=$(echo $HEURE_FIN | cut -d: -f1)
	Mf=$(echo $HEURE_FIN | cut -d: -f2)
	Sf=$(echo $HEURE_FIN | cut -d: -f3)
	TempsFinEnSecond=$(echo $Hf $Mf $Sf | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	
	DUREE=$(echo $TempsFinEnSecond $TempsDebutEnSecond | awk '{print $1 - $2 }')
	if test $DUREE -lt 60; then
		seconde=$DUREE
		minute=0
		else
		let "minute = $DUREE/60 "
		let "seconde = $DUREE%60 "
	fi
		 
	 echo "<tr><td>" $(echo $FILE | awk -F . '{print $1"."$2}')" </td><td> `grep $DESC $ADERHPARAM | cut -d/ -f 2`</td><td>$HEURE_DEBUT</td><td>$HEURE_FIN</td>
	 <td>$minute:$seconde</td><td> `grep $FREQ $ADERHPARAM | cut -d/ -f 2`</td><td>`DetectionErreur $FILE`</td></tr>" >> $RENDU
done
echo "</table> </body> </html>" >> $RENDU

