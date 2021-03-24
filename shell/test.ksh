#!/bin/ksh

# Encodage html
NCODING='"utf-8"'
CSS='"background-color: #00ffff; text-align: center; font-weight: bold"'
# Variable contenant le chemin vers les fichers LOGAPP
FILEAPP=/home/talhent/production/AutomatisationDesTaches/LOGAPP
# Variable contenant le chemin du rendu LOGAPP
RENDU=/home/talhent/production/AutomatisationDesTaches/renduAPP.html
# Variable contenant le chemin vers les donnée de parametrage
ADERHPARAM=/home/talhent/production/AutomatisationDesTaches/PARAMETRE.txt
# Variable contenant le chemin les mots clé désignant les erreurs
MOTS_CLE_ERROR=/home/talhent/production/AutomatisationDesTaches/MotsCles.txt

#-----------------------------------------------------------------------------------#
#                                  FUNCTIONS                                        #
#-----------------------------------------------------------------------------------#

# Condition pour créée un fichier html si elle n'existe pas
ConditionFichierExiste()
{
if test -f $1; then
	rm $1
	else
	touch $1
fi	
}
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
	echo "||+"$x
	fi
done
IFS=$oldIFS # rétablisement du séparateur de champ par défaut
}

#-----------------------------------------------------------------------------------#
#                                   MAIN                                            #
#-----------------------------------------------------------------------------------#

ConditionFichierExiste $RENDU
#Code pour la mise en forme en html(balise html)
echo "<!DOCTYPE html> <html> <head> <meta charset=$ENCODING /> <title>Compte-rendu</title> <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td {padding: 10px;}
</style></head><body><table> <tr style=$CSS><td>JOB-APP</td><td>Description</td><td>Heure début</td><td>Heure fin</td><td>Durée</td><td>Fréquence</td><td>Erreurs </td></tr>" >> $RENDU
#boucle pour parcourir tous les fichiers ce trouvant dans les dossier appropié.
for FILE in `ls $FILEAPP`
do
	Fichier=$(echo $FILE | awk -F . '{print $1}' | cut -d_ -f1,2)
	#Definition de nouvelle variable fils de JOB
	DESC="DESC"$Fichier
	FREQ="FREQ"$Fichier
	PREC="PREC"$Fichier
                 	 # *****************((((()))))******************#
				 	 #******** DATES DE FIN ET DEBUT DE JOB ********#
				 	 #******************((((()))))******************#

	#Definition d'une variable date de fin de JOB et début de JOB
	DATE_DEBUT=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $6}' | sed -n 1p)
	DATE_FIN=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $6}' | sed -n 2p)
	jourDebut=$(echo $DATE_DEBUT | cut -d/ -f3)
	jourFin=$(echo $DATE_FIN | cut -d/ -f3)
	if test -z $DATE_DEBUT || test -z $DATE_FIN; then 
	jourDebut=$(grep -E ^"Run began" $FILEAPP/$FILE | awk '{print $6}')
	jourFin=$(grep -E ^"Run ended" $FILEAPP/$FILE | awk '{print $6}')
	fi
					 # *****************((((()))))******************#
				 	 #******** DATES DE FIN ET DEBUT DE JOB ********#
				 	 #******************((((()))))******************#
	#Definition d'une variable heure de fin de JOB et début de JOB
	HEURE_DEBUT=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $7}' | sed -n 1p)
	HEURE_FIN=$(grep "JOB :.* DATE :" $FILEAPP/$FILE | awk '{print $7}' | sed -n 2p)
	if test -z $HEURE_DEBUT || test -z $HEURE_FIN; then 
	HEURE_DEBUT=$(grep -E ^"Run began" $FILEAPP/$FILE | awk '{print $7}')
	HEURE_FIN=$(grep -E ^"Run ended" $FILEAPP/$FILE | awk '{print $7}')
	fi
	#Décomposition de l'heure de début en Hd:Md/Sd
	Hd=$(echo $HEURE_DEBUT | cut -d: -f1)
	Md=$(echo $HEURE_DEBUT | cut -d: -f2)
	Sd=$(echo $HEURE_DEBUT | cut -d: -f3)
	
	#Décomposition de l'heure de fin en Hf:Mf/Sf
	Hf=$(echo $HEURE_FIN | cut -d: -f1)
	Mf=$(echo $HEURE_FIN | cut -d: -f2)
	Sf=$(echo $HEURE_FIN | cut -d: -f3)
	
					 # *****************((((()))))******************#
				 	 #******** CALCULE DE LA DUREE DES JOBS ********#
				 	 #******************((((()))))******************#
	if test $jourDebut -eq $jourFin; then
	TempsDebutEnSecond=$(echo $Hd $Md $Sd | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	TempsFinEnSecond=$(echo $Hf $Mf $Sf | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	elif test $jourDebut -lt $jourFin; then
	heureFin=$(( $Hf + 24))
	TempsDebutEnSecond=$(echo $Hd $Md $Sd | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	TempsFinEnSecond=$(echo $heureFin $Mf $Sf | awk '{print ($1 * 3600) + ($2 * 60) + $3}')
	fi

	DUREE=$(echo $TempsFinEnSecond $TempsDebutEnSecond | awk '{print $1 - $2 }')
	if test $DUREE -lt 0 || test $DUREE -eq $TempsFinEnSecond
	then
		Tmp="pas defini"
	elif test $DUREE -lt 60
	then
		Tmp="0min $DUREE s"
		
	else
		minute=$(($DUREE / 60 ))
		seconde=$(($DUREE % 60 ))
		Tmp=$minute"min "$seconde"s"
	fi
		 
	 echo "<tr><td>" $(echo $FILE | awk -F . '{print $1}')" </td><td> `grep $Fichier $ADERHPARAM | sed -n 2p | cut -d/ -f 2`</td><td>$HEURE_DEBUT</td><td>$HEURE_FIN</td>
	 <td>$Tmp</td><td> `grep $Fichier $ADERHPARAM | sed -n 3p | cut -d/ -f 2`</td><td>`DetectionErreur $FILE`</td></tr>" >> $RENDU
done
echo "</table> </body> </html>" >> $RENDU

