#!/bin/ksh

#------------------------------------ DESCRIPTION- ----------------------------------#
# @(#)         Script shell qui sera appelé par un shell principale. 
# @(#) ce script recupere toutes les log applicative dans le repertoir logapp:
# @(#) /dz-pareo-ga/applis/pa6/logapp. les fichiers log recupere seront traités
# @(#) et les données important extraite.
#---------------------------------- AUTEUR ET DATE ----------------------------------#
# @(#) Auteur: Sabi ONIANKITAN
# @(#) Date Creation:
#------------------------------------ HISTORIQUE ------------------------------------#
# @(#)|    VERSION   |      NOM     |  PRENOM   |  DATE DE MISE A JOUR  |
#     |     V0.1     |  ONIANKITAN  |   SABI    |  29/03/2021           | 
#-----------------------------------------------------------------------------------#


#. /${_YCDPARM}/pa6.env
#. /${_YCDPARM}/pa6.fonctions.env

#------------------------------------- Encodage html --------------------------------#
NCODING='"utf-8"'
CSS='"background-color: #00ffff; text-align: center; font-weight: bold"'
#------------------------------------- Encodage html --------------------------------#

# Variable contenant le chemin vers les fichers LOGAPP
FILEAPP=/home/talhent/production/AutomatisationDesTaches/LOGAPP
Fist_FILEAPP_SAVE=/home/talhent/production/AutomatisationDesTaches/shell/FICHIER_LOG_APP1.parm
Second_FILEAPP_SAVE=/home/talhent/production/AutomatisationDesTaches/shell/FICHIER_LOG_APP2.parm
DATE_LOGAPP=/home/talhent/production/AutomatisationDesTaches/shell/DATE_DU_DERNIER_LOGAPP.parm
# Variable contenant le chemin du rendu LOGAPP
RENDU=/home/talhent/production/AutomatisationDesTaches/renduAPP.html
# Variable contenant le chemin vers les donnée de parametrage
ADERHPARAM=/home/talhent/production/AutomatisationDesTaches/PARAMETRE.parm
MOTSCLES=/home/talhent/production/AutomatisationDesTaches/MOTSCLES.parm
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
TestSiVide()
{
	if test -z $1; then
	echo ""
	else
	echo "|| $1"
fi
}

DetectionErreur()
{
	ERROR=''error'|'erreur'|'anormal'|'abnormal'|'delai'|'depassement'|'cannot'|'err\.'|'rejet'|"trop petit"|"can not"|"permission denied"|"exit [1-9]"|"jobTest [1-9]"|"code retour [1-9]"'
		x=$(egrep -i $ERROR $FILEAPP/$1)
 	echo "$(TestSiVide "$x")"
}

concateneVariableError()
{
OLDIFS=$IFS
IFS=$'\n'
for MotsCles in 'exit [1-9]' 'anormal' 'abnormal' 'jobTest [1-9]' 'code retour [1-9]' 'delai' 'erreur' 'permission denied' 'error' 'depassement' 'cannot' 'can not' 'trop petit' 'err\.' 'rejet'
do
	echo $MotsCles
	Mots+="| $MotsCles"
	echo "${Mots}"
done
echo "${Mots}"
IFS=$OLDIFS
}

# DetectionErreur()
# {
# for MotsCles in 'exit [1-9]' 'anormal' 'abnormal' 'jobTest [1-9]' 'code retour [1-9]' 'delai' 'erreur' 'permission denied' 'error' 'depassement' 'cannot' 'can not' 'trop petit' 'err\.' 'rejet'
# do
# 	x=$(grep -E -i "$MotsCles" $FILEAPP/$1)
# 	echo "$(TestSiVide "$x")"
# done
# }
FicherRecupere(){
	find $FILEAPP/ -mtime -$1 -type f | awk -F / '{print $NF}' > $Fist_FILEAPP_SAVE
}

#-----------------------------------------------------------------------------------#
#                                   MAIN                                            #
#-----------------------------------------------------------------------------------#

#jobDebut

ConditionFichierExiste $RENDU
ConditionFichierExiste $Second_FILEAPP_SAVE
# recuperation des logs sur un intervalle de jours
FicherRecupere 25

concateneVariableError
# on recupere la date du dernier log exécuté
if test -f $DATE_LOGAPP; then
DERNIER_LOG=$(cat $DATE_LOGAPP)
else
touch $DATE_LOGAPP
fi

# recuperation des logs en fonction de la date du dernier log
for i in $(< $Fist_FILEAPP_SAVE)
do
	DATE_COURANT=$(echo $i | awk -F . '{print $(NF-1)}')
	if test $DATE_COURANT -ge $DERNIER_LOG; then
	echo $i >> $Second_FILEAPP_SAVE
	fi
done

#----------------------------------------------------------------- Code pour la mise en forme en html(balise html)-------------------------------------------------------------------------#
echo "<!DOCTYPE html> <html> <head> <meta charset=$ENCODING /> <title>Compte-rendu</title> <style>table, th, td {border: 1px solid black; border-collapse: collapse;}th, td {padding: 10px;}
</style></head><body><table> <tr style=$CSS><td>JOB-APP</td><td>Description</td><td>Heure début</td><td>Heure fin</td><td>Durée</td><td>Fréquence</td><td>Erreurs </td></tr>" >> $RENDU
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#boucle pour parcourir tous les fichiers ce trouvant dans les dossier appropié.
OLDIFS=$IFS
IFS=$'\n'
for FILE in $(< $Fist_FILEAPP_SAVE)
do
#DetectionErreur $FILE

	Fichier=$(echo $FILE | awk -F . '{print $1}' | cut -d_ -f1,2)
	LETTRE_ENV=`expr substr $Fichier 1 1`
	case $LETTRE_ENV in
		"X")
		Fichier=$(echo $Fichier |  sed 's/^X/X/g')
		DESC="DESC"$Fichier
		FREQ="FREQ"$Fichier
		PREC="PREC"$Fichier
		;;
		"D")
		Fichier=$(echo $Fichier |  sed 's/^D/X/g')
		;;
		"U")
		Fichier=$(echo $Fichier |  sed 's/^U/X/g')
		;;
	esac

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
#----------------------------------------------------------------- Code pour la mise en forme en html(balise html)-------------------------------------------------------------------------#		 
	 echo "<tr><td>" $(echo $FILE | awk -F . '{print $1}')" </td><td> `grep $Fichier $ADERHPARAM | sed -n 2p | cut -d/ -f 2`</td><td>$HEURE_DEBUT</td><td>$HEURE_FIN</td>
	 <td>$Tmp</td><td> `grep $Fichier $ADERHPARAM | sed -n 3p | cut -d/ -f 2`</td><td>`DetectionErreur $FILE`</td></tr>" >> $RENDU

done
IFS=$OLDIFS
echo "</table> </body> </html>" >> $RENDU
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
cat $Fist_FILEAPP_SAVE | awk -F . '{print $(NF-1)}' | tail -1 > $DATE_LOGAPP
#jobFin